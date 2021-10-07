resource "aws_ecs_cluster" "cluster" {
  name = "${var.ecsClusterName}"
  capacity_providers = var.spotEnabled == true ? ["FARGATE_SPOT"] : ["FARGATE"]
#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }
tags = var.tags
}
