data "aws_ami" "project-ubuntu-ami-1" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.10.20260120.4-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}

resource "aws_instance" "projectect2-1" {
  ami           = data.aws_ami.project-ubuntu-ami-1.id
  instance_type = "t2.micro"
  key_name = "mykeypair"
  subnet_id = "subnet-02d57621c1b67d18b"
  security_groups = ["${aws_security_group.projectvpc-1.id}"]
  iam_instance_profile = aws_iam_instance_profile.projectprofile1.id

  tags = {
    Name = "HelloWorld"
  }
}


