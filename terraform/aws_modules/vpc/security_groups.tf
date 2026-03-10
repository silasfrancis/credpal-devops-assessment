resource "aws_default_security_group" "default" {
  description = "Default security group with restricted access"
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "default-restricted"
  }
}

resource "aws_security_group" "alb" {
  description = "Security group for ALB with restricted access"
  name = "alb-security_group"
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.tags}-security_group-alb"      
  }
}

resource "aws_security_group" "ec2" {
  description = "Security group for EC2 instances with restricted access"
  name = "ec2-security_group"
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.tags}-security_group-ec2"      
  }
}