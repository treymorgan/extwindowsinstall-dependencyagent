mkdir c:\Temp2\dependencyagentwindows -Force
Invoke-WebRequest -Uri "https://aka.ms/dependencyagentwindows" -OutFile "c:\Temp2\dependencyagentwindows\InstallDependencyAgent-Windows.exe" 

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/treymorgan/extwindowsinstall-dependencyagent/master/Install-MicrosoftWindowsDependencyAgent.ps1" -OutFile "c:\Temp2\dependencyagentwindows\Install-MicrosoftWindowsDependencyAgent.ps1" 

cd c:\Temp2\dependencyagentwindows
./InstallDependencyAgent-Windows.exe /S
