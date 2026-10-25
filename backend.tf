
terraform {
  backend "s3" {
    bucket       = "terraform-s3-test-harsha-project"
    key          = "web-project/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

