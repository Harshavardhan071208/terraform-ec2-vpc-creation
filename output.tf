
output "loadbalancerdns" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.myalb.dns_name
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.myvpc.id
}

output "webserver1_public_ip" {
  description = "Public IP of EC2 instance 1"
  value       = aws_instance.webserver1.public_ip
}

output "webserver2_public_ip" {
  description = "Public IP of EC2 instance 2"
  value       = aws_instance.webserver2.public_ip
}

output "s3_bucket_name" {
  description = "Application S3 bucket name"
  value       = aws_s3_bucket.example.bucket
}

