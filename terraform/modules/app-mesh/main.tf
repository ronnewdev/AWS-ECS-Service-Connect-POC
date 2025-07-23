resource "aws_appmesh_mesh" "this" {
  name = var.mesh_name
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = var.namespace
  description = "Private DNS for ECS service connect"
  vpc         = var.vpc_id
}

output "namespace_name" {
  value = aws_service_discovery_private_dns_namespace.this.name
}
