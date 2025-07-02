#!/bin/bash

set -e

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

echo "[+] Waiting for app to deploy..."
sleep 180

# Get the public IP from Terraform output
RAW_INSTANCE_IP=$(terraform output -raw instance_public_ip)

echo "[+] Testing app on http://$RAW_INSTANCE_IP:80"
curl "http://$RAW_INSTANCE_IP:80"

echo "[+] Instance Public IP: $RAW_INSTANCE_IP"


# sleep 650

# terraform destroy -var-file="$CONFIG_FILE" -auto-approve