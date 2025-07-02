#!/bin/bash
set -e

# Update system and install dependencies
apt-get update -y
apt-get install -y unzip curl git openjdk-21-jdk maven

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install


# Set JAVA_HOME
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
export PATH=$JAVA_HOME/bin:$PATH

cd /home/ubuntu
git clone ${repo_url} app
#git checkout HEAD~1 # Latest commit in repo has bug two @GetMapping("/")

cd app
mvn clean package

# Run the Java app
nohup java -jar target/*.jar --server.port=80 > /var/log/my-app.log 2>&1 &

# Wait for the app to start
sleep 30

# Upload Logs to S3
aws s3 cp /var/log/cloud-init.log s3://${s3_bucket_name}/system/
aws s3 cp /var/log/my-app.log s3://${s3_bucket_name}/app/

# Shutdown after timeout
sudo shutdown -h +${shutdown_minutes}

