<properties
   pageTitle="Remove-ResourceGroups Azure Automation Runbook"
   description="This Azure Automation runbook can be used for removing resource groups across Azure subscriptions using a combination of filters and rules. You can run across multiple subscriptions, delete all resource groups, or run in preview mode."
   services="automation"
   documentationCenter=""
   authors="nwcadence"
   manager=""
   editor=""/>

<tags
   ms.service="automation"
   ms.devlang="na"
   ms.topic="article"
   ms.tgt_pltfrm="na"
   ms.workload="infrastructure-services"
   ms.date="05/11/2016"
   ms.author="TechNet@nwcadence.com"/>

# Remove-ResourceGroups Azure Automation Runbook

Follow these steps to import and use the Remove-ResourceGroups Azure Automation Runbook 

>[AZURE.WARNING] Use caution when using this runbook and take advantage of the "PreviewMode" to verify what will be automatically deleted.

## Choose an Authentication Type
The runbook works with both an AAD Credential (Automation Credential) and an AAD Service Principal (Automation Connection).  The AAD Service Principal is a prefered option as it uses certificate authentication instead of a password that may expire.

### Create Azure Automation credential asset
Create an [Azure Automation credential asset](automation-credentials.md) called that contains the Azure AD user account with permissions to any targeted subscriptions.  

To use a credential asset with a different name you can pass the asset name as a runbook input parameter or change the default value for the input parameter.

### Create Azure Automation connection asset
The easiest way to create a new Service Principal connection is to do so when creating a new Azure Automation resource. Follow this guide to create a [run as account] (https://azure.microsoft.com/en-us/documentation/articles/automation-sec-configure-azure-runas-account/).

Once the Service Principal connection is added as an Azure Automation asset, it should be granted permission to other targeted subscriptions.


## Import the runbook from the Runbook Gallery

The easiest way to get started with this runbook is to import it from the Runbook Gallery in the [TechNet Script Center](http://gallery.technet.microsoft.com/).

Follow the instructions to [Import a runbook from the Runbook Gallery with the Azure portal](runbooks-in-runbook-gallery.md).

You can find this runbook under the name [Azure Automation - Remove Resource Groups] (https://gallery.technet.microsoft.com/scriptcenter/Azure-Automation-Remove-7581144c).


## Execute the runbook

To trigger the runbook you can follow one of the many documented ways here: [Starting a runbook](automation-starting-a-runbook.md)

The following parameters are available when starting the runbook:

-   PARAMETER AuthenticationType (Mandatory)
	The type of authentication to use for connection to Azure subscriptions.
	Valid values are AADCREDENTIAL and SERVICEPRINCIPAL.
    - AADCREDENTIAL = Automation credential asset using an Azure AD user credential
    - SERVICEPRINCIPAL = Automation connection asset using an Azure AD service principal

-   PARAMETER AuthenticationAssetName (Mandatory)
    The name of an authentication asset with authorization for this subscription. 

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

-   PARAMETER PreviewMode Optional with default of $true. Execute the runbook
    to see which resource groups would be deleted but take no action.


## Next Steps
-   To get started with creating your own runbook, see [Creating or importing a runbook in Azure Automation](automation-creating-importing-runbook.md)
-	To get started with PowerShell workflow runbooks, see [My first PowerShell workflow runbook](automation-first-runbook-textual.md)

