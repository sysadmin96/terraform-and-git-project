variable "availability_zones" {
  description = "List of availability zones for the load balancer"
}

variable "instance_ids" {
  description = "List of instance IDs for the load balancer"
  type = list(string)
}
