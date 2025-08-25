# variables.tf
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "List of AZs for subnets"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "stage-eks-cluster"
}

variable "node_desired_capacity" {
  description = "Number of worker nodes to launch"
  type        = number
  default     = 2
}

variable "node_min_capacity" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_capacity" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "public_key_path" {
  description = "Path to SSH public key for EC2 access"
  type        = string
  default     = "id_rsa.pub"
}