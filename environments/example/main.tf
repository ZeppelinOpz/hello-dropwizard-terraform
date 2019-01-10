provider "aws" {
  region = "us-east-1"
  profile = "your-aws-profile"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private-key to key/xxx.pem
resource "local_file" "ssh_key_private" {
  content  = "${tls_private_key.ssh.private_key_pem}"
  filename = "${path.module}/keys/sandbox-demo.pem"
  provisioner "local-exec" {
    command = "chmod 600 ${path.module}/keys/sandbox-demo.pem"
  }
}

# Create key-pair at amazon with given public-key & key-name
resource "aws_key_pair" "generated_key" {
  key_name   = "demo"
  public_key = "${tls_private_key.ssh.public_key_openssh}"
}


variable "max_availability_zones" {
  default = "3"
}

data "aws_availability_zones" "available" {}

module "elasticbeanstalk-demo" {
  source      = "../"
  namespace   = "ops"
  name        = "hello-dropwizard"
  stage       = "app"
  description = "Demo application as Multi Docker container running on Elastic Beanstalk"

  master_instance_type         = "t2.small"
  aws_account_id               = ""
  aws_region                   = "us-east-1"
  availability_zones           = ["${slice(data.aws_availability_zones.available.names, 0, var.max_availability_zones)}"]
  vpc_id                       = "vpc-id"
  zone_id                      = "zone-id"
  public_subnets               = ["public_subnet_1","public_subnet_2","public_subnet_3"]
  private_subnets              = ["private_subnet_1","private_subnet_2","private_subnet_3"]
  loadbalancer_certificate_arn = ""
  ssh_key_pair                 = "${aws_key_pair.generated_key.key_name}"
  solution_stack_name          = "64bit Amazon Linux 2018.03 v2.11.6 running Multi-container Docker 18.06.1-ce (Generic)"

  env_vars = {
  }

  tags = {
    BusinessUnit = "Demo"
    Department   = "Ops"
    Environment  = "Development"
  }
}
