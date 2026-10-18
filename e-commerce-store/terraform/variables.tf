variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Prefix used in resource names and tags"
  type        = string
  default     = "shop"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root disk size in GB"
  type        = number
  default     = 20
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH. Leave empty to use only SSM Session Manager."
  type        = string
  default     = ""
}

variable "ssh_cidr_blocks" {
  description = "CIDR ranges allowed to SSH (port 22), e.g. [\"203.0.113.10/32\"]. Empty = SSH closed."
  type        = list(string)
  default     = []
}

variable "monitoring_cidr_blocks" {
  description = "CIDR ranges allowed to open Grafana (3000) and Prometheus (9090). Empty = closed."
  type        = list(string)
  default     = []
}

variable "alert_email" {
  description = "Email address for CloudWatch alarm notifications. Empty = alarms exist but send no email."
  type        = string
  default     = ""
}
