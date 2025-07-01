# AWS EC2 Auto Deployment with Terraform & Shell Scripts

This project automates the provisioning of an EC2 instance and the deployment of your application on AWS using Terraform and shell scripts. It supports different environments (Dev, Prod) through configuration files and scripts.

---

## 📁 **Project Structure**

```
tech_eazy_devops_git-user-9/
├── README.md
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── dev_config.tfvars
│   └── prod_config.tfvars
└── scripts/
    ├── deploy.sh
    ├── dev_script.sh
    └── prod_script.sh
```

---

## ⚙️ **Prerequisites**

Before you begin, ensure you have the following:

- **AWS Account** with EC2 access and permissions to create resources
- **IAM User** with programmatic access (access key ID and secret access key)
- **AWS CLI** installed and configured
- **Terraform** installed (version >= 1.0 recommended)
- **Git** (optional, for repository operations)

---

## 🔐 **AWS Credentials Setup**

You must set your AWS credentials in your local environment so Terraform can authenticate with AWS.

### Option 1: Using AWS CLI (Recommended)

```bash
aws configure
```

You'll be prompted to input your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (e.g., `us-east-1`)
- Default output format (e.g., `json`)

### Option 2: Set environment variables directly

```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-1
```

---

## 🚀 **How to Deploy**

### 1️⃣ Clone the Repository

```bash
git clone <your-repo-url>
cd tech_eazy_devops_git-user-9
```

### 2️⃣ Run the Deployment Script

```bash
./scripts/deploy.sh dev  # For Dev environment
./scripts/deploy.sh prod # For Prod environment
```

The script will:
- Load the corresponding Terraform variable file
- Initialize and apply the Terraform configuration
- Output the public IP of the created EC2 instance

### 3️⃣ Access the Application

Visit the public IP shown in the terminal:

```
http://<your-ec2-ip>:80
```

---

## 🛠️ **What Happens Behind the Scenes**

### Terraform provisions:
- EC2 instance in default VPC
- Security group with ports 22 (SSH) and 80 (HTTP) open

### User Data (inside shell script):
- Updates the system
- Installs Java 21, Git, and Maven
- Clones and builds your application
- Launches the application on port 80

---

## ✅ **Security Notes**

- No sensitive keys are stored in the repo
- Make sure your security group is restricted to specific IPs if used in production
- Rotate AWS credentials regularly

---

## 💬 **FAQ**

**Q: Can I deploy to a different AWS region?**  
Yes. Modify the `region` value in `terraform/main.tf` or export `AWS_DEFAULT_REGION`.



