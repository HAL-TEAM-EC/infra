resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  frontend_bucket_name = coalesce(
    var.frontend_bucket_name,
    "${local.name_prefix}-frontend-${random_id.bucket_suffix.hex}"
  )

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.additional_tags
  )

  has_custom_domain = length(var.custom_domain_names) > 0
}
