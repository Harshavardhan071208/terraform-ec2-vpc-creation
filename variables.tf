
variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"
}

variable "availability_zones" {
  description = "Availability zones for public subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["192.168.1.0/24", "192.168.2.0/24"]
}

variable "ami_id" {
  description = "Amazon Machine Image ID for EC2"
  type        = string
  default     = "ami-02b8269d5e85954ef"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "s3_bucket_name" {
  description = "Globally unique name for the application S3 bucket"
  type        = string
}

variable "alb_name" {
  description = "Application Load Balancer name"
  type        = string
  default     = "myalb"
}

variable "target_group_name" {
  description = "ALB target group name"
  type        = string
  default     = "myTG"
}

variable "ssh_cidr" {
  description = "CIDR allowed to connect to SSH"
  type        = string
  default     = "0.0.0.0/0"
}

