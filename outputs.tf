output "lb_security_group_id" {
  description = "The ID of LB security group"
  value       = "${aws_security_group.lb_sg.id}"
}

output "lb_fqdn" {
  description = "The FQDN pointing to the LB"
  value       = "${aws_route53_record.lb.fqdn}"
}

output "app_instance_profile_arn" {
  description = "The ARN of application instance profile"
  value       = "${module.instance_profile.instance_profile_arn}"
}

output "app_security_group_id" {
  description = "The ID of application security group"
  value       = "${aws_security_group.app_sg.id}"
}
