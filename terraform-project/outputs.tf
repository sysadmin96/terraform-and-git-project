output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_lb_id" {
  value = module.load_balancer.load_balancer_id
}
