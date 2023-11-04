
cluster_name            = "tooling-app-eks"
iac_environment_tag     = "development"
env_name                = "development"
name_prefix             = "krusha-io-eks"
main_network_block      = "10.0.0.0/16"
subnet_prefix_extension = 4
zone_offset             = 8
# serviceAccount.create   = false 
# serviceAccount.name = aws-load-balancer-controller


# Ensure that these users already exist in AWS IAM. Another approach is that you can introduce an iam.tf file to manage users separately, get the data source and interpolate their ARN.
admin_users                    = ["kuby", "project24"]
developer_users                = ["kuby", "project24"]
asg_instance_types                       = [{ instance_type = "t3.medium" }, { instance_type = "t2.small" }, ]
autoscaling_minimum_size_by_az           = 1
autoscaling_maximum_size_by_az           = 5
autoscaling_average_cpu                  = 60
