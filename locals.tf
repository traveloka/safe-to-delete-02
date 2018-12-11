locals {
  service_name   = "axtresv"
  product_domain = "axt"

  lb_cluster_role        = "lbint"
  lb_cluster_name        = "${local.service_name}-${local.lb_cluster_role}"
  lb_route53_record_name = "${var.lb_route53_record_name == "" ? local.service_name : var.lb_route53_record_name}"

  lb_tg_health_check = {
    port = "${local.app_port}"
  }

  app_cluster_role = "app"
  app_cluster_name = "${local.service_name}-${local.app_cluster_role}"
  app_port         = 29300

  lc_instance_type              = "t2.medium"
  asg_min_capacity              = 1
  asg_max_capacity              = 2
  asg_health_check_type         = "ELB"
  asg_wait_for_capacity_timeout = "7m"
  asg_policy_cpu_target_value   = 40.0

  postgres_port = 5432
  secure_port   = 443
  nlb_port      = 80
}
