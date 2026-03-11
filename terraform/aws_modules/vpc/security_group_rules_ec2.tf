resource "aws_vpc_security_group_ingress_rule" "ec2_ingress_rule_app_blue" {
  description = "Allow inbound traffic from ALB to EC2 on port 3000 for blue deployments"  
  security_group_id = aws_security_group.ec2.id
  from_port = 3000
  to_port = 3000
  ip_protocol = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
  tags = {
  Resource = "EC2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ingress_rule_app_green" {
  description = "Allow inbound traffic from ALB to EC2 on port 3001 for green deployments"  
  security_group_id = aws_security_group.ec2.id
  from_port = 3001
  to_port = 3001
  ip_protocol = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
  tags = {
  Resource = "EC2"
  }
}

resource "aws_vpc_security_group_egress_rule" "ec2_egress_rule" {
  description = "Allow outbound traffic from EC2 to the internet"
  security_group_id = aws_security_group.ec2.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
  tags = {
    Resource = "EC2"
  }
}