## This block will create our Vpc in ap-south-1
resource "aws_vpc" "vpc-02" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "${var.batch_name}-vpc-02"
  }
}

## This block will create internet gatway for the vitual private cloud
resource "aws_internet_gateway" "igw-02" {
  vpc_id = aws_vpc.vpc-02.id

  tags = {
    Name = "${var.batch_name}-igw-02"
  }
}

## This following 4 block will create both public and private subnets. 2 Private - 2 Public
resource "aws_subnet" "pub_subnet-01" { ## public Subnnet
  vpc_id                  = aws_vpc.vpc-02.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Pub-subnet-1a"
  }
}


resource "aws_subnet" "pub_subnet-02" { ## Public Subnet 
  vpc_id                  = aws_vpc.vpc-02.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Pub-subnet-2b"
  }
}

resource "aws_subnet" "pvt_subnet-03" { ## Private Subnet 
  vpc_id            = aws_vpc.vpc-02.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Pvt-subnet-3a"
  }
}

## Creating Private Subnets

resource "aws_subnet" "pvt_subnet-04" { ## PrivateSubnet 
  vpc_id            = aws_vpc.vpc-02.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Pvt-subnet-4b"
  }
}



## Elastic IP for NAT Gateway
resource "aws_eip" "my_eip_02" {
  domain = "vpc"

}
## Private Route table
resource "aws_nat_gateway" "ngw-02" {
  allocation_id = aws_eip.my_eip_02.id
  subnet_id     = aws_subnet.pvt_subnet-03.id

  tags = {
    Name = "${var.batch_name}-ngw-02"
  }

  depends_on = [aws_eip.my_eip_02]
}

## This will create Route table for the Public Subnet
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc-02.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-02.id
  }

  tags = {
    Name = "${var.batch_name}-public-rt"
  }
}
# Private Route Table
################################
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc-02.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw-02.id
  }

  tags = {
    Name = "${var.batch_name}-private-rt"
  }
}


## This block will crete NACL for us. We are going to make NACL for public subnet

resource "aws_network_acl" "nacl-02" {
  vpc_id = aws_vpc.vpc-02.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/00"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "nacl-02"
  }
}

## Public Route Table Associations
resource "aws_route_table_association" "public_assoc" {
  route_table_id = aws_route_table.public-rt.id
  subnet_id      = aws_subnet.pub_subnet-01.id
}
resource "aws_route_table_association" "public_assoc1" {
  route_table_id = aws_route_table.public-rt.id
  subnet_id      = aws_subnet.pub_subnet-02.id
}
## Private Route Table Associations
resource "aws_route_table_association" "private_assoc" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.pvt_subnet-03.id
}
resource "aws_route_table_association" "private_assoc2" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.pvt_subnet-04.id
}



# Security Group for EC2
resource "aws_security_group" "my_sg" {
  name        = "allow_web_ssh"
  description = "Allow Port 80 and 22"
  vpc_id      = aws_vpc.vpc-02.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}



## This will create a AmazonLinux instance
data "aws_ami" "my_ami_Amazon_linux" {
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

resource "aws_instance" "example" {
  ami             = data.aws_ami.my_ami_Amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.my_sg.id}"]
  subnet_id       = aws_subnet.pub_subnet-01.id
  key_name        = var.key_name

  tags = {
    Name = "HelloWorld"
  }
}



