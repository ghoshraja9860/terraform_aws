resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
 

  tags = {
    Name = "terraformVPC"
  }
}
# create igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "Terraformigw"
  }
}

#create public  subnet
resource "aws_subnet" "sub2" {
  vpc_id          = aws_vpc.myvpc.id
  cidr_block      = "10.0.1.0/24"
  availability_zone = "ap-south-1a" 
  map_public_ip_on_launch = true
}
#create route table
resource "aws_route_table" "RTA" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
 }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RTA.id
}
 
 #create security group
 resource "aws_security_group" "mysgw" {
  name        = "web"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "HTTP FROM VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
   ingress {
    description      = "SSH"
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
    Name = "aNEWSG"
  }
}
resource "aws_instance" "server1" {
      ami = "ami-03f4878755434977f"
      instance_type = "t2.micro"
      vpc_security_group_ids = [aws_security_group.mysgw.id]
      subnet_id = aws_subnet.sub2.id
      }

   

