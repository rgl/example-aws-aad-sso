# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user
resource "aws_identitystore_user" "alice" {
  identity_store_id = local.aws_identity_store_id
  display_name      = azuread_user.alice.display_name
  user_name         = azuread_user.alice.user_principal_name
  name {
    given_name  = azuread_user.alice.given_name
    family_name = azuread_user.alice.surname
  }
  emails {
    value   = azuread_user.alice.mail
    primary = true
  }
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user
resource "aws_identitystore_user" "bob" {
  identity_store_id = local.aws_identity_store_id
  display_name      = azuread_user.bob.display_name
  user_name         = azuread_user.bob.user_principal_name
  name {
    given_name  = azuread_user.bob.given_name
    family_name = azuread_user.bob.surname
  }
  emails {
    value   = azuread_user.bob.mail
    primary = true
  }
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group
resource "aws_identitystore_group" "administrators" {
  identity_store_id = local.aws_identity_store_id
  display_name      = "Administrators"
  description       = "Provides administrative access to AWS services and resources."
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group
resource "aws_identitystore_group" "readers" {
  identity_store_id = local.aws_identity_store_id
  display_name      = "Readers"
  description       = "Provides read-only access to AWS services and resources."
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership
resource "aws_identitystore_group_membership" "administrators_alice" {
  identity_store_id = local.aws_identity_store_id
  group_id          = aws_identitystore_group.administrators.group_id
  member_id         = aws_identitystore_user.alice.user_id
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership
resource "aws_identitystore_group_membership" "readers_alice" {
  identity_store_id = local.aws_identity_store_id
  group_id          = aws_identitystore_group.readers.group_id
  member_id         = aws_identitystore_user.alice.user_id
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership
resource "aws_identitystore_group_membership" "readers_bob" {
  identity_store_id = local.aws_identity_store_id
  group_id          = aws_identitystore_group.readers.group_id
  member_id         = aws_identitystore_user.bob.user_id
}
