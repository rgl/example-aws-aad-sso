# NB this name must be unique within the Azure subscription.
#    all the other names must be unique within this resource group.
variable "prefix" {
  default = "example-aws-aad-sso"
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config
data "azuread_client_config" "current" {
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/domains
data "azuread_domains" "current" {
  only_initial = true
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
data "aws_caller_identity" "current" {
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances
data "aws_ssoadmin_instances" "example" {
  # TODO search a specific one?
}
