#requires -version 3
<#
.SYNOPSIS
  The following script will install the Microsoft Windows Dependency Agent 

.DESCRIPTION
  <Brief description of script>

#>

$TempDirectory = "C:\Temp2\DependencyAgentWindows\"
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
