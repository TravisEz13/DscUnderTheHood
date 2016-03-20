# Initial setup
import-module xDscDiagnostics

# Get configuration status for all operations
Get-DscConfigurationStatus -all

# Get the status of the last configuration
$status = @(Get-DscConfigurationStatus -all).where{$_.Type -eq 'Initial'} | Select-Object -First 1

# display the status
$status

# dispaly all the properities of the status 
$status | fl *

# show the meta configuration
$status.MetaConfiguration

# get the verbose details of the status
Write-Verbose -Message "JobId: $($status.JobId)" -Verbose
$status | Get-XDscConfigurationDetail -Verbose

# Show all the files backing Get-ConfigurationStatus for this job
dir "C:\WINDOWS\System32\Configuration\ConfigurationStatus\$($status.JobId)*"

# get the status for a reboot example
$status = @(Get-DscConfigurationStatus -all).where{$_.Type -eq 'Reboot'}  

# get the verbose details for the reboot example
Write-Verbose -Message "JobId: $($status.JobId)" -Verbose
$status | Get-XDscConfigurationDetail -Verbose 

# get the status for a failed example
$status = @(Get-DscConfigurationStatus -all).where{$_.Status -eq 'Failure'}  

# Show resource not in derised state
$status.ResourcesNotInDesiredState
