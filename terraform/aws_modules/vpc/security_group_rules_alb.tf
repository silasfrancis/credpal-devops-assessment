resource "aws_vpc_security_group_ingress_rule" "alb_ingress_http" {
  security_group_id = aws_security_group.alb.id
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  depends_on = [ aws_security_group.alb ]
  tags = {
    Resource = "ALB"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_ingress_https" {
  security_group_id = aws_security_group.alb.id
  from_port = 443
  to_port = 443
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
    tags = {
    Resource = "ALB"
  }
  depends_on = [ aws_security_group.alb ]
}

resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.alb.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
    tags = {
    Resource = "ALB"
  }
  depends_on = [ aws_security_group.alb ]
}