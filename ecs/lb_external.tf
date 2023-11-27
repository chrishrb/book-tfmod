# ***************************************************************************
#
# External load balancer
#
# ***************************************************************************

resource "aws_lb" "external" {
  name                       = "${var.service_prefix}-alb-external"
  internal                   = false
  load_balancer_type         = "application"
  drop_invalid_header_fields = true

  security_groups = flatten([
    data.aws_security_groups.allow_local.ids,
    data.aws_security_groups.allow_http.ids,
    data.aws_security_groups.allow_https.ids,
  ])

  subnets = flatten([
    data.aws_subnets.public.ids,
  ])
}

resource "aws_lb_listener" "external_http" {
  load_balancer_arn = aws_lb.external.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.book_monolith.arn
  }
}

resource "aws_lb_target_group" "book_monolith" {
  name        = "${var.service_prefix}-book-monolith-public"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 20
    timeout             = 9
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}
