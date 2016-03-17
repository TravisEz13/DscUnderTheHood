param(
    [switch]
    $reboot
)
[String] $moduleRoot = Split-Path -Parent $Script:MyInvocation.MyCommand.Path
Register-PSRepository -Name xDscDiagnostics -SourceLocation https://ci.appveyor.com/nuget/xDscDiagnostics -ErrorAction SilentlyContinue
Install-Module xDscDiagnostics -Repository xDscDiagnostics -force

Get-NetAdapter | %{Set-NetConnectionProfile  -InterfaceAlias $_.Name -NetworkCategory Private}
Set-WSManQuickConfig -Force

$name = "Example"
If($reboot)
{
    del C:\WINDOWS\System32\Configuration\ConfigurationStatus\*
    $name +="Reboot"
}

configuration $name
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
  if($reboot)
  {
    Script Reboot
    {
        GetScript = { return @{}}
        TestScript =  { return (Test-path $env:SystemDrive\rebooted.txt)}
        SetScript = {
            $global:DSCMachineStatus = 1 
            ''|Out-File $env:SystemDrive\rebooted.txt 
        }
    }      
  }
  LocalConfigurationManager{
      ConfigurationMode = 'ApplyOnly'
      RebootNodeIfNeeded = $true
  }
}

&$name
Set-DscLocalConfigurationManager .\$name
Start-DscConfiguration .\$name -Wait -force

Remove-DscConfigurationDocument -Stage Pending
Remove-DscConfigurationDocument -Stage Current

$env:psmodulePath = "$env:psmodulePath;$moduleroot\modules"
