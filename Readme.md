## Logic App Terraform Example

### This sample demonstrates deploying a logic app using Terraform v0.13.2. 

## Terraform template
- Deploys the logic app using an arm template deployment
- The template echos the single string output of the template deployment.

## ARM Template
The embedded logic app template includes the following:
- http trigger activity
- Outlook 365 send email activity
- a single output containing the fully qualified callback url of the http trigger
- outlook 365 API connection

## API Connection
The outlook 365 API connection is an OAuth2 connection. As such, this must be manually authorized, post deployment. Refer to [Authorize OAuth Connections](https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-deploy-azure-resource-manager-templates#authorize-oauth-connections) and [LogicAppConnectionAuth](https://github.com/logicappsio/LogicAppConnectionAuth).
