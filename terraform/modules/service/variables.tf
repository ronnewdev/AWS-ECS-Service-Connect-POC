variable "ecs_cluster_id" {}
variable "task_exec_role" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "service_name" {}
variable "sg_name" {}
variable "task_family" {}
variable "cpu" {}
variable "memory" {}
variable "container_definitions" {}
variable "assign_public_ip" {}
variable "service_namespace" {}
variable "port_name" {}
variable "discovery_name" {}
variable "client_port" {}
variable "client_dns_name" {}
