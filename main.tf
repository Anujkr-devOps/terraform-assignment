#Main resources (VPC,EC2,etc)

#VPC Resource
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "TerraformAssignmentVPC"
  }
}

#Public Subnet Resource in AZ1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet-AZ1"
  }
}

#Public Subnet Resource in AZ2
resource "aws_subnet" "public_subnet_az2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet-AZ2"
  }
}


#Internet Gateway Resource
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "TerraformAssignmentIGW"
  }
}

#Public Route Table Resource
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "PublicRouteTable"
  }
}

#Route to Internet
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#Associate Route Table with Public Subnet AZ1
resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

#Associate Route Table with Public Subnet AZ2
resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for Web Servers
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
    cidr_blocks = ["YOUR_PUBLIC_IP/32"] # Replace with your IP for security
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

# EC2 Instance in AZ1
resource "aws_instance" "web_server_1" {
  ami           = "ami-0c02fb55956c7d316" #Amazon Linux 2 AMI 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
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

# EC2 Instance in AZ2
resource "aws_instance" "web_server_2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_2.id
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

# Elastic IP for Web Server 1
resource "aws_eip" "eip_1" {
  instance = aws_instance.web_server_1.id
  tags = {
    Name = "ElasticIP-WebServer1"
  }
}

# Elastic IP for Web Server 2
resource "aws_eip" "eip_2" {
  instance = aws_instance.web_server_2.id
  tags = {
    Name = "ElasticIP-WebServer2"
  }
}
