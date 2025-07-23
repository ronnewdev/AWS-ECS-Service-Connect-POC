resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = 3
}

output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}
