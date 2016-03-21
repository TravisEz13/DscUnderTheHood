[String] $moduleRoot = Split-Path -Parent $Script:MyInvocation.MyCommand.Path
Register-PSRepository -Name xDscDiagnostics -SourceLocation https://ci.appveyor.com/nuget/xDscDiagnostics -ErrorAction SilentlyContinue
Install-Module xDscDiagnostics -Repository xDscDiagnostics -force

Get-NetAdapter | %{Set-NetConnectionProfile  -InterfaceAlias $_.Name -NetworkCategory Private -erroraction SilentlyContinue}
Set-WSManQuickConfig -Force > $null

$env:psmodulePath = "$env:psmodulePath;$moduleroot\modules"
