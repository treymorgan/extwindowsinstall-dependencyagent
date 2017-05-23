#region Comments
<#
#requires -version 3

.SYNOPSIS
  The following script will install the Microsoft Windows Dependency Agent 

.DESCRIPTION
  This script is used in combination with an ARM Custom Script Extension deployment to install the Microsoft Dependency Agent for Windows

.LOCATION
The following script is located here: https://raw.githubusercontent.com/treymorgan/extwindowsinstall-dependencyagent/master/Install-MicrosoftWindowsDependencyAgent.ps1 


#>
#endregion

#region Login to Azure
#Obtains the environment for Public Azure and add it to a variable
#$env = Get-AzureRMEnvironment -Name AzureCloud

#Login to Azure
#Add-AzureRMAccount -EnvironmentName $env
#Change to the relevant Subscription
#Select-AzureRmSubscription -SubscriptionName "Azure Subscription 1" -TenantId "XXXX"
#endregion

#region Declare Variables
#Declare Variables for the script
cls
$results = $null
$ExtensionName
$Location = "East US"
$URLofPSInstallScript = "https://raw.githubusercontent.com/treymorgan/extwindowsinstall-dependencyagent/master/Install-MicrosoftWindowsDependencyAgent.ps1"
$PSInstallScriptName = "Install-MicrosoftWindowsDependencyAgent.ps1"
$ExtensionName = 'DependencyAgentWindows'
#endregion

#region obtain list of servers with cooresponding resource groups
#Get list of servers and group names from a csv file
$serversrgrouplist = Import-Csv -LiteralPath C:\temp\ServerList.csv
#endregion

#region Function to install the Dependency agent using a list of servers and resource groups in a csv file
Function Install-DependencyAgent {

#Loop through the list of servers and groups and install the oms agent
foreach ($serverrgroup in $serversrgrouplist)  {

#convert the server name and group name into a variable
$VMName = $serverrgroup.Computer
$RGName = $serverrgroup.RGroup

Try
{
#Deploys the ARM Custom Script Extension to install the Microsoft Dependency Agent for Windows
Set-AzureRmVMCustomScriptExtension -ResourceGroupName $RGName `
    -VMName $VMName `
    -Location $Location `
    -FileUri $URLofPSInstallScript `
    -Run $PSInstallScriptName `
    -Name $ExtensionName
 
}
Catch
{
 Throw $_
 exit 1
}

#capture extension execution results
$Installresults =  ((Get-AzureRmVM -Name $VMName -ResourceGroupName $RGName -Status).Extensions | Where-Object {$_.Name -eq $ExtensionName}).Substatuses
$Desplaystatus = $Installresults.DisplayStatus | Out-String
$Message = $Installresults.message | Out-String


         #custom object to be used for reporting
         $data = @{
         'Server' = $VMName
         'RGroup' = $RGName
         'DisplayStatus' = $Desplaystatus
         'Message' = $Message
                 }


        #Output the results
        $output =  New-Object -TypeName psobject -Property $data
        $output | Select-Object -Property Server,RGroup,DisplayStatus,Message | Export-Csv -Path C:\Temp\FinalResults.csv -Append -NoTypeInformation

}
}
#endregion

#region Start function

Install-DependencyAgent

#endregion

#region Uninstall Azure Extension
<#
#Removes the ARM Custom Script Extension that installs the Microsoft Dependency Agent for Windows

    remove-AzureRmVMCustomScriptExtension -ResourceGroupName deletemeresourcegp `
    -VMName 'awesomevmone' `
    -Name DependencyAgentWindows
#>
#endregion
