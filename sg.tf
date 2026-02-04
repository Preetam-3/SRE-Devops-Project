resource "aws_security_group" "projectvpc-1" {
  name = "allow_tls"
  description = "Allow TlS inbound traffic"
  vpc_id = "vpc-04c3f65c892bc1a79"

  ingress {
    description = "TLS from VPC"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
      Name = "ssh-project Vpc-1"
}
}
