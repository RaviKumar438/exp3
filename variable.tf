variables.tf
This file will define the variables used in the main.tf file.

hcl
Copy code
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "domain_name" {
  description = "The domain name for Route 53"
  type        = string
  default     = "example.com"
}

variable "key_name" {
  description = "The key name for EC2 instances"
  type        = string
}