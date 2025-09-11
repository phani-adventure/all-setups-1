#!/bin/bash
# Update system
sudo yum update -y

# Install Java (Jenkins requires Java 11+; we use Amazon Corretto 17)
sudo amazon-linux-extras enable corretto17
sudo yum install -y java-17-amazon-corretto

# Verify Java installation
java -version

# Add Jenkins repo
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Import Jenkins key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install -y jenkins

# Enable and start Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Check Jenkins status
sudo systemctl status jenkins
