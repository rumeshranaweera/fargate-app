variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "fargate-app"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8080
}

variable "app_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 2
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "fargate_memory" {
  description = "Fargate instance memory in MB"
  type        = number
  default     = 512
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
  default     = "your-github-username"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "aws-fargate-cicd"
}
