#######
# ALB #
#######

module "lb_sg_name" {
  source = "github.com/traveloka/terraform-aws-resource-naming?ref=v0.7.1"

  name_prefix   = "${local.lb_cluster_name}"
  resource_type = "security_group"
}

resource "aws_security_group" "lb_sg" {
  name        = "${module.lb_sg_name.name}"
  description = "Load balancer security group for ${local.lb_cluster_name}"

  vpc_id = "${var.vpc_id}"

  tags = {
    Name          = "${module.lb_sg_name.name}"
    Service       = "${local.service_name}"
    ProductDomain = "${local.product_domain}"
    Environment   = "${var.environment}"
    Description   = "Load balancer security group for ${local.lb_cluster_name}"
    ManagedBy     = "Terraform"
  }
}

resource "aws_security_group_rule" "allow_egress_from_axtresv_lb_to_axtresv_app" {
  type      = "egress"
  from_port = "${local.app_port}"
  to_port   = "${local.app_port}"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.app_sg.id}"
  security_group_id        = "${aws_security_group.lb_sg.id}"
}

resource "aws_security_group_rule" "allow_ingress_from_axtresv_lb_to_axtresv_app" {
  type      = "ingress"
  from_port = "${local.app_port}"
  to_port   = "${local.app_port}"
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.lb_sg.id}"
  security_group_id        = "${aws_security_group.app_sg.id}"
}

resource "aws_security_group_rule" "allow_ingress_from_axtresv_lb_to_axtresv_app" {
  type      = "ingress"
  from_port = "${local.secure_port}"
  to_port   = "${local.secure_port}"
  protocol  = "tcp"

  source_security_group_id  = "${var.axtresv_app_security_group_id}"
  security_group_id         = "${aws_security_group.lb_sg.id}"
}

resource "aws_security_group_rule" "allow_ingress_from_axtresv_lb_to_hdemand_app" {
  type      = "ingress"
  from_port = "${local.secure_port}"
  to_port   = "${local.secure_port}"
  protocol  = "tcp"

  source_security_group_id  = "${var.hdemand_app_security_group_id}"
  security_group_id         = "${aws_security_group.lb_sg.id}"
}

resource "aws_security_group_rule" "allow_ingress_from_axtresv_lb_to_axtcm_app" {
  type      = "ingress"
  from_port = "${local.secure_port}"
  to_port   = "${local.secure_port}"
  protocol  = "tcp"

  source_security_group_id  = "${var.axtcm_app_security_group_id}"  
  security_group_id         = "${aws_security_group.lb_sg.id}"
}

resource "aws_security_group_rule" "allow_ingress_from_axtresv_lb_to_hnet_app" {
  type      = "ingress"
  from_port = "${local.secure_port}"
  to_port   = "${local.secure_port}"
  protocol  = "tcp"

  source_security_group_id  = "${var.hnet_app_security_group_id}"
  security_group_id         = "${aws_security_group.lb_sg.id}" 
}

resource "aws_security_group_rule" "allow_ingress_from_axtresv_lb_to_entcurr_lb" {
  type      = "ingress"
  from_port = "${local.secure_port}"
  to_port   = "${local.secure_port}"
  protocol  = "tcp"

  source_security_group_id  = "${aws_security_group.lb_sg.id}"  
  security_group_id         = "${var.entcurr_lb_security_group_id}"  
}

resource "aws_security_group_rule" "allow_ingress_from_axtresv_lb_to_hnet_mongod" {
  type      = "ingress"
  from_port = "${local.secure_port}"
  to_port   = "${local.secure_port}"
  protocol  = "tcp"

  source_security_group_id  = "${aws_security_group.lb_sg.id}"  
  security_group_id         = "${var.hnet_mongod_security_group_id}"
}

resource "aws_security_group_rule" "allow_ingress_from_axtresv_lb_to_terafe_lb" {
  type      = "ingress"
  from_port = "${local.secure_port}"
  to_port   = "${local.secure_port}"
  protocol  = "tcp"

  source_security_group_id  = "${aws_security_group.lb_sg.id}"  
  security_group_id         = "${var.terafe_lb_security_group_id}"
}

module "alb" {
  source = "github.com/traveloka/terraform-aws-alb-single-listener?ref=v0.2.1"

  service_name   = "${local.service_name}"
  environment    = "${var.environment}"
  product_domain = "${local.product_domain}"
  description    = "Application Load Balancer for ${local.app_cluster_name}"

