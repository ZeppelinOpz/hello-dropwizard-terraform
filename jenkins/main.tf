provider "aws" {  
  region  = "us-east-1"
  profile = "your-aws-profile"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private-key to key/xxx.pem
resource "local_file" "ssh_key_private" {
  content  = "${tls_private_key.ssh.private_key_pem}"
  filename = "${path.module}/keys/sandbox-ops.pem"
  provisioner "local-exec" {
    command = "chmod 600 ${path.module}/keys/sandbox-ops.pem"
  }
}

# Create key-pair at amazon with given public-key & key-name
resource "aws_key_pair" "generated_key" {
  key_name   = "ops"
  public_key = "${tls_private_key.ssh.public_key_openssh}"
}

variable "max_availability_zones" {
  default = "3"
}

data "aws_availability_zones" "available" {}

module "jenkins" {
  source      = "./modules/terraform-aws-jenkins"
  namespace   = "cp"
  name        = "jenkins"
  stage       = "dev"
  description = "Jenkins server as Docker container running on Elastic Beanstalk"

  master_instance_type         = "t2.large"
  aws_account_id               = ""
  aws_region                   = "us-east-1"
  availability_zones           = ["${slice(data.aws_availability_zones.available.names, 0, var.max_availability_zones)}"]
  vpc_id                       = "vpc-id"
  zone_id                      = "zone-id"
  public_subnets               = ["public_subnet_1","public_subnet_2","public_subnet_3"]
  private_subnets              = ["private_subnet_1","private_subnet_2","private_subnet_3"]
  loadbalancer_certificate_arn = ""
  ssh_key_pair                 = "${aws_key_pair.generated_key.key_name}"

  root_volume_size = "200"
  root_volume_type = "standard"

  github_oauth_token  = "c5f6813fb295e157ad107cbe0b24ab64d03a9038"
  github_organization = "ZeppelinOpz"
  github_repo_name    = "jenkins"
  github_branch       = "master"

  datapipeline_config = {
    instance_type = "t2.medium"
    email         = "rtinoco@zeppelinops.com"
    period        = "12 hours"
    timeout       = "60 Minutes"
  }

  env_vars = {
    JENKINS_USER          = "admin"
    JENKINS_PASS          = "start12!"
    JENKINS_NUM_EXECUTORS = 4
  }

  tags = {
    BusinessUnit = "Build"
    Department   = "Ops"
  }
}
