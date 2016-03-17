#Initial setup
import-module xDscDiagnostics

# Get the status of the last configuration
$status = get-dscconfigurationstatus

# display the status
$status

# dispaly all the properities of the status 
$status | fl *

# show the meta configuration
$status.MetaConfiguration

# Show resource not in derised state
$status.ResourcesNotInDesiredState

# get the verbose details of the status
$status | Get-XDscConfigurationDetail -Verbose

@(Get-DscConfigurationStatus -all).where{$_.Type -eq 'Reboot'} | Get-XDscConfigurationDetail -Verbose 