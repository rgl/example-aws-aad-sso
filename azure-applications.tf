locals {
  # NB unfortunately, azuread_service_principal.example.saml_metadata_url is
  #    always empty, so we have to construct the value manually. this will
  #    probably break in the future when the azure implementation changes
  #    this... but for now it works.
  # e.g. https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/federationmetadata/2007-06/federationmetadata.xml?appid=00000000-0000-0000-0000-000000000001
  saml_metadata_url      = "https://login.microsoftonline.com/${azuread_service_principal.example.application_tenant_id}/federationmetadata/2007-06/federationmetadata.xml?appid=${azuread_service_principal.example.application_id}"
  saml_metadata_document = saml_metadata.example.document

  administrator_app_role = "administrator"
  reader_app_role        = "reader"
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
resource "azuread_application" "example" {
  display_name     = var.prefix
  owners           = [data.azuread_client_config.current.object_id]
  logo_image       = filebase64("logo.png")
  sign_in_audience = "AzureADMyOrg"
  identifier_uris  = [local.aws_saml_entity_id]
  web {
    redirect_uris = [
      local.aws_saml_acs,
    ]
  }
  # TODO see how can we use these app_role in AWS Identity Center.
  app_role {
    id                   = uuidv5("url", "urn:administrator")
    value                = local.administrator_app_role
    description          = "Administrator"
    display_name         = "Administrator"
    allowed_member_types = ["User"]
  }
  app_role {
    id                   = uuidv5("url", "urn:reader")
    value                = local.reader_app_role
    description          = "Reader"
    display_name         = "Reader"
    allowed_member_types = ["User"]
  }
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal
resource "azuread_service_principal" "example" {
  application_id                = azuread_application.example.application_id
  owners                        = [data.azuread_client_config.current.object_id]
  app_role_assignment_required  = true
  preferred_single_sign_on_mode = "saml"
  notes                         = "example notes"
  tags = [
    "WindowsAzureActiveDirectoryCustomSingleSignOnApplication", # custom_single_sign_on
    "WindowsAzureActiveDirectoryIntegratedApp",                 # enterprise
  ]
}

# see https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating
resource "time_rotating" "example" {
  rotation_years = 3
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_token_signing_certificate
# see https://github.com/hashicorp/terraform-provider-azuread/pull/968
resource "azuread_service_principal_token_signing_certificate" "example" {
  service_principal_id = azuread_service_principal.example.id
  end_date             = time_rotating.example.rotation_rfc3339
  display_name         = "CN=${azuread_application.example.display_name} SSO Certificate" # (default: Microsoft Azure Federated SSO Certificate)
  # TODO find a non provisioner way of doing this.
  provisioner "local-exec" {
    # NB this is in a single line to make it work in a linux or windows host.
    command = "az ad sp update --id ${self.service_principal_id} --set preferredTokenSigningKeyThumbprint=${self.thumbprint}"
  }
}

# see https://registry.terraform.io/providers/rgl/saml/latest/docs/resources/metadata
resource "saml_metadata" "example" {
  url                          = local.saml_metadata_url
  token_signing_key_thumbprint = azuread_service_principal_token_signing_certificate.example.thumbprint
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment
resource "azuread_app_role_assignment" "alice" {
  app_role_id         = azuread_application.example.app_role_ids[local.administrator_app_role]
  resource_object_id  = azuread_service_principal.example.object_id
  principal_object_id = azuread_user.alice.object_id
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment
resource "azuread_app_role_assignment" "bob" {
  app_role_id         = azuread_application.example.app_role_ids[local.reader_app_role]
  resource_object_id  = azuread_service_principal.example.object_id
  principal_object_id = azuread_user.bob.object_id
}
