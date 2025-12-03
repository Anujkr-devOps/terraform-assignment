#outputs like VPC ID, Subnet IDs, EC2 instance public IPs for easy reference

output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}

output "web_server_1_public_ip" {
  value = aws_instance.web_server_1.public_ip
}

output "web_server_2_public_ip" {
  value = aws_instance.web_server_2.public_ip
}