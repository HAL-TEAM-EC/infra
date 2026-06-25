variable "project_name" {
  description = "Project name used in AWS resource names and tags."
  type        = string
  default     = "hal-team-ec"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for regional resources such as S3."
  type        = string
  default     = "ap-northeast-1"
}

variable "frontend_bucket_name" {
  description = "Optional fixed S3 bucket name for frontend assets. If null, Terraform creates a unique name."
  type        = string
  default     = null
}

variable "force_destroy_frontend_bucket" {
  description = "When true, Terraform can destroy the frontend bucket even if it contains objects. Keep false for real environments."
  type        = bool
  default     = false
}

variable "cloudfront_price_class" {
  description = "CloudFront price class. PriceClass_200 is a practical default for Japan-focused apps."
  type        = string
  default     = "PriceClass_200"

  validation {
    condition = contains([
      "PriceClass_100",
      "PriceClass_200",
      "PriceClass_All"
    ], var.cloudfront_price_class)
    error_message = "cloudfront_price_class must be PriceClass_100, PriceClass_200, or PriceClass_All."
  }
}

variable "custom_domain_names" {
  description = "Optional custom domain names for CloudFront aliases."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1. Required only when custom_domain_names is not empty."
  type        = string
  default     = null
}

variable "additional_tags" {
  description = "Additional tags applied to AWS resources."
  type        = map(string)
  default     = {}
}
