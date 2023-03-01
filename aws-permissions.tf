locals {
  aws_region            = data.aws_ssoadmin_instances.example.id
  aws_sso_instance_arn  = data.aws_ssoadmin_instances.example.arns[0]
  aws_identity_store_id = data.aws_ssoadmin_instances.example.identity_store_ids[0]
  aws_saml_acs          = "http://localhost/TODO_SEE_README"
  aws_saml_entity_id    = "urn:example:TODO_SEE_README"
  aws_access_portal_url = "https://${local.aws_identity_store_id}.awsapps.com/start"
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set
resource "aws_ssoadmin_permission_set" "administrators" {
  instance_arn = local.aws_sso_instance_arn
  name         = "Administrators"
  description  = "Provides administrative access to AWS services and resources."
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set
resource "aws_ssoadmin_permission_set" "readers" {
  instance_arn = local.aws_sso_instance_arn
  name         = "Readers"
  description  = "Provides read-only access to AWS services and resources."
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment
resource "aws_ssoadmin_managed_policy_attachment" "administrators" {
  instance_arn       = local.aws_sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrators.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment
resource "aws_ssoadmin_managed_policy_attachment" "readers" {
  instance_arn       = local.aws_sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readers.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment
resource "aws_ssoadmin_account_assignment" "administrators" {
  instance_arn       = local.aws_sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrators.arn
  principal_type     = "GROUP"
  principal_id       = aws_identitystore_group.administrators.group_id
  target_type        = "AWS_ACCOUNT"
  target_id          = data.aws_caller_identity.current.account_id
}

# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment
resource "aws_ssoadmin_account_assignment" "readers" {
  instance_arn       = local.aws_sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readers.arn
  principal_type     = "GROUP"
  principal_id       = aws_identitystore_group.readers.group_id
  target_type        = "AWS_ACCOUNT"
  target_id          = data.aws_caller_identity.current.account_id
}
