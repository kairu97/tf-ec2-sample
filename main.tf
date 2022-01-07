provider "aws" {
  region = "ap-southeast-1"
}

### AMI/OS ###
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"] # Canonical
}

### EC2 ### 
resource "aws_key_pair" "mykey" {
  key_name = "mykey"
  public_key = file("mykey.pub")
}

resource "aws_instance" "ec2_instance" {
  user_data = file("install_site.sh")
  ami = data.aws_ami.amazon_linux.id
  key_name = aws_key_pair.mykey.key_name
  associate_public_ip_address = true
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ports.id]

  tags = {
    Name = "new-ec2-instance-tf"
  }
}

### Security Group ###
resource "aws_security_group" "allow_ports" {
  name        = "allow_ports"
  description = "Allow ports 80, 443, 22"

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ports"
  }
}