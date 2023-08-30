# see https://github.com/hashicorp/terraform
terraform {
  required_version = "1.5.6"
  required_providers {
    # see https://github.com/hashicorp/terraform-provider-random
    # see https://registry.terraform.io/providers/hashicorp/random
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    # see https://github.com/hashicorp/terraform-provider-time
    # see https://registry.terraform.io/providers/hashicorp/time
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
    # see https://github.com/terraform-providers/terraform-provider-azuread
    # see https://registry.terraform.io/providers/hashicorp/azuread
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.41.0"
    }
    # see https://github.com/hashicorp/terraform-provider-aws
    # see https://registry.terraform.io/providers/hashicorp/aws
    aws = {
      source  = "hashicorp/aws"
      version = "5.14.0"
    }
    # see https://github.com/rgl/terraform-provider-saml
    # see https://registry.terraform.io/providers/rgl/saml
    saml = {
      source  = "rgl/saml"
      version = "0.3.0"
    }
  }
}

# see https://github.com/terraform-providers/terraform-provider-azuread
provider "azuread" {
}

# see https://github.com/terraform-providers/terraform-provider-aws
provider "aws" {
}
