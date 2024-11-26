terraform.tfvars
This file will provide the values for the variables defined in variables.tf.

hcl
Copy code
vpc_cidr_block = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

private_subnet_cidrs = [
  "10.0.4.0/24",
  "10.0.5.0/24",
  "10.0.6.0/24"
]

availability_zones = [
  "us-west-2a",
  "us-west-2b",
  "us-west-2c"
]

cluster_name = "my-eks-cluster"

domain_name = "example.com"

key_name = "your-key-pair-name"  # Replace with your actual key pair name
Instructions
Save these files in your Terraform directory.
Initialize Terraform:
bash
Copy code
terraform init
Review the plan:
bash
Copy code
terraform plan
Apply the configuration:
bash
Copy code
terraform apply
Make sure you adjust the AMI IDs, domain names, and other parameters as necessary. This setup assumes you have a basic understanding of Terraform and AWS EKS. You may also need to install the Terraform AWS EKS module if it's not already included in your environment