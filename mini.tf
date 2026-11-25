provider "aws" {
    region = "eu-west-2"
}


# Create a VPC - 10.81.0.0/16

resource "aws_vpc" "prod-vpc" {
   cidr_block = "10.81.0.0/16"
   instance_tenancy = "default"

    tags = {
        Name = "prod-vpc"
    }
}

# Create a internet gateway and attach it to the VPC

resource "aws_internet_gateway" "prod-igw" {
    vpc_id = aws_vpc.prod-vpc.id

    tags = {
        Name = "prod-igw"
    }
}

# Create a route table

resource "aws_route_table" "prod-rt" {
    vpc_id = aws_vpc.prod-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.prod-igw.id
    }

    tags = {
        Name = "prod-rt"
    }           
}   

# Create a subnet
resource "aws_subnet" "prod-subnet" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.81.1.0/24"

    tags = {
        Name = "prod-subnet"
    }
}

# Associate Subnet with Route Table
resource "aws_route_table_association" "prod-rta" {
    subnet_id = aws_subnet.prod-subnet.id
    route_table_id = aws_route_table.prod-rt.id
}

# Create a security group to allow port 22 and 80, 443 or all ports

resource "aws_security_group" "prod-sg" {
    name = "prod-sg"
    description = "Allow SSH, HTTP and HTTPS"
    vpc_id = aws_vpc.prod-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "prod-sg"
    }   
}

# Create a network interface and attach it to the subnet and security group

resource "aws_network_interface" "prod-eni" {
    subnet_id = aws_subnet.prod-subnet.id
    private_ips = ["10.81.1.10"]
    security_groups = [aws_security_group.prod-sg.id]

    tags = {
        Name = "prod-eni"
    }
}

# assign an elastic IP to the network interface 

resource "aws_eip" "prod-eip" {
   
    network_interface = aws_network_interface.prod-eni.id
    associate_with_private_ip = "10.81.1.10"

    tags = {
        Name = "prod-eip"
    }
}

# create an EC2 instance and attach the network interface to it
resource "aws_instance" "prod-server" {
    ami = "ami-05855828e1e2be542"
    instance_type = "t3.micro"
    key_name = "Ansiblekey"

    user_data = file("${path.module}/serverscript.sh")

    primary_network_interface {
        network_interface_id = aws_network_interface.prod-eni.id
    }

    tags = {
        Name = "prod-server"
    }
}