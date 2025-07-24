#!/bin/bash


# Update system and install dependencies
# apt-get update -y
# apt-get install -y unzip git openjdk-21-jdk maven

# # Install AWS CLI v2
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install


# Set JAVA_HOME
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
export PATH=$JAVA_HOME/bin:$PATH

cd /home/ubuntu
git clone ${repo_url} app
#git checkout HEAD~1 # Latest commit in repo has bug two @GetMapping("/")

cd app
mvn clean package

# To fix permission issues
sudo touch /var/log/my-app.log
sudo chown ubuntu:ubuntu /var/log/my-app.log


# Run the Java app
nohup java -jar target/*.jar --server.port=80 > /var/log/my-app.log 2>&1 &

# Wait for app to run
sleep 5



# ------------------------------------------------------------------------------
# Install and Configure CloudWatch Agent (Ubuntu)
# ------------------------------------------------------------------------------
# sudo apt-get update
# sudo apt-get install collectd -y

# echo "Downloading CloudWatch Agent .deb..."
# wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/amazon-cloudwatch-agent.deb

# echo "Installing CloudWatch Agent..."
# sudo dpkg -i /tmp/amazon-cloudwatch-agent.deb

echo 'export PATH=$PATH:/opt/aws/amazon-cloudwatch-agent/bin' >> ~/.bashrc
source ~/.bashrc


echo "Writing CloudWatch Agent config..."
cat << 'EOF' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
${cw_agent_config_json}
EOF

echo "Starting CloudWatch Agent..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

# Wait a bit to ensure CW agent starts
sleep 10

# Inject test log entry for monitoring validation
echo "Error: Simulated a fake error failure on $(date)" >> /var/log/my-app.log
echo "Exception: Simulated a fake exception for testing on $(date)" >> /var/log/my-app.log
echo "Injected one fake Error and Exception into /var/log/my-app.log"

echo "Something went wrong - ERROR" >> /var/log/my-app.log
echo "NullPointerException occurred" >> /var/log/my-app.log


# Upload Logs to S3
sudo aws s3 cp /var/log/cloud-init.log s3://${s3_bucket_name}/prod/system/
sudo aws s3 cp /var/log/my-app.log s3://${s3_bucket_name}/prod/app/

# Shutdown after timeout
sudo shutdown -h +${shutdown_minutes}

