#!/bin/bash
set -euo pipefail

# STEP-0: ensure basic tools
yum update -y
yum install -y wget curl

# STEP-1: install git, maven (and keep Java 11)
yum install -y git maven

# Install OpenJDK 11 (amazon-linux-extras available on Amazon Linux)
if command -v amazon-linux-extras >/dev/null 2>&1; then
  amazon-linux-extras enable java-openjdk11
  yum install -y java-11-openjdk-devel
else
  # Fallback for RHEL/CentOS: install from yum repos
  yum install -y java-11-openjdk-devel
fi

# Verify java
java -version

# STEP-2: Add Jenkins repo (official)
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# STEP-3: install Jenkins
yum install -y jenkins

# STEP-4: configure alternatives if needed (optional interactive)
# update-alternatives --config java   # you can run this manually if multiple java versions present

# STEP-5: enable and start Jenkins so it is enabled across reboots
systemctl daemon-reload
systemctl enable --now jenkins.service

# STEP-6: show status and initial admin password location
systemctl status jenkins --no-pager
echo
echo "Initial admin password (if present):"
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
  cat /var/lib/jenkins/secrets/initialAdminPassword
else
  echo "/var/lib/jenkins/secrets/initialAdminPassword not present yet (Jenkins still initializing)"
fi

# Optional: open firewall (if firewalld in use)
# firewall-cmd --permanent --add-port=8080/tcp
# firewall-cmd --reload
