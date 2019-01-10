
module "elastic_beanstalk_application" {
  source      = "./modules/application"
  namespace   = "${var.namespace}"
  name        = "${var.name}"
  stage       = "${var.stage}"
  description = "${var.description}"
  delimiter   = "${var.delimiter}"
  attributes  = ["${compact(concat(var.attributes, list("")))}"]
  tags        = "${var.tags}"  
}

module "elastic_beanstalk_environment_development" {
  source        =  "./modules/environment"
  namespace     = "${var.namespace}"
  name          = "${var.name}"
  stage         = "${var.stage}"
  zone_id       = "${var.zone_id}"
  app           = "${module.elastic_beanstalk_application.app_name}"
  instance_type = "${var.master_instance_type}"
  solution_stack_name = "${var.solution_stack_name}"


  autoscale_min = 1
  autoscale_max = 1

  updating_min_in_service = 0
  updating_max_batch = 1

  healthcheck_url              = "${var.healthcheck_url}"
  loadbalancer_type            = "${var.loadbalancer_type}"
  loadbalancer_certificate_arn = "${var.loadbalancer_certificate_arn}"
  vpc_id                       = "${var.vpc_id}"
  public_subnets               = "${var.public_subnets}"
  private_subnets              = "${var.private_subnets}"
  security_groups              = "${var.security_groups}"
  keypair                      = "${var.ssh_key_pair}"
  solution_stack_name          = "${var.solution_stack_name}"
  env_default_key              = "${var.env_default_key}"
  env_default_value            = "${var.env_default_value}"
  rolling_update_type          = "Immutable"    
  
  env_vars = "${
      merge(
        map(
        ), var.env_vars
      )
    }"

  delimiter  = "${var.delimiter}"
  attributes = ["${compact(concat(var.attributes, list("development")))}"]
  tags       = "${var.tags}"
}