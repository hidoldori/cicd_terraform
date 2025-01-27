resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "aws_vpc" "kp_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "kp_vpc-${random_integer.random.id}"
  }
}

resource "aws_subnet" "kp_pb_sn" {
  count                   = length(var.pb_cidrs)
  vpc_id                  = aws_vpc.kp_vpc.id
  cidr_block              = var.pb_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = ["ap-northeast-2a", "ap-northeast-2c"][count.index]

  tags = {
    Name = "kp-pb_${count.index + 1}"
  }
}

resource "aws_internet_gateway" "kp_pb_ig" {
  vpc_id = aws_vpc.kp_vpc.id
  tags = {
    Name = "kp_pb_igw"
    Managed_by = "terraform"
  }
}

resource "aws_security_group" "kp_pb_sg" {
  name        = "kp_cd_sg"
  description = "SSH inbound traffic"
  vpc_id      = aws_vpc.kp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ext_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}