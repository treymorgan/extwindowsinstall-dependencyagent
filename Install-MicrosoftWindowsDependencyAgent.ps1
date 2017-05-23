#requires -version 3
<#
.SYNOPSIS
  The following script will install the Microsoft Windows Dependency Agent 

.DESCRIPTION
  This script is used in combination with an ARM Custom Script Extension deployment to install the Microsoft Dependency Agent for Windows

.LOCATION
The following script is located here: https://raw.githubusercontent.com/treymorgan/extwindowsinstall-dependencyagent/master/Install-MicrosoftWindowsDependencyAgent.ps1 

#>

#Creates New Event Log Source if it does not already exist
New-EventLog -LogName Application -Source "MSDependencyAgent" -ErrorAction SilentlyContinue


#Script Variables
$TempDirectory = "C:\Temp\DependencyAgentWindows\"
$MSDependencyAgentMediaURL = "https://aka.ms/dependencyagentwindows"
$MediaFileName = $TempDirectory + "InstallDependencyAgent-Windows.exe"
$URLofPSInstallScript = "https://raw.githubusercontent.com/treymorgan/extwindowsinstall-dependencyagent/master/Install-MicrosoftWindowsDependencyAgent.ps1"
$PSInstallScriptName = $TempDirectory + "Install-MicrosoftWindowsDependencyAgent.ps1"

#Create temporary directory to store the script and installation media
New-Item $TempDirectory -type directory -Force

#Download the Microsoft Dependency Agent Media and store it in the temporary location specified above
Invoke-WebRequest -Uri $MSDependencyAgentMediaURL  -OutFile $MediaFileName 

#Download the PowerShell script that installs the agent
Invoke-WebRequest -Uri $URLofPSInstallScript -OutFile $PSInstallScriptName

#Swith directories to the location where the PowerShell script and installation media are stored
Set-Location -Path $TempDirectory

#Peform a Silent installation of the Microsoft Dependency Agent
./InstallDependencyAgent-Windows.exe /S

#Check Microsoft Dependency Agent Status
$MicrosoftDependencyAgentServiceStatus = Test-Path -Path "C:\Program Files\Microsoft Dependency Agent\bin\MicrosoftDependencyAgent.exe"

#sleep for 1 min
Start-Sleep -Seconds 60

#Log an event in the windows application event log indicating the success of failure of the agent installation (this can be picked up by OMS)
If ($MicrosoftDependencyAgentServiceStatus.count -gt 0) {
$MicrosoftDependencyAgentServiceStatusStatus = $MicrosoftDependencyAgentServiceStatus.Status
$Message =  "The Microsoft Dependency Agent is installed" | Out-String

Write-EventLog -LogName Application -Source "MSDependencyAgent" -EntryType Information -EventID 1 -Message $Message 
}

Else {

$Message =  "The Microsoft Dependency Agent was not detected or an error occurred while attempting to detect the agent service" | Out-String

Write-EventLog -LogName Application -Source "MSDependencyAgent" -EntryType Warning -EventID 2 -Message $Message 
}

#remove the install media
$FilePath = $TempDirectory + "InstallDependencyAgent-Windows.exe"
Remove-Item $FilePath -Force
