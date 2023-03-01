output "alice_email" {
  value = azuread_user.alice.mail
}

output "alice_password" {
  sensitive = true
  value     = azuread_user.alice.password
}

output "bob_email" {
  value = azuread_user.bob.mail
}

output "bob_password" {
  sensitive = true
  value     = azuread_user.bob.password
}

output "saml_metadata_document" {
  value = local.saml_metadata_document
  # NB this is not really sensitive, but its value is too big to be reviewed in
  #    the terraform diff, so this will prevent terraform from showing it in
  #    the default output.
  sensitive = true
}

output "aws_access_portal_url" {
  value = local.aws_access_portal_url
}
