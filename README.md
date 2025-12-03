# terraform-assignment
git repo for terraform assignment


# Terraform Assignment – AWS VPC, EC2, and ALB Setup

## Overview
This project provisions an AWS infrastructure using Terraform. It includes:
- A custom VPC with public and private subnets.
- EC2 instances running Nginx in private subnets.
- An Application Load Balancer (ALB) in public subnets.
- NAT Gateway for outbound internet access.
- Security groups for controlled access.
- AWS Systems Manager Session Manager for secure instance access.

## Architecture
**Components:**
- **VPC:** `10.0.0.0/16`
- **Public Subnets:** `10.0.1.0/24` (AZ1), `10.0.2.0/24` (AZ2)
- **Private Subnets:** `10.0.10.0/24` (AZ1), `10.0.20.0/24` (AZ2)
- **Internet Gateway:** For public subnet internet access.
- **NAT Gateway:** For private subnet outbound access.
- **EC2 Instances:** Amazon Linux 2, Nginx installed via `user_data`.
- **ALB:** Distributes traffic across EC2 instances.
- **Target Group:** Health checks on `/health.html`.
- **IAM Role:** Enables Session Manager access.

## Prerequisites
- AWS CLI configured with credentials.
- Terraform installed (`>= v1.0`).
- An existing AWS key pair for SSH (optional if using Session Manager).

## Deployment Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/Anujkr-devOps/terraform-assignment.git
   cd terraform-assignment
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Validate configuration:**
   ```bash
   terraform validate
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply
   ```
   Confirm with `yes`.

## What Terraform Creates
- VPC, subnets, route tables, IGW, NAT Gateway.
- Security groups for ALB and EC2.
- EC2 instances with Nginx installed and running.
- ALB with listener and target group.
- IAM role for Session Manager.

## Testing
1. **Get ALB DNS Name:**
   ```bash
   terraform output alb_dns_name
   ```
   `terraform-assignment-alb-2077771958.eu-west-1.elb.amazonaws.com/`

2. **Access the application:**
   ```bash
   curl http://terraform-assignment-alb-2077771958.eu-west-1.elb.amazonaws.com/
   ```
   Expected:
   ```
   <h1>Hello from Web Server 1</h1>
   ```

3. **Check health status:**
   - Go to **AWS Console → EC2 → Target Groups → terraform-assignment-tg**.
   - Targets should show **healthy**.

## Session Manager Access
- Navigate to **AWS Console → Systems Manager → Session Manager → Start Session**.
- Select an instance and start a session (no SSH keys or public IP required).

## Security Best Practices
- Restrict HTTP access to ALB SG only (not `0.0.0.0/0`).
- Use Session Manager instead of SSH for private instances.
- Enable logging and monitoring for ALB and EC2.

## Cleanup
To destroy all resources:
```bash
terraform destroy
```

## Future Enhancements
- Add Auto Scaling Group for EC2.
- Enable ALB access logs.
- Add CloudWatch alarms for health checks.