variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "project_name" {
  description = "Projekt-Name"
  type        = string
  default     = "java-demo"
}

variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
  default     = "production"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID (Ubuntu 22.04 LTS)"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH Public Key für EC2-Zugriff"
  type        = string
}
