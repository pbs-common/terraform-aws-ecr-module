# PBS TF ECR Module

## Installation

### Using the Repo Source

```hcl
github.com/pbs/terraform-aws-ecr-module?ref=x.y.z
```

### Alternative Installation Methods

More information can be found on these install methods and more in [the documentation here](./docs/general/install).

## Usage

This module provisions an ECR repository.

By default, the repository will be created with 
- sharedtools: 5 images  
- dev: 10 images         
- qa: 15 images          
- staging: 20 images    
- prod: 35 images 
 retention policy, be `AES256` encrypted and allow access from Lambda. Use the optional variables provided in this module to adjust those configurations.

Integrate this module like so:

```hcl
module "ecr" {
  source = "github.com/pbs/terraform-aws-ecr-module?ref=x.y.z"

  # Tagging Parameters
  organization = var.organization
  environment  = var.environment
  product      = var.product
  repo         = var.repo

  # Optional Parameters
}
```

### Retention

A lifecycle policy is always created. Retention is enforced on every repository this module manages and cannot be switched off; `images_to_retain` only changes how many images are kept, defaulting to the per-environment numbers above.

### Repository policy

By default the repository policy carries a single statement allowing Lambda to pull images. `allow_lambda_access = false` drops it, and `create_ecr_policy = false` skips the policy altogether.

Add to the policy with `extra_policy_statements`, a list of JSON-encoded IAM statements. Everything a repository policy can express lives in a statement, so this covers cross-account grants, conditions and deny rules alike:

```hcl
allow_lambda_access = false

extra_policy_statements = [
  jsonencode({
    Sid       = "CrossAccountPull"
    Effect    = "Allow"
    Principal = { AWS = "arn:aws:iam::111122223333:root" }
    Action    = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"]
  })
]
```

A policy needs at least one statement to be valid, so switching off the Lambda statement without adding any of your own creates no policy rather than an empty one. See [the policy example](/examples/policy).

## Adding This Version of the Module

If this repo is added as a subtree, then the version of the module should be close to the version shown here:

`x.y.z`

Note, however that subtrees can be altered as desired within repositories.

Further documentation on usage can be found [here](./docs).

Below is automatically generated documentation on this Terraform module using [terraform-docs][terraform-docs]

---

[terraform-docs]: https://github.com/terraform-docs/terraform-docs
