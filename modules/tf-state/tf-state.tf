# Create S3 Bucket
resource "aws_s3_bucket" "tf-state-bucket" {
  bucket = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "tf-state-bucket-acl" {
  bucket = aws_s3_bucket.tf-state-bucket.id
  depends_on = [aws_s3_bucket_ownership_controls.tf-state-bucket-ownership]
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "tf-state-bucket-ownership" {
  bucket = aws_s3_bucket.tf-state-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.tf-state-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "tf-state-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.tf-state-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tf-state-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Create DynamoDB Table
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}