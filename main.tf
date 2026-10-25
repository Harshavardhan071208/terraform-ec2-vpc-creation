
# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr

  tags = merge(local.common_tags, {
    Name = "myvpc"
  })
}

# -------------------------
# Subnets
# -------------------------

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet_cidrs[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "subnet-1"
  })
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet_cidrs[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "subnet-2"
  })
}

# -------------------------
# Internet Gateway
# -------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = merge(local.common_tags, {
    Name = "my-igw"
  })
}

# -------------------------
# Route Table
# -------------------------

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name = "public-route-table"
  })
}

# -------------------------
# Route Table Associations
# -------------------------

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

# -------------------------
# Security Group
# -------------------------

resource "aws_security_group" "webSg" {
  name        = "web"
  description = "Web server and SSH access"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "HTTP"
    from_port   = local.common_ports.http
    to_port     = local.common_ports.http
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from approved CIDR"
    from_port   = local.common_ports.ssh
    to_port     = local.common_ports.ssh
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "Web-sg"
  })
}

# -------------------------
# S3 Bucket
# -------------------------

resource "aws_s3_bucket" "example" {
  bucket = var.s3_bucket_name

  tags = merge(local.common_tags, {
    Name = "application-bucket"
  })
}

# -------------------------
# EC2 Instance 1
# -------------------------

resource "aws_instance" "webserver1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id

  user_data = file("${path.module}/userdata.sh")

  tags = merge(local.common_tags, {
    Name = "webserver1"
  })
}

# -------------------------
# EC2 Instance 2
# -------------------------

resource "aws_instance" "webserver2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub2.id

  user_data = file("${path.module}/userdata1.sh")

  tags = merge(local.common_tags, {
    Name = "webserver2"
  })
}

# -------------------------
# Application Load Balancer
# -------------------------

resource "aws_lb" "myalb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.webSg.id]
  subnets = [
    aws_subnet.sub1.id,
    aws_subnet.sub2.id
  ]

  tags = merge(local.common_tags, {
    Name = "web-alb"
  })
}

# -------------------------
# Target Group
# -------------------------

resource "aws_lb_target_group" "tg" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = local.common_tags
}

# -------------------------
# Target Group Attachments
# -------------------------

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

# -------------------------
# ALB Listener
# -------------------------

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

