# Terraform Static Site

## Description

Provisions a static site on AWS. Configures a private bucket website served through cloudfront. This module does not provision any redirects. If you would like to redirect a domain to this one (e.g. www to non-www or vice-versa) then use the module https://github.com/gillisandrew/terraform-static-redirect

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| aws.acm | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain | Domain to serve the site under | `string` | n/a | yes |
| environment | Deployment environment (e.g. prod, dev, test) | `string` | `"dev"` | no |
| hosted\_zone\_id | n/a | `string` | n/a | yes |
| project | A meaningful project name | `string` | `"example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket | n/a |
| url | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->