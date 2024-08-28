#!/bin/bash

# Variables
BUCKET_NAME="terraform-github-gitlab-tf-state-backend"
DYNAMODB_TABLE_NAME="terraform-state-locking-table"
REGION="ap-south-1"

# Check if S3 bucket exists
if aws s3api head-bucket --bucket "$BUCKET_NAME" &>/dev/null; then
  echo "S3 bucket $BUCKET_NAME already exists."
else
  echo "Creating S3 bucket $BUCKET_NAME..."
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"
  aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
  aws s3api put-bucket-acl --bucket $BUCKET_NAME --acl private
  aws s3api put-bucket-encryption --bucket "$BUCKET_NAME" --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
  echo "S3 bucket $BUCKET_NAME created with versioning and encryption."
fi

# Check if DynamoDB table exists
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE_NAME" --region "$REGION" &>/dev/null; then
  echo "DynamoDB table $DYNAMODB_TABLE_NAME already exists."
else
  echo "Creating DynamoDB table $DYNAMODB_TABLE_NAME..."
  aws dynamodb create-table \
    --table-name "$DYNAMODB_TABLE_NAME" \
    --attribute-definitions AttributeName=LockID, AttributeType=S \
    --key-schema AttributeName=LockID, KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"
  echo "DynamoDB table $DYNAMODB_TABLE_NAME created."
fi