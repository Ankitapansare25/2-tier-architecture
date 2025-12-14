terraform {
  backend "s3" {
    bucket = "terraformb11"
    key = "terraform.tfstate"
    region = "ap-south-1"
  }
}
provider "aws" {
    region = var.region
  
}
 # Create vpc
resource "aws_vpc" "myvpc" {
    cidr_block = var.vpc_block
    tags = {
      Name = "${var.project_name}-VPC"
    }
}
# create a private subnet

    resource "aws_subnet" "private_subnet" {
    vpc_id =aws_vpc.myvpc.id
    cidr_block = var.private_cidr
    availability_zone = var.az1
    tags = {
      Name = "${var.project_name}-private-subnet"
    }
    }

# create a public subnet
resource "aws_subnet" "public_subnet" {
    vpc_id =aws_vpc.myvpc.id
    cidr_block = var.public_cidr
    availability_zone = var.az2
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.project_name}-public-subnet"
    }
    }
    
    # create a IGW 
    resource "aws_internet_gateway" "my-igw" {
        vpc_id = aws_vpc.myvpc.id
        tags = {
          Name = "${var.project_name}-IGW"
        }
      
    }
    # create a default route table
    resource "aws_default_route_table" "main-RT" {
        default_route_table_id = aws_vpc.myvpc.default_route_table_id
      tags = {
        Name = "${var.project_name}-main-RT"
      }
    }
    # add a route in main route table
    resource "aws_route" "aws-route" {
        route_table_id = aws_default_route_table.main-RT.id
        destination_cidr_block = var.igw_cidr
        gateway_id = aws_internet_gateway.my-igw.id
      
    }


    # create a sg
    resource "aws_security_group" "my-sg" {
      vpc_id = aws_vpc.myvpc.id
        name = "${var.project_name}-sg"
        description = "allow ssh, http, mysql traffic"

        ingress {
            protocol = "tcp"
            to_port = 22
            from_port = 22
            cidr_blocks = ["0.0.0.0/0"]
        }

        ingress  {
            protocol = "tcp"
            to_port = 80
            from_port = 80
            cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
            protocol = "tcp"
            to_port = 3306
            from_port = 3306
            cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
            protocol = -1
            to_port = 0
            from_port = 0
            cidr_blocks= ["0.0.0.0/0"]
        }
        depends_on = [ aws_vpc.myvpc ]
        }
        
        # create a public server
        resource "aws_instance" "public-server" {
            subnet_id = aws_subnet.public_subnet.id
            ami = var.ami
            instance_type = var.instance_type
            key_name = var.key
            vpc_security_group_ids = [aws_security_group.my-sg.id]
            tags = {
              Name = "${var.project_name}-app-server"
            }
          depends_on = [ aws_security_group.my-sg ]

        }
        # create a private server
        resource "aws_instance" "private-server" {
            subnet_id = aws_subnet.private_subnet.id
            ami = var.ami
            instance_type = var.instance_type
            key_name = var.key
            vpc_security_group_ids = [aws_security_group.my-sg.id]
            tags = {
              Name = "${var.project_name}-db-server"
            }
          depends_on = [ aws_security_group.my-sg ]
          
        }
        

      
    