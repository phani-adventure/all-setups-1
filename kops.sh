#!/bin/bash

# Exit if any command fails
set -e

# Step 0: Prompt for AWS credentials and region
echo "🛠️   Configuring AWS CLI..."
aws configure

# Step 1: Install kubectl
echo "⬇️  Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Step 2: Install kops
echo "⬇️  Installing kops..."
wget https://github.com/kubernetes/kops/releases/download/v1.32.0/kops-linux-amd64
chmod +x kops-linux-amd64
mv kops-linux-amd64 /usr/local/bin/kops

# Step 3: Create S3 bucket for KOPS state store
BUCKET_NAME="cloudanddevopsbyphani00734567.k8s.local"
REGION=$(aws configure get region)

echo "🪣 Creating S3 bucket $BUCKET_NAME in $REGION..."
aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --region $REGION --versioning-configuration Status=Enabled
export KOPS_STATE_STORE=s3://$BUCKET_NAME

# Step 4: Set cluster name and availability zone
CLUSTER_NAME="agoproject1.k8s.local"
