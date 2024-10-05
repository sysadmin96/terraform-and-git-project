variable "instance_type" {
  description = "The instance type"
  default     = "t2.micro"
}

variable "public_subnet_id" {
  description = "Subnet ID for the proxy instance"
}

variable "private_subnet_id" {
  description = "Subnet ID for the backend instance"
}
