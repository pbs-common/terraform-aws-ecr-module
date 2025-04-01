locals {
  name    = var.name != null ? var.name : var.product
  creator = "terraform"

  defaulted_tags = merge(
    var.tags,
    {
      Name                                      = local.name
      "${var.organization}:billing:product"     = var.product
      "${var.organization}:billing:environment" = var.environment
      creator                                   = local.creator
      repo                                      = var.repo
    }
  )

  tags = merge({ for k, v in local.defaulted_tags : k => v if lookup(data.aws_default_tags.common_tags.tags, k, "") != v })
   # Default retention values per environment
  default_retention_values = {
    sharedtools = 10
    dev         = 10  
    qa          = 15   
    staging     = 20   
    prod        = 40   
  }

  # Calculate the effective number of images to retain
  effective_images_to_retain = coalesce(
    try(var.images_to_retain, null),                    # First priority: explicit images_to_retain
    try(var.environment_images_retention[var.environment], null),  # Second priority: environment-specific override
    try(local.default_retention_values[var.environment], null),    # Third priority: default for environment
    local.default_retention_values["prod"]              # Final fallback: prod default
  )

  # Create lifecycle policy only if effective_images_to_retain is set
  create_lifecycle_policy = local.effective_images_to_retain != null
}

data "aws_default_tags" "common_tags" {}
