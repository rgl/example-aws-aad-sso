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

**NB** If you are using the Free Microsoft 365 E5 instant sandbox, you should login as its administrator.

Ensure the expected account is set as default:

```bash
az account show
az account list
az account set --subscription=<tenantId or id>
az account show
```

Configure the AWS CLI to use a Secret Key to access AWS:

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

1. Go to the `Dashboard` page.
2. Change the identity source to `External service provider`:
   1. Click the `Choose your identity source` link.
   2. Under the `Identity source` tab, click the `Actions` button, and choose `Change identity source`.
   3. Click `External service provider`.
   4. Click the `Next` button.
3. Under the `Service provider metadata` section:
   1. Copy the `IAM Identity Center Assertion Consumer Service (ACS) URL` and paste it into the `aws_saml_acs` variable value inside the `aws-permissions.tf` file.
   2. Copy the `IAM Identity Center issuer URL` and paste it into the `aws_saml_entity_id` variable value inside the `aws-permissions.tf` file.
   3. Execute `make terraform-plan` and review the plan.
   4. Execute `make terraform-apply` and wait for it to finish.
   5. Execute `terraform output -raw saml_metadata_document >azure-ad-idp-saml-metadata.xml`
4. Under the `Identity provider metadata`, `IdP SAML metadata` section:
   1. Click the `Choose file` button, and upload the `azure-ad-idp-saml-metadata.xml` file created in the previous step.
5. Click `Next`.
6. Review and confirm.
7. Click `Change identity source`.

Show the `AWS access portal URL` (aka SSO start URL):

```bash
terraform output -raw aws_access_portal_url
```

Open the `AWS access portal URL` in a web browser, and login with the `Alice` credentials:

```bash
terraform output -raw alice_email
terraform output -raw alice_password
```

Open a new shell session, and configure the AWS CLI to use a SSO generated
token to access AWS as `Alice`:

```bash
aws configure sso
```

The questions, answers, and output will be something alike:

```plain
SSO session name (Recommended): cli
SSO start URL [None]: https://d-0000000000.awsapps.com/start
SSO region [None]: eu-west-1
SSO registration scopes [sso:account:access]:
Attempting to automatically open the SSO authorization page in your default browser.
If the browser does not open or you wish to use a different device to authorize this request, open the following URL:

https://device.sso.eu-west-1.amazonaws.com/

Then enter the code:

0000-0000
The only AWS account available to you is: 00000000
Using the account ID 00000000
There are 2 roles available to you.
Using the role name "Readers"
CLI default client Region [None]:
CLI default output format [None]:
CLI profile name [Readers-00000000]: Alice-Readers

To use this profile, specify the profile name using --profile, as shown:

aws s3 ls --profile Alice-Readers
```

Use the profile, and show the user, user amazon resource name (arn), and the account id:

```
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
export AWS_PROFILE='Alice-Readers'
aws sts get-caller-identity
```

This should show something alike:

```json
{
    "UserId": "000000000000000000000:example-aws-aad-sso-alice.doe@example.onmicrosoft.c",
    "Account": "00000000",
    "Arn": "arn:aws:sts::00000000:assumed-role/AWSReservedSSO_Readers_0000000000000000/example-aws-aad-sso-alice.doe@example.onmicrosoft.c"
}
```

After you are done testing as `Alice`, logout, and exit the shell:

```bash
aws sso logout
exit
```

When you later need to login again, you can skip the `aws configure sso` step,
and use `aws sso login` as:

```bash
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
export AWS_PROFILE='Alice-Readers'
aws sso login
aws sts get-caller-identity
```

After you are done testing, and are ready to destroy everything, return to the
original shell, the one that is using the `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY` environment variables, and destroy everything:

```bash
make terraform-destroy
```

# References

* [Tutorial: Azure AD SSO integration with AWS IAM Identity Center](https://learn.microsoft.com/en-us/azure/active-directory/saas-apps/aws-single-sign-on-tutorial)
* [Configuring the AWS CLI to use AWS IAM Identity Center (successor to AWS Single Sign-On)](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
* [Environment variables to configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
