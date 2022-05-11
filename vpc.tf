resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.splunk_vpc.id
  tags = {
    Name = "Splunk internet gateway"
  }
}
resource "aws_vpc" "splunk_vpc" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Splunk VPC"
  }
}
resource "aws_subnet" "splunk_subnet1" {
  vpc_id            = aws_vpc.splunk_vpc.id
  cidr_block        = "172.31.48.0/20"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "Splunk 1"
  }
}
resource "aws_subnet" "splunk_subnet2" {
  vpc_id            = aws_vpc.splunk_vpc.id
  cidr_block        = "172.31.64.0/20"
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "Splunk 2"
  }
}
resource "aws_route_table" "splunk_vpc_rt" {
  vpc_id = aws_vpc.splunk_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "Splunk route table"
  }
}
resource "aws_route_table_association" "splunk_vpc_rta_subnet1" {
  subnet_id      = aws_subnet.splunk_subnet1.id
  route_table_id = aws_route_table.splunk_vpc_rt.id
}
resource "aws_route_table_association" "splunk_vpc_rta_subnet2" {
  subnet_id      = aws_subnet.splunk_subnet2.id
  route_table_id = aws_route_table.splunk_vpc_rt.id
}
resource "aws_lb" "splunk_lb" {
  name               = "Splunk-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.splunk.id]
  subnets            = [aws_subnet.splunk_subnet1.id, aws_subnet.splunk_subnet2.id]
}
resource "aws_lb_target_group" "splunk_target" {
  name        = "splunk"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.splunk_vpc.id
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
  name        = "trello-webhook"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.splunk_vpc.id
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
