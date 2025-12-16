# AWS Multi-Tier Infrastructure with Terraform

## 📖 Project Overview
This project automates the deployment of a production-ready **2-Tier Web Architecture** on AWS using Terraform. It features a public-facing web server and a secure, isolated database backend.

## 🏗️ Architecture
* **VPC:** Custom Network with public and private subnets across **2 Availability Zones**.
* **Public Tier:** EC2 Web Server (Amazon Linux 2023) with Auto-assigned Public IP.
* **Private Tier:** RDS MySQL Database (isolated from the internet).
* **Security:**
  * **Web SG:** Allows HTTP (80) from anywhere.
  * **DB SG:** Allows MySQL (3306) **ONLY** from the Web SG.
 
  * ![Architecture Diagram](./architecture-diagram.png)

## 🛠️ Tech Stack
* **Cloud:** AWS (VPC, EC2, RDS, IAM)
* **IaC:** Terraform (Modular & Variable-driven)
* **Database:** MySQL 8.0

## 🚀 How to Run

1.  **Clone the repo:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/aws-terraform-multi-tier-app.git
    ```

2.  **Create secrets file:**
    Create a `terraform.tfvars` file (this is git-ignored for security):
    ```hcl
    db_password = "your-secure-password"
    ```

3.  **Deploy:**
    ```bash
    terraform init
    terraform apply --auto-approve
    ```

## 🧹 Cleanup
To destroy all resources and stop billing:
```bash
terraform destroy
```
