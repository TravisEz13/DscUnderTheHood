[String] $moduleRoot = Split-Path -Parent $Script:MyInvocation.MyCommand.Path
Register-PSRepository -Name xDscDiagnostics -SourceLocation https://ci.appveyor.com/nuget/xDscDiagnostics -ErrorAction SilentlyContinue
Install-Module xDscDiagnostics -Repository xDscDiagnostics -force


configuration Example
{
  log example
  {
    message='example'
  }
  Script NotInDesiredStateExample
  {
    GetScript = { return @{}}
    TestScript =  { return $false}
    SetScript = {throw }
  }
  LocalConfigurationManager{
      ConfigurationMode = 'ApplyOnly'
  }
}

example
Set-DscLocalConfigurationManager .\Example
Start-DscConfiguration .\Example -Wait

import-module "$moduleroot\modules\startdemo\startdemo.psd1" -force -Scope Global