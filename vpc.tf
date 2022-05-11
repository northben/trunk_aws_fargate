resource "aws_subnet" "trunk_subnet1" {
  vpc_id     = var.vpc_id
  cidr_block = var.subnet1_cidr
  tags = {
    Name = "trunk 1"
  }
}
resource "aws_subnet" "trunk_subnet2" {
  vpc_id     = var.vpc_id
  cidr_block = var.subnet2_cidr
  tags = {
    Name = "trunk 2"
  }
}

resource "aws_lb" "splunk_lb" {
  name               = "splunk"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_splunk.id]
  subnets            = [aws_subnet.trunk_subnet1.id, aws_subnet.trunk_subnet2.id]
}
resource "aws_lb_target_group" "splunk_target" {
  name        = "splunk"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path = "/en-US/account/login"
  }
}
resource "aws_lb_listener" "splunk_listener" {
  load_balancer_arn = aws_lb.splunk_lb.arn
  port              = "8000"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.splunk_target.arn
  }
}
resource "aws_lb_target_group" "webhook_target" {
  name        = "webhook"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path = "/trello"
  }
}
resource "aws_lb_listener" "webhook_listener" {
  load_balancer_arn = aws_lb.splunk_lb.arn
  port              = "9000"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webhook_target.arn
  }
}

resource "aws_route53_record" "trunk" {
  zone_id = var.route53_zone
  name    = var.trunk_dns_name
  type    = "A"
  alias {
    name                   = aws_lb.splunk_lb.dns_name
    zone_id                = aws_lb.splunk_lb.zone_id
    evaluate_target_health = false
  }
}
