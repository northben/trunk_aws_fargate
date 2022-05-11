terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}
resource "aws_ecs_task_definition" "trunk" {
  family                   = "trunk"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "splunk"
      image     = var.trunk_ecr_image
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = 8000
        },
        {
          containerPort = 9000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/trunk",
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "ecs",
        }
      }
    }
  ])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
resource "aws_ecs_cluster" "trunk" {
  name               = "trunk"
  capacity_providers = ["FARGATE"]
  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = "trunk"
      }
    }
  }
}
resource "aws_ecs_service" "trunk" {
  name                 = "trunk"
  cluster              = aws_ecs_cluster.trunk.id
  task_definition      = aws_ecs_task_definition.trunk.arn
  desired_count        = 1
  launch_type          = "FARGATE"
  force_new_deployment = true
  network_configuration {
    subnets          = [aws_subnet.trunk_subnet1.id, aws_subnet.trunk_subnet2.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.allow_splunk.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.splunk_target.arn
    container_name   = "splunk"
    container_port   = 8000
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.webhook_target.arn
    container_name   = "splunk"
    container_port   = 9000
  }
}
