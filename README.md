# AWS Multi-Tier Infrastructure with Terraform

## 📖 Project Overview

This project automates the deployment of a scalable, multi-tier web application architecture on AWS using **Terraform**. It demonstrates Infrastructure as Code (IaC) best practices, including modular VPC networking, security groups, and automated EC2 provisioning.

## 🏗️ Architecture

The infrastructure includes:
* **VPC:** Custom Virtual Private Cloud for network isolation.
* **Public Subnet:** Hosts the web server (accessible via Internet Gateway).
* **Private Subnet:** Prepared for backend/database resources (secure isolation).
* **Security Groups:** Strictly scoped firewall rules (HTTP/80).
* **EC2 Automation:** Auto-provisioning of Amazon Linux 2023 with Apache Web Server.

## 🛠️ Tech Stack

* **Cloud Provider:** AWS (Amazon Web Services)
* **IaC Tool:** Terraform
* **Scripting:** Bash (User Data for server configuration)

## 🚀 How to Run

### Prerequisites

* Terraform installed
* AWS CLI configured with credentials

### Deployment Steps

1. **Clone the repository:**

    ```bash
    git clone [https://github.com/YOUR_USERNAME/aws-terraform-multi-tier-app.git](https://github.com/YOUR_USERNAME/aws-terraform-multi-tier-app.git)
    cd aws-terraform-multi-tier-app
    ```

2. **Initialize Terraform:**

    ```bash
    terraform init
    ```

3. **Plan the deployment:**

    ```bash
    terraform plan
    ```

4. **Apply changes:**

    ```bash
    terraform apply --auto-approve
    ```

5. **Access the Application:**

    Terraform will output the `web_server_public_ip`. Open this IP in your browser to verify the deployment.

## 🧹 Cleanup

To avoid AWS charges, destroy the resources when finished:
```bash
terraform destroy