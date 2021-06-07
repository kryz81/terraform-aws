resource "aws_lb" "kryz_lb" {
  name            = "kryz-loadbalancer"
  security_groups = [var.public_sg]
  subnets         = var.public_subnets
  idle_timeout    = 400
}

resource "aws_alb_target_group" "kryz_tg" {
  name     = "kryz-lb-tg-${uuid()}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = var.lb_healthy_threeshold
    unhealthy_threshold = var.lb_unhealthy_threeshold
    timeout             = var.lb_timeout
    interval            = var.lb_interval
  }

  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }

}

resource "aws_alb_listener" "kryz_lblistener" {
  load_balancer_arn = aws_lb.kryz_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.kryz_tg.arn
  }
}
