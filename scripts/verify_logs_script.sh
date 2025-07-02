#!/bin/bash

# Install AWS CLI and dependencies
apt-get update -y
apt-get install -y unzip curl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Create directories for logs
# cd /home/ubuntu
# mkdir -p /mylogs/app
# mkdir -p /mylogs/system
mkdir -p /mylogs



# Retrieve logs from S3
echo "Fetching logs from S3 Bucket: ${s3_bucket_name}"
# sudo aws s3 sync s3://techeazy-logs-dev-unique123ss /mylogs
# sudo aws s3 sync s3://${s3_bucket_name} /mylogs/ 

echo "Waiting for logs to appear in S3 bucket: techeazy-logs-dev-unique123ss"
sleep 100
MAX_RETRIES=20
RETRY_DELAY=30  # seconds

for ((i=1; i<=MAX_RETRIES; i++)); do
  echo "Attempt $i: Syncing logs from S3..."
  if sudo aws s3 sync s3://${s3_bucket_name} /mylogs; then
    echo "Logs synced successfully on attempt $i"
    break
  else
    echo "Attempt $i failed. Waiting $RETRY_DELAY seconds before retrying..."
    sleep $RETRY_DELAY
  fi
done




# Final check if logs were synced
if [ "$(ls -A /mylogs/app 2>/dev/null)" ]; then
  echo "Logs found and downloaded."
else
  echo "ERROR: No logs found in /mylogs after $MAX_RETRIES attempts." >&2
  exit 1
fi


# aws s3 cp s3://${s3_bucket_name}/system/ /mylogs/app/ --recursive
# aws s3 cp s3://${s3_bucket_name}/system/ /mylogs/system/ --recursive
# aws s3 cp s3://techeazy-logs-dev-unique123ss/app/ /mylogs/app/ --recursive


# Shutdown instance after fetching logs
echo "Verifier complete. Shutting down in ${fetch_timeout} minutes."
sudo shutdown -h +${fetch_timeout}