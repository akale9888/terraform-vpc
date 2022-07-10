            ##--VPC--##

resource "aws_vpc" "ap-vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  tags = {
     name = "vpc${var.vpc-tf}-pub1"
  }
 
}

         #--subnets--##

resource "aws_subnet" "public" {
  
  vpc_id                  = aws_vpc.ap-vpc.id
  cidr_block              = var.public_cidr_block
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true
  tags = {
     name = "pub${var.vpc-tf}"
  }

}

resource "aws_subnet" "private" {
  
  vpc_id            = aws_vpc.ap-vpc.id
  cidr_block        = var.private_cidr_block
  availability_zone = var.availability_zones[1]
  tags = {
     name = "prv${var.vpc-tf}"
  }
}

##--IGW--##
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ap-vpc.id
tags = {
     name = "igw${var.vpc-tf}"
  }
}
## ROUTE TABLE ##
  resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ap-vpc.id
  route {
  cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id
  
}
 tags = {
     name = "rtpbc${var.vpc-tf}"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.ap-vpc.id
  route  = []
 tags = {
     name = "rtprv${var.vpc-tf}"
  }
}
## ---  SUBNET ASSOCIATION---##
resource "aws_route_table_association" "public" {
   subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
 
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
  depends_on     = [aws_nat_gateway.nat]
}
 ##----EIP----##

resource "aws_eip" "eip_nat" {
  vpc  = true
  tags = {
     name = "rtprv${var.vpc-tf}"
  }
}

## ---NAT----##

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
     name = "rtprv${var.vpc-tf}"
  }
}

###NACL##########

resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.ap-vpc.id
  subnet_ids = [ aws_subnet.public.id ]
   
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
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
    Name = "nacl-${var.vpc-tf}"
  }
}

resource "aws_instance" "foo" {
  ami           = "ami-0cff7528ff583bf9a" # us-east-2
  instance_type = "t2.micro"
  key_name = aws_key_pair.generated_key.id
  subnet_id = aws_subnet.public.id
 

  tags = {
    Name = "instance11"
  }
}

# Assigning key type

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Creating private key

resource "aws_key_pair" "generated_key" {
  key_name   = "keypair"
  public_key = tls_private_key.example.public_key_openssh
}

#Creating sec grp

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.ap-vpc.id
  

  ingress {
    description      = "TLS from VPC"
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
    ipv6_cidr_blocks = ["::/0"]
  }

}