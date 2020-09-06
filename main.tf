provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = ">=2.20.0"
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "rg-logicapp-terraform-demo-001"
  location = "westus2"
}

resource "azurerm_template_deployment" "example" {
  name                = "acctesttemplate-01"
  resource_group_name = azurerm_resource_group.main.name
  // lifecycle {
  //     ignore_changes = [
  //         parameters
  //     ]
  // }
  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "logicAppName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "metadata": {
        "description": "Name of the Logic App."
      }
    },
    "logicAppLocation": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location of the Logic App."
      }
    },
    "office365_Connection_Name": {
      "type": "string"
    },
    "office365_Connection_DisplayName": {
      "type": "string"
    },
    "recipient_email_address": {
      "type": "string"
    }
  },
  "variables": {},
  "resources": [
    {
      "name": "[parameters('logicAppName')]",
      "type": "Microsoft.Logic/workflows",
      "location": "[parameters('logicAppLocation')]",
      "tags": {
        "displayName": "LogicApp"
      },
      "apiVersion": "2016-06-01",
      "properties": {
        "definition": {
          "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
          "actions": {
            "Send_an_email_(V2)": {
              "type": "ApiConnection",
              "inputs": {
                "host": {
                  "connection": {
                    "name": "@parameters('$connections')['office365']['connectionId']"
                  }
                },
                "method": "post",
                "body": {
                  "To": "[parameters('recipient_email_address')]",
                  "Subject": "this is the subject",
                  "Body": "this is the body"
                },
                "path": "/v2/Mail"
              },
              "runAfter": {}
            }
          },
          "parameters": {
            "$connections": {
              "defaultValue": {},
              "type": "Object"
            }
          },
          "triggers": {
            "manual": {
              "type": "Request",
              "kind": "Http",
              "inputs": {
                "schema": {}
              }
            }
          },
          "contentVersion": "1.0.0.0",
          "outputs": {}
        },
        "parameters": {
          "$connections": {
            "value": {
              "office365": {
                "id": "[concat(subscription().id, '/providers/Microsoft.Web/locations/', parameters('logicAppLocation'), '/managedApis/', 'office365')]",
                "connectionId": "[resourceId('Microsoft.Web/connections', parameters('office365_Connection_Name'))]",
                "connectionName": "[parameters('office365_Connection_Name')]"
              }
            }
          }
        }
      },
      "dependsOn": [
        "[resourceId('Microsoft.Web/connections', parameters('office365_Connection_Name'))]"
      ]
    },
    {
      "type": "MICROSOFT.WEB/CONNECTIONS",
      "apiVersion": "2018-07-01-preview",
      "name": "[parameters('office365_Connection_Name')]",
      "location": "[parameters('logicAppLocation')]",
      "properties": {
        "api": {
          "id": "[concat(subscription().id, '/providers/Microsoft.Web/locations/', parameters('logicAppLocation'), '/managedApis/', 'office365')]"
        },
        "displayName": "[parameters('office365_Connection_DisplayName')]"
      }
    }
  ],
  "outputs": {
    "logicAppUrl": {
      "type": "string",
      "value": "[listCallbackURL(concat(resourceId('Microsoft.Logic/workflows/', parameters('logicAppName')), '/triggers/manual'), '2016-06-01').value]"
    }
  }
}
DEPLOY
  parameters = {
    "logicAppName" = "logic-app-emailsender",
    "office365_Connection_DisplayName" = "email account goes here",
    "office365_Connection_Name" = "office-365-connection-1",
    "recipient_email_address" = "some-address@mailserver.com"
  }

  deployment_mode = "Incremental"
}

output "logicAppUrl" {
  value = azurerm_template_deployment.example.outputs["logicAppUrl"]
}