  vpc_id                   = "${var.vpc_id}"
  lb_subnet_ids            = "${var.lb_subnet_ids}"
  lb_security_groups       = ["${aws_security_group.lb_sg.id}"]
  listener_certificate_arn = "${var.listener_certificate_arn}"
  lb_logs_s3_bucket_name   = "${var.lb_logs_s3_bucket_name}"
  cluster_role             = "${local.app_cluster_role}"

  tg_port         = "${local.app_port}"
  tg_health_check = "${merge(local.lb_tg_health_check, var.lb_tg_health_check)}"
}

resource "aws_route53_record" "lb" {
  zone_id = "${var.route53_private_zone_id}"
  name    = "${local.lb_route53_record_name}.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = "${lower(module.alb.lb_dns)}"
    zone_id                = "${module.alb.lb_zone_id}"
    evaluate_target_health = false
  }
}

#######
# APP #
#######

module "instance_profile" {
  source = "github.com/traveloka/terraform-aws-iam-role//modules/instance?ref=v0.4.4"

  service_name = "${local.service_name}"
  cluster_role = "${local.app_cluster_role}"
}

resource "aws_iam_role_policy" "this" {
  role   = "${module.instance_profile.role_name}"
  policy = "${data.aws_iam_policy_document.app.json}"
}

resource "aws_iam_role_policy" "session_manager" {
  role   = "${module.instance_profile.role_name}"
  policy = "${data.aws_iam_policy_document.session_manager_policy.json}"
}

module "app_sg_name" {
  source = "github.com/traveloka/terraform-aws-resource-naming?ref=v0.7.1"

  name_prefix   = "${local.app_cluster_name}"
  resource_type = "security_group"
}

resource "aws_security_group" "app_sg" {
  name        = "${module.app_sg_name.name}"
  description = "Application security group for ${local.app_cluster_name}"

  vpc_id = "${var.vpc_id}"

  tags = {
    Name          = "${module.app_sg_name.name}"
    Service       = "${local.service_name}"
    ProductDomain = "${local.product_domain}"
    Environment   = "${var.environment}"
    Description   = "Application security group for ${local.app_cluster_name}"
    ManagedBy     = "Terraform"
  }
}

resource "aws_security_group_rule" "allow_egress_from_axtresv_app_to_all_at_443" {
  type      = "egress"
  from_port = "${local.secure_port}"
  to_port   = "${local.secure_port}"
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.app_sg.id}"
}

resource "aws_security_group_rule" "allow_ingress_from_axtresv_app_to_axtresv_lbint"  {
  type      = "ingress"
  from_port = "${local.secure_port}"
  to_port   = "${local.secure_port}"
  protocol  = "tcp"

  source_security_group_id        = "${aws_security_group.lb_sg.id}"
  security_group_id               = "${aws_security_group.app_sg.id}"
}


module "asg" {
  source = "github.com/traveloka/terraform-aws-autoscaling?ref=v0.1.5"

  service_name   = "${local.service_name}"
  environment    = "${var.environment}"
  product_domain = "${local.product_domain}"
  description    = "Autoscaling Group for ${local.app_cluster_name}"
  application    = "java-7"

  lc_security_groups  = ["${aws_security_group.app_sg.id}"]
  lc_instance_profile = "${module.instance_profile.instance_profile_arn}"
  lc_instance_type    = "${local.lc_instance_type}"
  lc_ami_id           = "${var.lc_ami_id}"
  lc_user_data        = "${var.lc_user_data}"

  asg_min_capacity         = "${local.asg_min_capacity}"
  asg_max_capacity         = "${local.asg_max_capacity}"
  asg_vpc_zone_identifier  = ["${var.asg_vpc_zone_identifier}"]
  asg_lb_target_group_arns = ["${module.alb.tg_arn}"]

  asg_health_check_type         = "${local.asg_health_check_type}"
  asg_wait_for_capacity_timeout = "${local.asg_wait_for_capacity_timeout}"

  asg_tags = [
    {
      key                 = "AmiId"
      value               = "${var.lc_ami_id}"
      propagate_at_launch = true
    }
  ]
}

module "autoscaling_policy_name" {
  source = "github.com/traveloka/terraform-aws-resource-naming?ref=v0.7.1"

  name_prefix   = "${local.app_cluster_name}"
  resource_type = "autoscaling_policy"
}

resource "aws_autoscaling_policy" "app" {
  name                   = "${module.autoscaling_policy_name.name}"
  autoscaling_group_name = "${module.asg.asg_name}"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "${local.asg_policy_cpu_target_value}"
  }
}
