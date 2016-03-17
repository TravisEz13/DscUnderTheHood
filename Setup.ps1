param(
    [switch]
    $reboot
)
$errorActionPreference = 'Stop'
. .\Init.ps1
$rebootFile = "$env:SystemDrive\rebooted.txt"
$failOnceFile = "$env:SystemDrive\failed.txt"
if(!$reboot -and @(Get-DscConfigurationStatus -all).where{$_.type -eq 'reboot'}.Status -ne 'Success')
{
    throw 'Reboot example has not been setup'
}
if(!$reboot -and @(Get-DscConfigurationStatus -all).where{$_.type -eq 'Initial'}.Count -ge 2)
{
    throw 'Non-Reboot example has been setup'
}

$name = "Example"
If($reboot)
{
    del $rebootFile -ErrorAction SilentlyContinue
    del $failOnceFile -ErrorAction SilentlyContinue    
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

