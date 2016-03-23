# Credential encryption examples
# review the configuration
ise .\EncryptedCredential.psm1

#import the configuration
import-module .\EncryptedCredential.psm1 -force

# Compile the meta configuration
EncryptedCredentialMeta

# Set the LCM to use the meta
Set-DscLocalConfigurationManager -path .\EncryptedCredentialMeta -force

# Review the contents of the MOF the LCM stored
notepad "$env:windir\system32\configuration\MetaConfig.mof"

# Compile the configuration
EncryptedCredential -ConfigurationData (Get-EncryptedCredentialConfigurationData) -runAsCredential (Get-Credential -UserName "$env:computername\testuser" -message 'enter config credentials')

# Review the contents of the mof sent to LCM
notepad ".\EncryptedCredential\localhost.mof"

# Start the configuration
start-dscconfiguration .\EncryptedCredential -wait -verbose -force 

# Run Get dsc configuration 
Get-DscConfiguration | select resourceid, result

# Delete the user
net user testUser /delete

# Review the contents of the MOF the LCM stored
notepad "$env:windir\system32\configuration\current.mof"
