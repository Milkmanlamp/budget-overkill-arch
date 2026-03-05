resource "aws_ecr_repository" "this" {
  name                 = "${var.project_name}-website"
  image_tag_mutability = "MUTABLE" # for now
}
resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"
}
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-website"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc" # gives each task its own eni for my sg to map to
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-website"
      image     = "${aws_ecr_repository.this.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])
}
resource "aws_alb" "this" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "website" {
  name        = "${var.project_name}-tg1"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = "3000"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.website.arn
  }
}
#https later when i set up certs

resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-ecs-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.id
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.website.arn
    container_name   = "${var.project_name}-ecs-container"
    container_port   = 3000
  }
}
