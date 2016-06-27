Remove-ResourceGroups Azure Automation Runbook
==============================================

This project contains an Azure Automation runbookfor removing resource groups
across Azure subscriptions using a combination of filters and rules. You can run
across multiple subscriptions, delete all resource groups, or run in preview
mode.

Using the Azure Automation Workflow
-----------------------------------
### Required Automation Assets

    Authorization to targeted Azure subscriptions using one of the following options:
        1. An Automation credential asset that contains the Azure AD user credential.
        2. An Automation connection asset that contains the Azure AD service principal.

### Import the new runbook

1.  If you do not already have it, create an Azure Automation account.

2.  Create the AzureCredential asset and populate it with credentials that has
    permissions to the subscriptions you want to target.

3.  Import the Remove-ResourceGroups runbook

### Execute the runbook

The following parameters are available when starting the runbook
-   PARAMETER AuthenticationType (Mandatory)
	The type of authentication to use for connection to Azure subscriptions.
	Valid values are AADCREDENTIAL and SERVICEPRINCIPAL.
    - AADCREDENTIAL = Automation credential asset using an Azure AD user credential
    - SERVICEPRINCIPAL = Automation connection asset using an Azure AD service principal

-   PARAMETER AuthenticationAssetName (Mandatory)
	The name of an authentication asset with authorization for this subscription. 

-   PARAMETER ActionType (Mandatory) 
	The specific action to take for either keeping assets that match the name 
	filter and deleting everything else or deleting just those assets that match 
	the name filter. Valid values are KEEP, DELETE, and DELETEALL.

    -   KEEP = Delete everything except resource groups that match the name filter
    -   DELETE = Delete only resource groups that match the name filter
    -   DELETEALL = Delete all resource groups

-   PARAMETER SubscriptionIds (Mandatory) 
	Allows you to specify the targeted subscription id(s) for removal of resource groups.  
    Pass multiple subscripription ids through a comma separated list.

-   PARAMETER NameFilter (Optional) 
	Allows you to specify a name filter to limit the resource groups that you 
	will KEEP or DELETE. Pass multiple name filters through a comma separated list.  
    The filter is not case sensitive and will match any resource group that
    contains the string.

-   PARAMETER PreviewMode (Optional with default of \$true) 
	Execute the runbook to see which resource groups would be deleted but take no action.
