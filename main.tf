# -------------------------------
# VPC
# -------------------------------
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "TerraformAssignmentVPC"
  }
}

# -------------------------------
# Public Subnets
# -------------------------------
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet-AZ1"
  }
}

resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet-AZ2"
  }
}

# -------------------------------
# Private Subnets
# -------------------------------
resource "aws_subnet" "private_subnet_az1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "PrivateSubnet-AZ1"
  }
}

resource "aws_subnet" "private_subnet_az2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "eu-west-1b"
  tags = {
    Name = "PrivateSubnet-AZ2"
  }
}

# -------------------------------
# Internet Gateway
# -------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "TerraformAssignmentIGW"
  }
}

# -------------------------------
# Public Route Table
# -------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------------
# Security Groups
# -------------------------------
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_PUBLIC_IP/32"] # Replace with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebServerSG"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB-SG"
  }
}

# -------------------------------
# EC2 Instances
# -------------------------------
resource "aws_instance" "web_server_1" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_az1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name      = "firstkeypair"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Hello from Web Server 1</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "WebServer-AZ1"
  }
}

resource "aws_instance" "web_server_2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_az2.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name      = "firstkeypair"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Hello from Web Server 2</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "WebServer-AZ2"
  }
}

# -------------------------------
# Application Load Balancer
# -------------------------------
resource "aws_lb" "app_lb" {
  name               = "terraform-assignment-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]

  enable_deletion_protection = false

  tags = {
    Name = "TerraformAssignmentALB"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "terraform-assignment-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "TerraformAssignmentTG"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "web_server_1_attach" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.web_server_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_server_2_attach" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.web_server_2.id
  port             = 80
}

# -------------------------------
# Outputs
# -------------------------------
output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}