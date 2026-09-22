variable "name" {
  description = "(optional) Name of the ECR repository (defaults to product if null)"
  default     = null
  type        = string
}

variable "scan_on_push" {
  description = "(optional) Security scan on push"
  default     = true
  type        = bool
}

variable "images_to_retain" {
  description = "(optional) Number of most recent images to retain. When null, the number defaults to the environment: 5 for sharedtools, 10 dev, 15 qa, 20 staging, 35 prod. A lifecycle policy is always created — retention is enforced on every repository this module manages, and cannot be switched off."
  default     = null
  type        = number
  validation {
    condition     = var.images_to_retain == null || try(var.images_to_retain > 0, false)
    error_message = "Images_to_retain must be a number greater than zero or null."
  }
}

variable "image_tag_mutability" {
  description = "(optional) Image tag mutability (allowance for a tag be reassigned to another image)"
  default     = "IMMUTABLE"
  type        = string
  validation {
    condition     = can(regex("^MUTABLE$|^IMMUTABLE$", var.image_tag_mutability))
    error_message = "Valid values are \"MUTABLE\" and \"IMMUTABLE\"."
  }
}

variable "encryption_configuration" {
  description = "(optional) Encryption configuration. Set `encryption_type` to `KMS` to use KMS encryption. Set `kms_key_arn` to the ARN of the KMS key to use. Set `encryption_type` to `AES256` to use AES256 encryption."
  default = {
    encryption_type = "AES256"
    kms_key_arn     = null
  }
  type = object({
    encryption_type = string
    kms_key_arn     = optional(string)
  })
}

variable "create_ecr_policy" {
  description = "(optional) Create ECR policy"
  default     = true
  type        = bool
}

variable "allow_lambda_access" {
  description = "(optional) Allow Lambda access to ECR"
  default     = true
  type        = bool
}

variable "force_delete" {
  description = "(optional) Force delete ECR repository even if it has images in it"
  default     = false
  type        = bool
}

variable "extra_policy_statements" {
  description = <<EOT
(optional) Additional statements to merge into the generated repository policy, each a JSON-encoded IAM statement. Anything a repository policy can express lives in a statement, so this covers cross-account grants, conditions and deny rules alike. Set `allow_lambda_access = false` alongside it for a policy made up only of these statements.

```hcl
extra_policy_statements = [
  jsonencode({
    Sid       = "CrossAccountPull"
    Effect    = "Allow"
    Principal = { AWS = "arn:aws:iam::111122223333:root" }
    Action    = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"]
  })
]
```
EOT
  default     = []
  type        = list(string)
  validation {
    condition     = alltrue([for s in var.extra_policy_statements : can(jsondecode(s))])
    error_message = "Each extra_policy_statements entry must be valid JSON."
  }
}
