Remove-ResourceGroups Azure Automation Runbook
==============================================

This project contains an Azure Automation runbookfor removing resource groups
across Azure subscriptions using a combination of filters and rules. You can run
across multiple subscriptions, delete all resource groups, or run in preview
mode.

Using the Azure Automation Workflow
-----------------------------------

### Required Automation Assets

1.  An Automation credential asset called "AzureCredential" that contains the
    Azure AD user credential with authorization for targeted subscriptions.  
    To use an asset with a different name you can pass the asset name as a
    runbook input parameter or change the default value for the input parameter.

### Import the new runbook

1.  If you do not already have it, create an Azure Automation account.

2.  Create the AzureCredential asset and populate it with credentials that has
    permissions to the subscriptions you want to target.

3.  Import the Remove-ResourceGroups runbook

### Execute the runbook

The following parameters are available when starting the runbook

-   PARAMETER AzureCredentialAssetName Optional with default of
    "AzureCredential". The name of an Automation credential asset that contains
    the Azure AD user credential with authorization for this subscription.  
    To use an asset with a different name you can pass the asset name as a
    runbook input parameter or change the default value for the input parameter.

-   PARAMETER ActionType Mandatory. The specific action to take for either
    keeping assets that match the name filter and deleting everything else or
    deleting just those assets that match the name filter. Valid values are
    KEEP, DELETE, and DELETEALL.

    -   KEEP = Delete everything except resource groups that match the name
        filter

    -   DELETE = Delete only resource groups that match the name filter

    -   DELETEALL = Delete all resource groups

-   PARAMETER SubscriptionIds Mandatory Allows you to specify the targeted
    subscription id(s) for removal of resource groups.  
    Pass multiple subscripription ids through a comma separated list.

-   PARAMETER NameFilter Optional Allows you to specify a name filter to limit
    the resource groups that you will KEEP or DELETE. Pass multiple name filters
    through a comma separated list.  
    The filter is not case sensitive and will match any resource group that
    contains the string.

-   PARAMETER PreviewMode Optional with default of \$true. Execute the runbook
    to see which resource groups would be deleted but take no action.
