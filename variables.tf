variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique."
  type        = string
  default = "krusha-terraform-bucket"
}

variable "table_name" {
  description = "The name of the DynamoDB table. Must be unique in this AWS account."
  type        = string
  default = "terraform-locks"
}

variable "aws_region" {
  description = "The name of the aws region"
  type        = string
  default = "eu-west-3"
}

variable "cluster_name" {
type        = string
description = "EKS-krusha-cluster"
}

variable "iac_environment_tag" {
type        = string
description = "AWS tag to indicate environment name of each infrastructure object."
}

variable "name_prefix" {
type        = string
description = "Prefix to be used on each infrastructure object Name created in AWS."
}

variable "main_network_block" {
type        = string
description = "Base CIDR block to be used in our VPC."
}

variable "subnet_prefix_extension" {
type        = number
description = "CIDR block bits extension to calculate CIDR blocks of each subnetwork."
}

variable "zone_offset" {
type        = number
description = "CIDR block bits extension offset to calculate Public subnets, avoiding collisions with Private subnets."
}

variable "admin_users" {
  type        = list(string)
  description = "List of Kubernetes admins."
}

variable "developer_users" {
  type        = list(string)
  description = "List of Kubernetes developers."
}

variable "asg_instance_types" {
  #type        = list(string)
  # type        = number
  description = "List of EC2 instance machine types to be used in EKS."
}

variable "autoscaling_minimum_size_by_az" {
  type        = number
  description = "Minimum number of EC2 instances to autoscale our EKS cluster on each AZ."
}

variable "autoscaling_maximum_size_by_az" {
  type        = number
  description = "Maximum number of EC2 instances to autoscale our EKS cluster on each AZ."
}

variable "autoscaling_average_cpu" {
  type        = number
  description = "Average cpu utilization to autoscale our EKS cluster on each AZ."
}