module "ecr" {
  source = "../.."

  name                 = var.product
  scan_on_push         = false
  images_to_retain     = null
  image_tag_mutability = "MUTABLE"

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
