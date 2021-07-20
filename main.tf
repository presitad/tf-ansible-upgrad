provider "aws" {
  region = "us-east-1"
}

resource "tls_private_key" "task1_p_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "task1-key" {
  key_name   = "task1-key"
  public_key = tls_private_key.task1_p_key.public_key_openssh
}

resource "local_file" "private_key" {
  depends_on = [
    tls_private_key.task1_p_key,
  ]
  content  = tls_private_key.task1_p_key.private_key_pem
  filename = "task1-key.pem"
}

resource "aws_vpc" "My_VPC" {
  cidr_block           = "10.20.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "My VPC"
  }
}

resource "aws_subnet" "My_VPC_Subnet" {

  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "My VPC public Subnet1"
  }
}

resource "aws_subnet" "My_VPC_Subnet2" {

  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = "10.20.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "My VPC private Subnet2"
  }
}

resource "aws_subnet" "My_VPC_Subnet3" {
  vpc_id            = aws_vpc.My_VPC.id
  cidr_block        = "10.20.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "My VPC public Subnet3"
  }
}

resource "aws_subnet" "My_VPC_Subnet4" {
  vpc_id            = aws_vpc.My_VPC.id
  cidr_block        = "10.20.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "My VPC private Subnet4"
  }
}

resource "aws_internet_gateway" "My_VPC_GW" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "My VPC Internet Gateway"
  }
}

resource "aws_route_table" "My_VPC_route_table" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "My VPC Route Table"
  }
}

resource "aws_route" "My_VPC_internet_access" {
  route_table_id         = aws_route_table.My_VPC_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.My_VPC_GW.id
}

resource "aws_route_table_association" "My_VPC_association" {
  subnet_id      = aws_subnet.My_VPC_Subnet.id
  route_table_id = aws_route_table.My_VPC_route_table.id
}

resource "aws_security_group" "bositon_host_sg" {
  depends_on = [aws_subnet.My_VPC_Subnet]
  name       = "bositon_host_sg"
  vpc_id     = aws_vpc.My_VPC.id

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

  tags = {
    Name = "bositon_host_sg"
  }
}


resource "aws_security_group" "allow_web_sg" {
  name   = "allow_web_sg"
  vpc_id = aws_vpc.My_VPC.id

  ingress {

    from_port   = 3306
    to_port     = 3306
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

resource "aws_security_group" "allow_http" {
  name   = "allow_http"
  vpc_id = aws_vpc.My_VPC.id
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
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_http"
  }
}

resource "aws_security_group" "only_ssh_sql_bositon" {
  depends_on  = [aws_subnet.My_VPC_Subnet]
  name        = "only_ssh_sql_bositon"
  description = "allow ssh bositon inbound traffic"
  vpc_id      = aws_vpc.My_VPC.id
  ingress {
    description     = "Only ssh_sql_bositon in public subnet"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bositon_host_sg.id]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "only_ssh_sql_bositon"
  }
}
resource "aws_eip" "abhi_ip" {
  vpc              = true
  public_ipv4_pool = "amazon"
}


resource "aws_nat_gateway" "myngw" {
  depends_on    = [aws_eip.abhi_ip]
  allocation_id = aws_eip.abhi_ip.id
  subnet_id     = aws_subnet.My_VPC_Subnet.id
  tags = {
    Name = "myngw"
  }
}

// Route table for SNAT in private subnet

resource "aws_route_table" "private_subnet_route_table" {
  depends_on = [aws_nat_gateway.myngw]
  vpc_id     = aws_vpc.My_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myngw.id
  }

  tags = {
    Name = "private_subnet_route_table"
  }
}

resource "aws_route_table_association" "private_subnet_route_table_association" {
  depends_on     = [aws_route_table.private_subnet_route_table]
  subnet_id      = aws_subnet.My_VPC_Subnet2.id
  route_table_id = aws_route_table.private_subnet_route_table.id
}

resource "aws_instance" "BASTION" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.My_VPC_Subnet.id
  vpc_security_group_ids = [aws_security_group.bositon_host_sg.id]
  key_name               = "task1-key"

  tags = {
    Name = "bastionhost"
  }
}

resource "aws_instance" "jenkins" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.My_VPC_Subnet2.id
  vpc_security_group_ids = [aws_security_group.allow_web_sg.id, aws_security_group.only_ssh_sql_bositon.id]
  key_name               = "task1-key"

  tags = {
    Name = "jenkins"
  }
}

resource "aws_instance" "app" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.My_VPC_Subnet.id
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  key_name               = "task1-key"


  tags = {
    Name = "app"
  }
}

# resource "aws_lb" "alb" {
#   name               = "alb"
#   internal           = false
#   load_balancer_type = "application"
#   subnets            = aws_subnet.public_subnet.*.id

#   tags = {
#     Name = "Load Balancer"
#   }
# }