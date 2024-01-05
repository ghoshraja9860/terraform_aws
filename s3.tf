#main.tf1
provider "aws" {
  region="us-east-1"
} # end provider
# create vpc ##

variable "cidr" {
  default = "10.0.0.0/16"
}

# first create cidr block
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
# use key pair
resource "aws_key_pair" "newkey" {
  key_name   = "terraform-demo"  
  public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your public key file
}
resource "" "mypvc" {
  cidr_block = var.cidr
}
resource "aws_subnet" "sub" {
  vpc_id     = aws_vpc.mypvc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

#create igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mypvc.id
}
#create router table
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.mypvc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
#associate RT with subnet
resource "aws_route_table_association" "RTA" {
  subnet_id      = aws_subnet.sub.id
  route_table_id = aws_route_table.RT.id
}

#EXPOSING instance on pub ip (create SG)
resource "aws_security_group" "sg1" {
  name        = "websg"
  
  vpc_id      = aws_vpc.mypvc.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 22
    to_port          = 22
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
    }

  tags = {
    Name = "WEBSG1"
  }
}
resource "aws_instance" "server1" {
  ami= "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  private_kry = "file("~/.ssh/id_rsa.pub")"
}


