#requires -version 3
<#
.SYNOPSIS
  The following script will install the Microsoft Windows Dependency Agent 

.DESCRIPTION
  This script is used in combination with an ARM Custom Script Extension deployment to install the Microsoft Dependency Agent for Windows

.LOCATION
The following script is located here: https://raw.githubusercontent.com/treymorgan/extwindowsinstall-dependencyagent/master/Install-MicrosoftWindowsDependencyAgent.ps1 


#>


#Obtains the environment for Public Azure and add it to a variable
$env = Get-AzureRMEnvironment -Name AzureCloud

#Login to Azure
Add-AzureRMAccount -EnvironmentName $env


cls
#Declare Variables for the script
#$VMName = "awesomevmone"
#$RGName = "deletemeresourcegp"
$ExtensionName
$Location = "East US"
$URLofPSInstallScript = "https://raw.githubusercontent.com/treymorgan/extwindowsinstall-dependencyagent/master/Install-MicrosoftWindowsDependencyAgent.ps1"
$PSInstallScriptName = "Install-MicrosoftWindowsDependencyAgent.ps1"
$ExtensionName = 'DependencyAgentWindows'

#Get list of servers and group names from a csv file
$serversrgrouplist = Import-Csv -LiteralPath C:\temp\ServerList.csv

#Function to install the Dependency agent using a list of servers and resource groups in a csv file
Function Install-DependencyAgent {

#Loop through the list of servers and groups and install the oms agent
foreach ($serverrgroup in $serversrgrouplist)  {

#convert the server name and group name into a variable
$server = $serverrgroup.Name
$resourcegroup = $serverrgroup.rgroup

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
$Desplaystatus = $Installresults.DisplayStatus
$Message = $Installresults.message


         #custom object
         $data = @{
         'Server' = $server
         'RGroup' = $resourcegroup
         'DisplayStatus' = $Desplaystatus
         'Message' = $Message
                 }


           #Output the results
            New-Object -TypeName psobject -Property $data

}
}

$results = Install-DependencyAgent


<#
#Removes the ARM Custom Script Extension that installs the Microsoft Dependency Agent for Windows

    remove-AzureRmVMCustomScriptExtension -ResourceGroupName deletemeresourcegp `
    -VMName 'awesomevmone' `
    -Name DependencyAgentWindows
#>
