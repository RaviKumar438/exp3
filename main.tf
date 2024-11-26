main.tf
This file will include the main configuration for the EKS cluster, VPC, subnets, security groups, and Route 53.

hcl
Copy code
provider "aws" {
  region = "us-west-2"  # Change to your desired AWS region
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Create public subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[2]
  availability_zone = var.availability_zones[2]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-3"
  }
}

# Create private subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[2]
  availability_zone = var.availability_zones[2]
  tags = {
    Name = "private-subnet-3"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Create a route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate route table with public subnets
resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_association_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public.id
}

# Create a security group
resource "aws_security_group" "eks" {
  vpc_id = aws_vpc.main.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-security-group"
  }
}

# Create IAM roles and policies for EKS
resource "aws_iam_role" "eks_master" {
  name = "eks-master-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_master_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role     = aws_iam_role.eks_master.name
}

resource "aws_iam_role" "eks_node" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role     = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_policy_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role     = aws_iam_role.eks_node.name
}

resource "aws_iam_instance_profile" "eks_node" {
  name = "eks-node-instance-profile"
  role = aws_iam_role.eks_node.name
}

# EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.21"
  subnets         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]
  vpc_id           = aws_vpc.main.id
  node_groups = {
    eks_nodes = {
      desired_capacity = 3
      max_capacity     = 5
      min_capacity     = 1
      instance_type    = "t3.medium"
      key_name          = var.key_name
      iam_role_arn     = aws_iam_role.eks_node.arn
    }
  }
}

# Route 53 Hosted Zone
resource "aws_route53_zone" "example" {
  name = var.domain_name
}

# Route 53 DNS Record
resource "aws_route53_record" "example" {
  zone_id = aws_route53_zone.example.id
  name    = "eks.${var.domain_name}"
  type    = "A"
  ttl     = 60
  records = [module.eks.cluster_endpoint]
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

