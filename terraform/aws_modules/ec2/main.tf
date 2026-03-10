resource "aws_instance" "ec2_instance" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = var.private_subnet_id
  vpc_security_group_ids  = var.ec2_security_group_id
  iam_instance_profile = var.iam_instance_profile 
  associate_public_ip_address = false
  tags = {
    Name = "${var.tags}-instance"
  }
}