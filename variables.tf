variable "environment" {
  type        = "string"
  description = "The environment this stack belongs to"
}

variable "vpc_id" {
  type        = "string"
  description = "The ID of the VPC this stack belongs to"
}

variable "hdemand_app_security_group_id" {
  type        = "string"
  description = "The ID of hdemand_vpce security group"
}

variable "axtresv_app_security_group_id" {
  type        = "string"
  description = "The ID of axtresv_app security group"
}

variable "hnet_app_security_group_id" {
  type        = "string"
  description = "The ID of hnet_app security group"
}

variable "axtcm_app_security_group_id" {
  type        = "string"
  description = "The ID of axtcm_app security group"
}

variable "entcurr_lb_security_group_id" {
  type        = "string"
  description = "The ID of entcurr_lb security group"
}

variable "terafe_lb_security_group_id" {
  type        = "string"
  description = "The ID of terafe_lb security group"
}

variable "hnet_mongod_security_group_id" {
  type        = "string"
  description = "The ID of hnet_mongod security group"
}

variable "lb_subnet_ids" {
  type        = "list"
  description = "The list of subnet ids to attach to the LB"
}

variable "listener_certificate_arn" {
  type        = "string"
  description = "The list of subnet ids to attach to the LB"
}

variable "lb_logs_s3_bucket_name" {
  type        = "string"
  description = "The s3 bucket where the LB access logs will be stored"
}

variable "lb_route53_record_name" {
  type        = "string"
  description = "The name of Route 53 record pointing to the LB. The default is the service name"
  default     = ""
}

variable "lb_tg_health_check" {
  type        = "map"
  default     = {}
  description = "The ALB target group's health check configuration, will be merged over the default on locals.tf"
}

variable "route53_private_zone_id" {
  type        = "string"
  description = "The ID of Route 53 private zone"
}

variable "lc_ami_id" {
  type        = "string"
  description = "The AMI ID to spawn ASG instances from"
}

variable "lc_user_data" {
  type        = "string"
  description = "The user data to be passesd to the launch configuration"
}

variable "asg_vpc_zone_identifier" {
  type        = "list"
  description = "The list of subnet ids to spawn ASG instances to"
}

variable "kms_tvlk_ssm_tvlk_secret_key_arn" {
  type        = "string"
  description = "The ARN of KMS key to decrypt tvlk-secret SSM parameters"
}

variable "session_manager_bucket_arn" {
  type        = "string"
  description = "The ARN of S3 bucket where the session manager output will be stored"
}
