[DscLocalConfigurationManager()]
Configuration EncryptedCredentialMeta
{
    Settings 
    {
        CertificateID = $global:DscEncryptionCert.Thumbprint
    }
}


Configuration EncryptedCredential
{
    param(
        [PSCredential]
        $runAsCredential 
    )
    node localhost
    {
        Script DontRunAs
        {
            GetScript = {
                @{
                    LcmUsername = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
                }
            }
            TestScript = {
                Write-Verbose "LcmUsername: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name))" 
                return $true
            }
            SetScript = {
                        ##
                }
        }
        Script RunAs
        {
            GetScript = {
                @{
                    username = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
                }
            }
            TestScript = {
                Write-Verbose "username: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name))" 
                return $true
            }
            SetScript = {
                        #
                }
            PsDscRunAsCredential = $runAsCredential
        }
        
    }
}

function Get-EncryptedCredentialConfigurationData
{
    return @{ 
            AllNodes = @(
                @{
                    NodeName = 'localhost'
                    #CertificateFile = "$env:temp\DscPublicKey.cer"
                    CertificateId =  $global:DscEncryptionCert.Thumbprint
                }    
            )
        }
}