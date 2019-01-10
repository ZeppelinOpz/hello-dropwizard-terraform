# How to Create Sample Demo Environment

Goto example directory.

Upadate the variables inside main.tf

- your_aws_profile
- your_vpc_id
- your_rout53_hosted_zone_id
- your_public_subnet_* (1,2,3) 
- your_private_subnet_* (1,2,3)


```bash
module "elasticbeanstalk-demo" {
  source      = "../"
  namespace   = "zeppelinops"
  name        = "app"
  stage       = "demo"
  description = "Demo application as Multi Docker container running on Elastic Beanstalk"

  master_instance_type         = "t2.small"
  aws_account_id               = ""
  aws_region                   = "us-east-1"
  availability_zones           = ["${slice(data.aws_availability_zones.available.names, 0, var.max_availability_zones)}"]
  vpc_id                       = "your_vpc_id"
  zone_id                      = "your_rout53_hosted_zone_id"
  public_subnets               = ["your_public_subnet_1","your_public_subnet_2","your_public_subnet_3"]
  private_subnets              = ["your_private_subnet_1","your_private_subnet_2","your_private_subnet_2"]
  loadbalancer_certificate_arn = ""
  ssh_key_pair                 = "${aws_key_pair.generated_key.key_name}"
  solution_stack_name          = "64bit Amazon Linux 2018.03 v2.11.6 running Multi-container Docker 18.06.1-ce (Generic)"

  env_vars = {
  }

  tags = {
    BusinessUnit = "Demo"
    Department   = "Ops"
  }
}

```


## Run :

```bash
terraform init
terraform apply
```
