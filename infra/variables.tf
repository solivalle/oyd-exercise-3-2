variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "name" {
  description = "Base name applied to all resources in this module"
  type        = string
}

variable "memory_size" {
  description = "Memory allocated to the Lambda function in MB (min 128)"
  type        = number
  default     = 128
}

variable "architecture" {
  description = "CPU architecture for the Lambda function (x86_64 or arm64)"
  type        = string
  default     = "arm64"
}