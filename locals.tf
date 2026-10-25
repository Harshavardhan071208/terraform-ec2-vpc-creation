
locals {
  common_tags = {
    Project     = "Terraform-Web-Project"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }

  resource_name = "web"

  common_ports = {
    http = 80
    ssh  = 22
  }
}

