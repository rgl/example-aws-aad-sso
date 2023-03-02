# About

[![Lint](https://github.com/rgl/example-aws-aad-sso/actions/workflows/lint.yml/badge.svg)](https://github.com/rgl/example-aws-aad-sso/actions/workflows/lint.yml)

This integrates the AWS IAM Identity Center with the Azure AD as a SSO solution.

This will use [terraform](https://www.terraform.io/) to configure the AWS IAM Identity Center and the Azure AD services as described in the [Tutorial: Azure AD SSO integration with AWS IAM Identity Center](https://learn.microsoft.com/en-us/azure/active-directory/saas-apps/aws-single-sign-on-tutorial).

It will create the Azure AD [Users](azure-users.tf), [Application, Application Roles, Enterprise Application (aka Service Principal)](azure-applications.tf) that can be used to login into AWS.

It will create the homologous AWS Identity Center [Users, Groups](aws-users.tf), and [Permissions Sets](aws-permissions.tf) to login into AWS.

You can test this in the Azure AD of [Free Microsoft 365 E5 instant sandbox](https://developer.microsoft.com/en-us/microsoft-365/dev-program) and in the [AWS Free Tier](https://aws.amazon.com/free/).

Be aware that this is not configuring [Automatic User Provisioning](https://docs.aws.amazon.com/singlesignon/latest/userguide/provision-automatically.html). Its creating the users in both directories: Azure AD and AWS Identity Center.

Be aware that the AWS IAM Identity Center can only be connected with a single Azure AD. For more information see the [FAQ: Can I connect more than one identity source to IAM Identity Center?](https://aws.amazon.com/iam/identity-center/faqs/#Identity_sources_and_applications_support).

Be aware of the [AWS IAM Identity Center User Guide Troubleshooting section](https://docs.aws.amazon.com/singlesignon/latest/userguide/troubleshooting.html), especially the [Error 'An unexpected error has occurred' when a user tries to sign in using an external identity provider](https://docs.aws.amazon.com/singlesignon/latest/userguide/troubleshooting.html#issue8).

Be aware that although AWS Single Sign-On was renamed to AWS IAM Identity Center, the `sso` and `identitystore` API namespaces (and terraform names) continue to retain their original name for backward compatibility purposes. For more information, see [IAM Identity Center rename](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html#renamed).

# Usage

Create an Azure account.

Create an AWS account, choose a region, and then [just enable the IAM Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/getting-started.html) (this will also enable the AWS Organizations service).

Install the required tools:

* [terraform](https://github.com/hashicorp/terraform).
* [azure-cli](https://github.com/Azure/azure-cli).
* [aws-cli](https://github.com/aws/aws-cli).

Login into Azure:

```bash
az login --allow-no-subscriptions
```

Ensure the expected account is set as default:

```bash
az account show
az account list
az account set --subscription=<tenantId or id>
az account show
```

Login into AWS:

```bash
# set the account credentials.
# NB get these from your aws account iam console.
#    see Managing access keys (console) at
#        https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey
export AWS_ACCESS_KEY_ID='TODO'
export AWS_SECRET_ACCESS_KEY='TODO'
# set the default region.
export AWS_DEFAULT_REGION='eu-west-1'
# show the user, user amazon resource name (arn), and the account id.
aws sts get-caller-identity
```

Initialize terraform:

```bash
make terraform-init
```

Launch the example:

```bash
make terraform-plan
make terraform-apply
```

Open the AWS Identity Center page and:

1. Change the identity source to `External service provider`.
2. Under the `Service provider metadata` section:
   1. Copy the `IAM Identity Center Assertion Consumer Service (ACS) URL` and paste it into the `aws_saml_acs` variable value inside the `aws-permissions.tf` file.
   2. Copy the `IAM Identity Center issuer URL` and paste it into the `aws_saml_entity_id` variable value inside the `aws-permissions.tf` file.
   3. Execute `make terraform-plan` and review the plan.
   4. Execute `make terraform-apply` and wait for it to finish.
   5. Execute `terraform output -raw saml_metadata_document >azure-ad-idp-saml-metadata.xml`
3. Under the `Identity provider metadata`, `IdP SAML metadata` section:
   1. Click the `Choose file` button, and upload the `azure-ad-idp-saml-metadata.xml` file created in the previous step.
4. Click `Next`.
5. Review and confirm.
6. Click `Change identity source`.

Show the `AWS access portal URL`:

```bash
terraform output -raw aws_access_portal_url
```

Open the `AWS access portal URL` in a web browser, and login with the `Alice` credentials:

```bash
terraform output -raw alice_email
terraform output -raw alice_password
```

After you are done testing, you can destroy everything:

```bash
make terraform-destroy
```

# References

* [Tutorial: Azure AD SSO integration with AWS IAM Identity Center](https://learn.microsoft.com/en-us/azure/active-directory/saas-apps/aws-single-sign-on-tutorial)
