
cidr       = "192.168.0.0/16"
aws_region = "ap-south-1"

availability_zones = ["ap-south-1a", "ap-south-1b"]
subnet_cidrs       = ["192.168.1.0/24", "192.168.2.0/24"]

ami_id        = "ami-0ba051b596cabfebe"
instance_type = "t3.micro"

s3_bucket_name = "terraform-s3-test-harsha-project"

alb_name          = "myalb"
target_group_name = "myTG"

# Replace with your public IP/CIDR for safer SSH access.
ssh_cidr = "3.7.62.123/32"

