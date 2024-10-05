variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_cidr_block" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "private_cidr_block" {
  description = "CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "The instance type"
  default     = "t2.micro"
}

variable "availability_zones" {
  description = "List of availability zones for the load balancer"
  type        = list(string)
  default     = ["us-east-1a"]
}
