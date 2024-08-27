module "tf-state" {
  source              = "./modules/tf-state"
  bucket_name         = local.bucket_name
  dynamodb_table_name = local.dynamodb_table_name
}

module "eks" {
  source = "./modules/eks"
}