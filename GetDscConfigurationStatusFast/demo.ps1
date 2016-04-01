# Initial setup
import-module xDscDiagnostics

# Get configuration status for all operations
Get-DscConfigurationStatus -all

# Get the status of the last configuration
$status = @(Get-DscConfigurationStatus -all).where{$_.Type -eq 'Initial'} | Select-Object -First 1

# display the status
$status

# dispaly all the properities of the status 
# MetaData: Information about the configuration compilation
# JobId: Associates tasks started by the same action
# Type: Initial, Reboot, Consistency
$status | fl *

# show the Resource details

$status.ResourcesInDesiredState

# get the status for a failed example

$status = @(Get-DscConfigurationStatus -all | sort-object -property startdate).where{$_.Status -eq 'Failure'} | Select-Object -First 1

# Show resource not in derised state
$status.ResourcesNotInDesiredState

# get the verbose details of the status
# using Get-XDscConfigurationDetail from xDscDiagnostics
Write-Verbose -Message "JobId: $($status.JobId)" -Verbose
$status | Get-XDscConfigurationDetail -Verbose
