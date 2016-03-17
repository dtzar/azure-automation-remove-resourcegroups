<# 
.SYNOPSIS 
  Connects to Azure and removes all resource groups which match the name filter
 
.DESCRIPTION 
  This runbook connects to Azure and removes all resource groups which match the name filter. 
  You can run across multiple subscriptions, delete all resource groups, or run in preview mode. 
 
  REQUIRED AUTOMATION ASSETS  
  1. An Automation credential asset called "AzureCredential" that contains the Azure AD user credential with authorization for targeted subscriptions.  
     To use an asset with a different name you can pass the asset name as a runbook input parameter or change the default value for the input parameter. 
 
.PARAMETER AzureCredentialAssetName 
   Optional with default of "AzureCredential". 
   The name of an Automation credential asset that contains the Azure AD user credential with authorization for this subscription.  
   To use an asset with a different name you can pass the asset name as a runbook input parameter or change the default value for the input parameter. 
 
.PARAMETER ActionType 
   Mandatory. 
   The specific action to take for either keeping assets that match the name filter and deleting everything else or deleting just those assets that match the name filter. 
   Valid values are KEEP, DELETE, and DELETEALL.
    - KEEP = Delete everything except resource groups that match the name filter
	- DELETE = Delete only resource groups that match the name filter
	- DELETEALL = Delete all resource groups
 
.PARAMETER SubscriptionIds 
   Mandatory 
   Allows you to specify the targeted subscription id(s) for removal of resource groups.   
   Pass multiple subscripription ids through a comma separated list.   
 
.PARAMETER NameFilter 
   Optional 
   Allows you to specify a name filter to limit the resource groups that you will KEEP or DELETE.
   Pass multiple name filters through a comma separated list.     
   The filter is not case sensitive and will match any resource group that contains the string.   
 
.PARAMETER PreviewMode 
   Optional with default of $true. 
   Execute the runbook to see which resource groups would be deleted but take no action.  
#> 

workflow Remove-ResourceGroups
{
    param(
		[Parameter(Mandatory=$false)]  
		[string]  $AzureCredentialAssetName = 'AzureCredential', 
		
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('KEEP', 'DELETE', 'DELETEALL')]
        [string]$ActionType,

        [parameter(Mandatory=$true)]
        [string]$SubscriptionIds,

        [parameter(Mandatory = $false)]
        [string]$NameFilter,
		
        [parameter(Mandatory = $false)]
        [bool]$PreviewMode = $true
    )


    # Returns strings with status messages 
    [OutputType([String])]
	
	$VerbosePreference = 'Continue'
	
	[regex]$actionTypeRegex = 'KEEP|DELETE|DELETEALL'
	if ($ActionType.ToUpper() -notmatch $actionTypeRegex) {
		throw "ActionType not valid, valid actions are KEEP, DELETE, and DELETEALL"
	}
 
    # Connect to Azure and select the subscription to work against
    $creds = Get-AutomationPSCredential -Name $AzureCredentialAssetName
 
    $null = Login-AzureRmAccount -Credential $creds -ErrorVariable err 
    if($err) { 
		throw "Failed to log in to Azure RM. $err"
    } 
 
	# Parse subscription id list and name filter list
    $subscriptionIdList = $SubscriptionIds.Split(',')
	if ($NameFilter) {
		$nameFilterList = $NameFilter.Split(',')
		[regex]$nameFilterRegex = ‘(‘ + (($nameFilterList | foreach {[regex]::escape($_.ToLower())}) –join “|”) + ‘)’
	}

	# Begin loop through each subscription
    foreach ($subscriptionId in $subscriptionIdList) {
		try {
			# Select the subscription, if not found, skip resource group removal
			Write-Output "Attempting connection to subscription: $subscriptionId"
			Select-AzureRMSubscription -SubscriptionId $subscriptionId -ErrorAction Stop -ErrorVariable err
			if($err) { 
				Write-Error "Subscription not found: $subscriptionId."
				throw $err
			}
			else {
				Write-Output "Successful connection to subscription: $subscriptionId"
				# Find resource groups to remove based on passed in name filter and KEEP, DELETE, or DELEETALL action
				if ($ActionType.ToUpper() -eq 'KEEP') {
					$groupsToRemove = Get-AzureRmResourceGroup | `
									? { -not $_.ResourceGroupName.StartsWith('Default-') } |`
									? { $nameFilterList.Count -eq 0 -or $_.ResourceGroupName.ToLower() -notmatch $nameFilterRegex }
				}
				elseif ($ActionType.ToUpper() -eq 'DELETE') {
					$groupsToRemove = Get-AzureRmResourceGroup | `
									? { -not $_.ResourceGroupName.StartsWith('Default-') } |`
									? { $nameFilterList.Count -eq 0 -or $_.ResourceGroupName.ToLower() -match $nameFilterRegex }
				}
				elseif ($ActionType.ToUpper() -eq 'DELETEALL') {
					$groupsToRemove = Get-AzureRmResourceGroup | `
									? { -not $_.ResourceGroupName.StartsWith('Default-') }
				}
		
				# No matching groups were found to remove
				if ($groupsToRemove.Count -eq 0) {
					Write-Output "No matching resource groups found for subscription: $($subscriptionId)"
				}
				# Matching groups were found to remove
				else
				{
					# In preview mode, output what would take place but take no action
					if ($PreviewMode -eq $true) {
						Write-Output "Preview Mode: The following resource groups would be removed for subscription: $($subscriptionId)"
						Write-Output $groupsToRemove
						Write-Verbose "Preview Mode (VERBOSE): The following resources would be removed:"
						$resources = (Get-AzureRmResource | foreach {$_} | Where-Object {$groupsToRemove.ResourceGroupName.Contains($_.ResourceGroupName)})
						foreach ($resource in $resources) {
							Write-Verbose $resource
						}
					}
					# Remove the resource groups in parallel
					else {
						Write-Output "Preparing to remove resource groups in parallel for subscription: $($subscriptionId)"
						Write-Verbose "(VERBOSE): The following resources will be removed:"
						$resources = (Get-AzureRmResource | foreach {$_} | Where-Object {$groupsToRemove.ResourceGroupName.Contains($_.ResourceGroupName)})
						foreach ($resource in $resources) {
							Write-Verbose $resource
						}
						foreach -parallel ($resourceGroup in $groupsToRemove) {
							Write-Output "Starting to remove resource group: $($resourceGroup.ResourceGroupName)"
							Remove-AzureRmResourceGroup -Name $($resourceGroup.ResourceGroupName) -Force
							if ((Get-AzureRmResourceGroup -Name $($resourceGroup.ResourceGroupName) -ErrorAction SilentlyContinue) -eq $null) {
								Write-Output "...successfully removed resource group: $($resourceGroup.ResourceGroupName)"
							}				
						}
					}
					Write-Output "Completed."
				}
			}
		}
		catch {
			$errorMessage = $_
		}
		if ($errorMessage) {
			Write-Error $errorMessage
		}
    }
}