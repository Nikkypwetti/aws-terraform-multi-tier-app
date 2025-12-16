terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1" # You can change this to your preferred region
}

# 1. Create the VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" # This gives you 65,536 IP addresses

  tags = {
    Name = "My-DevOps-Project-VPC"
  }
}

# 2. Create an Internet Gateway
# This is attached to the VPC we created above using 'aws_vpc.main.id'
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "My-DevOps-Gateway"
  }
}

# 3. Create a PUBLIC Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"    # Range: 10.0.1.0 - 10.0.1.255
  availability_zone       = "us-east-1a"     # We pin this to AZ 'a'
  map_public_ip_on_launch = true             # Auto-assign public IP (Make it public!)

  tags = {
    Name = "My-Public-Subnet"
  }
}

# 4. Create a PRIVATE Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"    # Range: 10.0.2.0 - 10.0.2.255
  availability_zone = "us-east-1a"     # Keeping it in the same AZ for low latency

  tags = {
    Name = "My-Private-Subnet"
  }
}

# 5. Create Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "My-Public-Route-Table"
  }
}

# 6. Associate the Route Table with the Public Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 7. Create a Security Group (Firewall)
resource "aws_security_group" "web_sg" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP (Port 80) from anywhere
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH (Port 22) - Optional, for later
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (so the server can download updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My-Web-SG"
  }
}

# 8. Data Source: Get the latest Amazon Linux 2023 AMI
# Instead of hardcoding an ID like "ami-12345", we ask AWS for the latest one.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 9. Create the EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro" # Free tier eligible
  subnet_id     = aws_subnet.public_subnet.id

  # Attach the Security Group we created above
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # This script runs ONCE when the server boots up
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform! You did it! 🚀</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "My-Terraform-Web-Server"
  }
}

# 10. Output the Public IP
# This tells Terraform to print the IP address at the end so you don't have to look for it.
output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}

# 11. Create a 2nd PRIVATE Subnet (Required for RDS)
resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"    # New range
  availability_zone = "us-east-1b"     # Different AZ (b instead of a)

  tags = {
    Name = "My-Private-Subnet-B"
  }
}

# 12. Create DB Subnet Group
resource "aws_db_subnet_group" "my_db_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_b.id]

  tags = {
    Name = "My-DB-Subnet-Group"
  }
}

# 13. Create Database Security Group
resource "aws_security_group" "db_sg" {
  name        = "allow_mysql"
  description = "Allow MySQL traffic from Web Server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from Web Layer"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] # Only the Web SG can enter!
  }

  tags = {
    Name = "My-DB-SG"
  }
}

# 14. Create the MySQL Database
resource "aws_db_instance" "my_database" {
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = var.db_password  # Using the variable here
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true          # vital for learning/destroying easily
  db_subnet_group_name   = aws_db_subnet_group.my_db_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "My-Terraform-DB"
  }
}