provider "aws" {
  region = "eu-north-1"
}

data "aws_iam_role" "ecs_task_exec_role" {
  name = "ecsTaskExecutionRole"
}

module "network" {
  source     = "./modules/network"
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
}

module "ecs_cluster" {
  source           = "./modules/ecs-cluster"
  ecs_cluster_name = var.ecs_cluster_name
  log_group_name   = "/ecs/service-connect-poc"
}

module "mesh" {
  source    = "./modules/app-mesh"
  mesh_name = "poc-appmesh"
  namespace = "service.local"
  vpc_id    = module.network.vpc_id
}

module "backend_service" {
  source              = "./modules/service"
  ecs_cluster_id      = module.ecs_cluster.cluster_id
  task_exec_role      = data.aws_iam_role.ecs_task_exec_role.arn
  vpc_id              = module.network.vpc_id
  subnet_ids          = module.network.subnet_ids
  service_name        = "backend-poc"
  sg_name             = "ecs-service-connect-sg-backend"
  task_family         = "backend-task"
  cpu                 = "256"
  memory              = "512"
  container_definitions = jsonencode([{
    name  = "backend"
    image = var.ecr_backend_image
    portMappings = [{
      containerPort = 5000
      name          = "backend-port"
      appProtocol   = "http"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = module.ecs_cluster.log_group_name
        awslogs-region        = "eu-north-1"
        awslogs-stream-prefix = "backend"
      }
    }
  }])
  assign_public_ip    = false
  service_namespace   = module.mesh.namespace_name
  port_name           = "backend-port"
  discovery_name      = "backend-poc"
  client_port         = 5000
  client_dns_name     = "backend-poc"
}

module "frontend_service" {
  source              = "./modules/service"
  ecs_cluster_id      = module.ecs_cluster.cluster_id
  task_exec_role      = data.aws_iam_role.ecs_task_exec_role.arn
  vpc_id              = module.network.vpc_id
  subnet_ids          = module.network.subnet_ids
  service_name        = "frontend"
  sg_name             = "ecs-service-connect-sg-frontend"
  task_family         = "frontend-task"
  cpu                 = "256"
  memory              = "512"
  container_definitions = jsonencode([{
    name  = "frontend"
    image = var.ecr_frontend_image
    portMappings = [{
      containerPort = 3000
      name          = "frontend-port"
      appProtocol   = "http"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = module.ecs_cluster.log_group_name
        awslogs-region        = "eu-north-1"
        awslogs-stream-prefix = "frontend"
      }
    }
  }])
  assign_public_ip    = true
  service_namespace   = module.mesh.namespace_name
  port_name           = "frontend-port"
  discovery_name      = "frontend-poc"
  client_port         = 5000
  client_dns_name     = "backend-poc"
}
