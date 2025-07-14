# AWS EC2 Auto Deployment with Terraform & GitHub Actions

This project automates the provisioning of EC2 instances and the deployment of your application on AWS using **Terraform** and **GitHub Actions**. It supports different environments (Dev, Prod) via configuration files.

---

## 📁 **Project Structure**

```
tech_eazy_devops_git-user-9/
├── README.md                  # Project documentation
├── .gitignore                 # Lists files to exclude from version control
├── .github/
│   └── workflows/
│       └── deploy.yml         # GitHub Actions workflow for deployment
├── terraform/                 # Terraform configurations
│   ├── main.tf                # Main Terraform configuration file
│   ├── outputs.tf             # Defines Terraform outputs (e.g., EC2 public IP)
│   ├── variables.tf           # Common variables (e.g., region, key pair name)
│   ├── dev_config.tfvars      # Variable values for 'Dev' environment
│   ├── prod_config.tfvars     # Variable values for 'Prod' environment
├── scripts/                   # Shell scripts for configuration and log validation
│   ├── deploy.sh              # [OBSOLETE] Legacy deployment script (replaced by deploy.yml)
│   ├── dev_script.sh          # Dev-specific configuration script for EC2
│   ├── prod_script.sh         # Production-specific script for EC2
│   ├── verify_logs.sh         # Validates and uploads logs
├── mylogs/                    # Application and system logs
│   ├── app/                   # Stores runtime application logs
│   │   └── my-app.log         # Main application log
│   └── system/                # Tracks provisioning/system logs
│       └── cloud-init.log     # Logs of initialization processes
```

---

## ⚙️ **Prerequisites**

* **Fork this repository** – You must fork it to your own GitHub account so you can add secrets (you cannot add secrets to a repo you don't own).

* **AWS Account** with IAM permissions to provision EC2, S3, etc.

* **GitHub Secrets**

  * `AWS_ACCESS_KEY_ID` – IAM user access key
  * `AWS_SECRET_ACCESS_KEY` – IAM user secret key
  * `SSH_PRIVATE_KEY` – Private key for SSH access to EC2 instances
* Terraform installed (for local testing if required)
* EC2 Key Pair configured in AWS and referenced in Terraform configs

---

## 🔒 **Private Repository Setup for Production Config**

For enhanced security, production configuration should be stored in a separate private repository:

### **Step 1: Create Private Repository**

1. Create a new **private repository** on GitHub (e.g., `your-username/terraform-prod-configs`)
2. Copy the `prod_config.tfvars` file from `./terraform/prod_config.tfvars` in this repository
3. Add the `prod_config.tfvars` file to your private repository

### **Step 2: Generate Personal Access Token (PAT)**

1. Go to GitHub Settings → Developer settings → Personal Access Tokens → Tokens (classic)
2. Generate a new token with **repo** access permissions
3. Copy the generated token for use in GitHub Secrets

### **Step 3: Configure Additional GitHub Secrets**

Add these secrets to your forked repository:

* **`PRIVATE_REPO`** – URL of your private repository
  ```
  github.com/your-username/terraform-prod-configs
  ```
  (note: do not keep https:// in repo link above)

* **`PRIVATE_REPO_KEY`** – Personal Access Token with repo access
  ```
  ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ```

⚠️ **Important**: Replace `your-username` with your actual GitHub username and ensure the private repository contains your production Terraform variables.

---

## 🔑 **Step: Configure Terraform Variables**

Before triggering deployment, update the Terraform configuration files for your AWS environment:

1. Open `terraform/variables.tf`
2. Set the default values for common variables like EC2 Key Pair name:

```hcl
variable "key_name" {
  default = "your-ec2-keypair-name" # Set your AWS Key Pair name
}
```

3. Edit `terraform/dev_config.tfvars` and `terraform/prod_config.tfvars`:

* Example (`dev_config.tfvars`):

```hcl
key_name      = "your-ec2-keypair-name"
```

* Example (`prod_config.tfvars`):

```hcl
key_name      = "your-ec2-keypair-name"
```

⚠️ Ensure your EC2 Key Pair exists in the selected AWS region. 
*ap-south-1 (Mumbai) is being used by default in this project, so kindly create a ec2 key pair on this region for smoother experience during execution. Otherwise kindly change ap-south-1 at all places to your preferred region*

---

## 🔐 **How to Get SSH Private Key from .pem File**

When you create an AWS EC2 Key Pair, AWS provides a `.pem` file. To use this in GitHub Actions, you must convert it to a format that can be stored as a secret.

### Steps:

1. **Generate the Key Pair in AWS Console** (download the `.pem` file)
2. Open the `.pem` file in a text editor and copy its contents.
3. Add it as a GitHub secret named `SSH_PRIVATE_KEY` in your forked repository.

Example:

```bash
cat path/to/your-key.pem
```

Copy the entire output (including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`) into the GitHub secret.

⚠️ Ensure your `.pem` file permissions are secure:

```bash
chmod 400 path/to/your-key.pem
```

---

## 🚀 **Deployment Workflow**

The deployment is managed via GitHub Actions.

### ✅ Trigger Methods

* **Push to Branch**: `devops/a3`
* **Git Tags**: `deploy-dev` (for Dev), `deploy-prod` (for Prod)
* **Manual Trigger**: Run from GitHub Actions → Select Stage (dev/prod)

---

#### 🏷️ **Trigger Deployment via Git Tags**

To deploy to **Dev** or **Prod**, create and push the appropriate Git tag:

*⚠️ Make sure your working directory is clean (git status) before creating tags to avoid pushing unwanted changes.*

##### For Dev Environment:

```bash
git tag deploy-dev
git push origin deploy-dev
```

##### For Prod Environment:

```bash
git tag deploy-prod
git push origin deploy-prod
```

The GitHub Actions workflow will automatically detect the tag and deploy to the respective environment.

---

---

### 📖 Overview of Workflow

The workflow performs the following steps:

1. **Checkout Repository** – Fetches the code from the repository.

2. **Configure AWS Credentials** – Uses GitHub Secrets to authenticate with AWS.

3. **Setup Terraform** – Installs Terraform and initializes configuration.

4. **Determine Stage** – Sets the target environment (dev or prod) based on trigger type.

5. **Provision App EC2 Instance (Write Access)**

   * Deploys the first EC2 instance with **write access to S3**.
   * Installs required software (Java, Maven, Git, etc.).
   * Pulls source code from the repository and builds the Maven application.
   * Runs the application and pushes logs (system and app logs) to the S3 bucket.

6. **Provision Verifier EC2 Instance (Read Access)**

   * Deploys a second EC2 instance with **read-only access to S3**.
   * Uses AWS CLI to pull logs from the S3 bucket to the instance.

7. **Log Validation via SSH**

   * SSH into the Verifier EC2 instance.
   * Validates that required logs exist in S3.
   * Prints the last 20 lines of each log for inspection.

8. **App Health Check** – Ensures the application is healthy (HTTP 200 response).

9. **Destroy Infrastructure** – After validation, destroys all provisioned resources and cleans up Terraform workspaces.

This workflow fully automates the lifecycle: provisioning, deployment, validation, and cleanup, ensuring no manual intervention is needed during the process.

---