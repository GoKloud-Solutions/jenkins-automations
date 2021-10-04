# data "aws_caller_identity" "current" {}


# resource "aws_iam_role" "test_role" {
#   name = "ClusterRole"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
# 						"Version": "2012-10-17",
# 						"Statement": [{
# 								"Action": [
# 									"ecs:RegisterTaskDefinition",
# 									"ecs:ListClusters",
# 									"ecs:DescribeContainerInstances",
# 									"ecs:ListTaskDefinitions",
# 									"ecs:DescribeTaskDefinition",
# 									"ecs:DeregisterTaskDefinition"
# 								],
# 								"Effect": "Allow",
# 								"Resource": "*"
# 							},
# 							{
# 								"Action": [
# 									"ecs:ListContainerInstances",
# 									"ecs:DescribeClusters"
# 								],
# 								"Effect": "Allow",
# 								"Resource": [{
# 									"Fn::Sub": [
# 										"arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.ecsClusterName}",
# 										{
# 											"clusterName": {
# 												"Ref": "clusterName"
# 											}
# 										}
# 									]
# 								}]
# 							},
# 							{
# 								"Action": [
# 									"ecs:RunTask"
# 								],
# 								"Effect": "Allow",
# 								"Condition": {
# 									"ArnEquals": {
# 										"ecs:cluster": [{
# 											"Fn::Sub": [
# 										"arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.ecsClusterName}",
# 												{
# 													"clusterName": {
# 														"Ref": "clusterName"
# 													}
# 												}
# 											]
# 										}]
# 									}
# 								},
# 								"Resource": {
# 									"Fn::Sub": "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:task-definition/*"
# 								}
# 							},
# 							{
# 								"Action": [
# 									"ecs:StopTask"
# 								],
# 								"Effect": "Allow",
# 								"Condition": {
# 									"ArnEquals": {
# 										"ecs:cluster": [{
# 											"Fn::Sub": [
# 										"arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.ecsClusterName}",
# 												{
# 													"clusterName": {
# 														"Ref": "clusterName"
# 													}
# 												}
# 											]
# 										}]
# 									}
# 								},
# 								"Resource": {
# 									"Fn::Sub": "arn:aws:ecs:*:*:task/*"
# 								}
# 							},
# 							{
# 								"Action": [
# 									"ecs:DescribeTasks"
# 								],
# 								"Effect": "Allow",
# 								"Condition": {
# 									"ArnEquals": {
# 										"ecs:cluster": [{
# 											"Fn::Sub": [
# 										"arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.ecsClusterName}",
# 												{
# 													"clusterName": {
# 														"Ref": "clusterName"
# 													}
# 												}
# 											]
# 										}]
# 									}
# 								},
# 								"Resource": {
# 									"Fn::Sub": "arn:aws:ecs:*:*:task/*"
# 								}
# 							},
# 							{
# 								"Sid": "",
# 								"Effect": "Allow",
# 								"Action": [
# 									"ecr:GetDownloadUrlForLayer",
# 									"ecr:GetAuthorizationToken",
# 									"ecr:BatchGetImage",
# 									"ecr:BatchCheckLayerAvailability"
# 								],
# 								"Resource": "*"
# 							}
# 						]
# 					})

#   tags = var.tags
# }