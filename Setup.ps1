param(
    [switch]
    $reboot
)
$errorActionPreference = 'Stop'
[String] $moduleRoot = Split-Path -Parent $Script:MyInvocation.MyCommand.Path
Register-PSRepository -Name xDscDiagnostics -SourceLocation https://ci.appveyor.com/nuget/xDscDiagnostics -ErrorAction SilentlyContinue
Install-Module xDscDiagnostics -Repository xDscDiagnostics -force

Get-NetAdapter | %{Set-NetConnectionProfile  -InterfaceAlias $_.Name -NetworkCategory Private}
Set-WSManQuickConfig -Force
$rebootFile = "$env:SystemDrive\rebooted.txt"
$failOnceFile = "$env:SystemDrive\failed.txt"
if(!$reboot -and @(Get-DscConfigurationStatus -all).where{$_.type -eq 'reboot'}.Status -ne 'Success')
{
    throw 'Reboot example has not been setup'
}

$name = "Example"
If($reboot)
{
    del $rebootFile -ErrorAction SilentlyContinue
    
    $name +="Reboot"
}
del $failOnceFile -ErrorAction SilentlyContinue

configuration $name
{
  log example
  {
    message='example'
  }
  Script NotInDesiredStateExample
  {
    GetScript = { return @{}}
    TestScript =  { return (Test-path $using:failOnceFile)}
    SetScript = {
        ''|Out-File $using:failOnceFile
        throw 
    }
  }
  if($reboot)
  {
    Script Reboot
    {
        GetScript = { return @{}}
        TestScript =  { return (Test-path $using:rebootFile)}
        SetScript = {
            $global:DSCMachineStatus = 1 
            ''|Out-File $using:rebootFile
        }
    }      
  }
  LocalConfigurationManager{
      ConfigurationMode = 'ApplyOnly'
      RebootNodeIfNeeded = $true
  }
}

&$name
if($reboot)
{
    Set-DscLocalConfigurationManager .\$name
    del "$env:windir\System32\Configuration\ConfigurationStatus\*" -ErrorAction SilentlyContinue
}
Start-DscConfiguration .\$name -Wait -force -ErrorAction SilentlyContinue

# Remove-DscConfigurationDocument -Stage Pending
# Remove-DscConfigurationDocument -Stage Current

$env:psmodulePath = "$env:psmodulePath;$moduleroot\modules"
