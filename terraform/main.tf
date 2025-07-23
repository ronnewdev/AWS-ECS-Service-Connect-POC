provider "aws" {
  region = "eu-north-1"
}

resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_appmesh_mesh" "this" {
  name = "poc-appmesh"
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "service.local"
  description = "Private DNS for ECS service connect"
  vpc         = var.vpc_id
}

data "aws_iam_role" "ecs_task_exec_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/service-connect-poc"
  retention_in_days = 3
}

resource "aws_security_group" "this" {
  name   = "ecs-service-connect-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------- BACKEND -------------------
resource "aws_ecs_task_definition" "backend" {
  family                   = "backend-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = data.aws_iam_role.ecs_task_exec_role.arn
  task_role_arn            = data.aws_iam_role.ecs_task_exec_role.arn

  container_definitions = jsonencode([{
    name      = "backend"
    image     = var.ecr_backend_image
    portMappings = [{
      containerPort = 5000
      name          = "backend-port"
      appProtocol   = "http"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.name
        awslogs-region        = "eu-north-1"
        awslogs-stream-prefix = "backend"
      }
    }
  }])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_service" "backend" {
  name            = "backend-poc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.this.id]
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.this.name

    service {
      port_name      = "backend-port"
      discovery_name = "backend-poc"

      client_alias {
        port     = 5000
        dns_name = "backend-poc"
      }
    }
  }
}

# ------------------- FRONTEND -------------------
resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = data.aws_iam_role.ecs_task_exec_role.arn
  task_role_arn            = data.aws_iam_role.ecs_task_exec_role.arn

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = var.ecr_frontend_image
    portMappings = [{
      containerPort = 3000
      name          = "frontend-port"
      appProtocol   = "http"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.name
        awslogs-region        = "eu-north-1"
        awslogs-stream-prefix = "frontend"
      }
    }
  }])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.this.id]
    assign_public_ip = true
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.this.name

    #service {
    #  port_name = "frontend-port"
    #  client_alias {                # required, even if client-only
    #    port     = 5000             # backend’s port
    #    dns_name = "frontend-poc"    # the alias your frontend code will call
    #  }
    # 
    #}

    log_configuration {
      log_driver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.name
        awslogs-region        = "eu-north-1"
        awslogs-stream-prefix = "frontend-service"
      }
    }
  }
}
