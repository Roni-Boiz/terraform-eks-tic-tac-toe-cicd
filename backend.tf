terraform {
  backend "s3" {
    bucket         = local.bucket_name
    key            = "tf-infra/terraform.tfstate"
    region         = local.region
    dynamodb_table = local.dynamodb_table_name
    encrypt        = true
  }
}