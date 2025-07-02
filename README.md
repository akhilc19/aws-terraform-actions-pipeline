# AWS EC2 Auto Deployment with Terraform & Shell Scripts

This project automates the provisioning of an EC2 instance and the deployment of your application on AWS using Terraform and shell scripts. It supports different environments (Dev, Prod) through configuration files and deployment scripts.

---

## 📁 **Project Structure**

```
tech_eazy_devops_git-user-9/
├── README.md                  # Project documentation
├── terraform/                 # Terraform configurations
│   ├── main.tf                # Main Terraform configuration file
│   ├── outputs.tf             # Defines Terraform outputs (e.g., EC2 public IP)
│   ├── variables.tf           # Public variables file for EC2 and other details
│   ├── dev_config.tfvars      # Variable values for 'Dev' environment
│   ├── prod_config.tfvars     # Variable values for 'Prod' environment
├── scripts/                   # Shell scripts for provisioning and deployments
│   ├── deploy.sh              # Automates provisioning with Terraform
│   ├── dev_script.sh          # Dev-specific configuration script for EC2
│   ├── prod_script.sh         # Production-specific script for EC2
│   ├── verify_logs.sh         # Validates and uploads logs
├── mylogs/                    # Application and system logs
│   ├── app/                   # Stores runtime application logs
│   │   └── my-app.log         # Main application log
│   └── system/                # Tracks provisioning/system logs
│       └── cloud-init.log     # Logs of initialization processes
└── .gitignore                 # Lists files to exclude from version control
```

---

## ⚙️ **Prerequisites**

Ensure the following tools and resources are configured before deploying:

- **AWS Account** with IAM permissions for creating EC2, S3, and other resources.
- **IAM User** with access keys for programmatic access.
- **AWS CLI** installed and configured on your machine.
- **Terraform** (version >= 1.0 recommended).
- **Git** installed for version control.
- An **EC2 Key Pair** set up in AWS Console for securely accessing instances (see [Key Pair Section](#ec2-key-pair-requirement)).

---

## 🔐 **AWS Credentials Setup**

Terraform authenticates with AWS using your configured credentials.

### Option 1: AWS CLI (Recommended)

```bash
aws configure
```
Provide the following inputs:
- AWS Access Key ID
- AWS Secret Access Key
- Default AWS region (e.g., `ap-south-1`)
- Default output format (e.g., `json`)

### Option 2: Environment Variables

Set environment variables explicitly:
```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=ap-south-1
```

---

## EC2 Key Pair Requirement

Ensure you have an EC2 Key Pair set up in the AWS Console. Update the key pair's name in these files:

**`terraform/variables.tf`**
```hcl
variable "key_name" {
  default = "your-key-name-here"
}
```

**`terraform/dev_config.tfvars`**
```hcl
key_name = "your-key-name-here"
```

**`terraform/prod_config.tfvars`**
```hcl
key_name = "your-key-name-here"
```

The Key Pair ensures secure SSH access to the instances.

---

## 🚀 **How to Deploy**

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/git-user-9/tech_eazy_devops_git-user-9.git
cd tech_eazy_devops_git-user-9
```

### 2️⃣ Run the Deployment Script
```bash
./scripts/deploy.sh dev    # For Development Environment
./scripts/deploy.sh prod   # For Production Environment
```
This will:
- Apply Terraform configurations for selected environment
- Output the public IP of the created EC2 instance
- Upload logs to S3 automatically
- Terminate the instance after 10-15 minutes if configured

### 3️⃣ Access the Application
Navigate to:
```
http://<ec2-public-ip>:80
```

---

## 🛠️ **Details of Automation**

### Terraform Provisions:
- **EC2 Instances** within the default VPC.
- **Security Groups** with HTTP (80) and SSH (22) access.
- **IAM Roles** for instances to access S3.

### Shell Scripts:
- Update operating system packages.
- Install required tools such as Java, Git, Maven, AWS CLI, etc.
- Clone, build, and run the application on Port 80.
- Upload logs to the S3 bucket.

---

## Note on Pulling Logs from EC2 to Local

To enable **log pulling from EC2 to your local machine,** follow these steps:

1. **Uncomment Lines in the Script:**
   Locate the following lines in your deployment script between **lines 52–59** and uncomment them:

   ```bash
   # Wait a while for logs to upload
   sleep 100
   cd .. # Save logs at the root level
   PRIVATE_KEY_PATH="/Users/default/CS/DevOps/AWS/ssh-key-ec2.pem" # Change this to your SSH private key path and ensure `chmod 400` on your key
   echo "Trying to SCP logs to local"
   scp -r -i "$PRIVATE_KEY_PATH" ubuntu@$VERIFIER_IP:/mylogs/ . # Pull logs from EC2 to /mylogs/ in your local directory
   cd $TERRAFORM_DIR # Return to Terraform directory for destroy commands
   ```

2. **Specify Your Private Key Path:**
   - Replace the placeholder `"/Users/default/CS/DevOps/AWS/ssh-key-ec2.pem"` under the variable `PRIVATE_KEY_PATH` with the actual path to your EC2 key's private key file.
   - Before using, ensure the private key has the appropriate permissions by running:
     ```bash
     chmod 400 /path/to/your/private-key.pem
     ```

3. **Save the logs locally:**
   After successfully setting this up, the script will pull logs from `/mylogs/` on your EC2 instance to a local `/mylogs/` directory at the repository's root level.

This addition ensures your logs are saved to your local environment automatically.



---

## 💬 **FAQs**

**Q: How can I deploy in a different region?**  
Modify the `aws_region` variable in the `terraform/variables.tf` file and update it in the `.tfvars` files.

**Q: What happens if deployment fails?**  
Terraform maintains a state file. Retry by running the deployment script again.

**Q: Where can I find the logs?**  
Logs are stored in the `mylogs/` directory or uploaded to the configured S3 bucket.

---


