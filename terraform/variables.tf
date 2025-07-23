variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}

variable "ecr_backend_image" {}
variable "ecr_frontend_image" {}
variable "ecs_cluster_name" {
  default = "service-connect-poc"
}
