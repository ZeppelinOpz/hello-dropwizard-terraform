provider "aws" {  
  region  = "us-east-1"
  profile = "your-aws-profile"
}

# Deploy vpc 
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eb-vpc"
  cidr = "10.100.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.100.0.0/19", "10.100.32.0/19", "10.100.64.0/19"]
  public_subnets  = ["10.100.128.0/20", "10.100.144.0/20", "10.100.160.0/20"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform = "true"    
  }
}