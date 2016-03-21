# Credential encryption examples
# review the configuration
ise .\EncryptedCredential.psm1

#import the configuration
import-module .\EncryptedCredential.psm1 -force

# Compile the meta configuration
EncryptedCredentialMeta

# Set the LCM to use the meta
Set-DscLocalConfigurationManager -path .\EncryptedCredentialMeta

# Compile the configuration
EncryptedCredential -ConfigurationData (Get-EncryptedCredentialConfigurationData) -runAsCredential (Get-Credential)

# Review the contents of the mof sent to LCM
notepad ".\EncryptedCredential\localhost.mof"

# Start the configuration
start-dscconfiguration .\EncryptedCredential -wait -verbose -force 

# Review the contents of the MOF the LCM stored
Get-content "$env:windir\system32\configuration\current.mof"
