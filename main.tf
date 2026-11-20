provider "aws" {
  region = "eu-west-2"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "server1" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  count         = 2

  tags = {
    Name = "terraformserver"
  }
}