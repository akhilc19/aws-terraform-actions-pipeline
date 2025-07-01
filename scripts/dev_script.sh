#!/bin/bash
set -e

# Update and install dependencies
apt-get update -y
apt-get install -y openjdk-21-jdk maven git

# Set JAVA_HOME
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
export PATH=$JAVA_HOME/bin:$PATH

# Clone the repo
cd /home/ubuntu
git clone https://github.com/techeazy-consulting/techeazy-devops app
cd app
# git checkout HEAD~1 # Latest commit in repo has bug two @GetMapping("/")

# Build the application
mvn package

# Run the app in background and redirect output
nohup java -jar target/techeazy-devops-0.0.1-SNAPSHOT.jar > /home/ubuntu/app.log 2>&1 &

