resource "aws_elb" "public_lb" {
  name               = "public-load-balancer"
  availability_zones = var.availability_zones
  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  instances = var.instance_ids
}
