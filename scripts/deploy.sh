#!/bin/bash

# Check for environment argument
if [ -z "$1" ]; then
  echo "[Error] Usage: $0 <environment>"
  exit 1
fi

ENV="$1"
ENV_LOWER=$(echo "$ENV" | tr '[:upper:]' '[:lower:]')
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"
CONFIG_FILE="${ENV_LOWER}_config.tfvars"

# Move to the Terraform directory
cd "$TERRAFORM_DIR" || {
  echo "[Error] Failed to change directory to Terraform folder."
  exit 1
}

echo "[+] Initializing Terraform..."
terraform init

echo "[+] Applying configuration for environment: $ENV"
terraform apply -var-file="$CONFIG_FILE" -auto-approve

echo "[+] Waiting 200 seconds for app to deploy in ec2 instance"
sleep 200

# Get the public IP from Terraform output
RAW_INSTANCE_IP=$(terraform output -raw instance_public_ip)

echo -e "\n"
echo "[+] Testing app on http://$RAW_INSTANCE_IP:80"
echo -e "\n"

echo -e "\n"
curl "http://$RAW_INSTANCE_IP:80"
echo -e "\n"
echo -e "\n"

echo "[+] Instance Public IP: $RAW_INSTANCE_IP"

echo "[+] Deploying Log Verification EC2 instance..."
terraform apply -var-file="$CONFIG_FILE" -target=aws_instance.log_verifier -auto-approve
VERIFIER_IP=$(terraform output -raw verifier_instance_public_ip)


echo "Verified Public IP: $VERIFIER_IP"


# #To verify and pull logs from ec2 to local.
# echo "Wait 2min for verifier ec2 (read only) to pull the logs from s3 to local environment"
# sleep 120
# cd .. # to save logs at root level
# PRIVATE_KEY_PATH="/Users/default/CS/DevOps/AWS/ssh-key-ec2.pem" #change this to your ssh private key path, also make sure to use `chmod 400` on your key before using
# echo "trying to scp logs to local"
# scp -r -i "$PRIVATE_KEY_PATH" ubuntu@$VERIFIER_IP:/mylogs/ .   #to pull logs from readonly ec2 to your local directory /mylogs/
# cd $TERRAFORM_DIR # to run destroy need to go to terraform directory

echo "Terraform destroy will run after 10minutes..."
echo "You can press ctrl+c and do it earlier as well"
sleep 650

terraform destroy -var-file="$CONFIG_FILE" -auto-approve