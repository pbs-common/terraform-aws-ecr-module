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
    sharedtools = 5
    dev         = 10  
    qa          = 15   
    staging     = 20   
    prod        = 35   
  }

  # Calculate the effective number of images to retain
  # Priority: environment_images_retention > images_to_retain > environment default
  effective_images_to_retain = coalesce(
    try(local.default_retention_values[var.environment_images_retention], null), # First priority: environment_images_retention setting
    var.images_to_retain,                                           # Second priority: explicit images_to_retain
    try(local.default_retention_values[var.environment], null),     # Third priority: actual environment default
    local.default_retention_values["prod"]                         # Final fallback: prod default
  )

  # Create lifecycle policy only if effective_images_to_retain is set
  create_lifecycle_policy = local.effective_images_to_retain != null
}

data "aws_default_tags" "common_tags" {}
