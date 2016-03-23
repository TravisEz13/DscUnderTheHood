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
    $username = $runAsCredential.GetNetworkCredential().UserName 
    Import-DscResource -ModuleName xPSDesiredStateConfiguration    
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    
    node localhost
    {
        # Script resource running as LCM
        # not using credentials
        User testUser
        {
            Ensure = 'Present'
            UserName = $runAsCredential.GetNetworkCredential().UserName
            PasswordChangeRequired = $false
            PasswordChangeNotAllowed = $true
            Disabled = $false
            Password = $runAsCredential
        }
        Script DontRunAs
        {
            GetScript = {
                # LCM Username
                @{
                    Result = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
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
                # RunAs Username
                @{
                    Result = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
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
                    PSDscAllowDomainUser = $true
                }    
            )
        }
}

function Resolve-Uri
{
    [CmdletBinding()]
    param (
        [Uri] $uri
    )

    $response = $null
    try
    {  
        $response = Invoke-WebRequest -uri $uri -UseBasicParsing -MaximumRedirection 0 -Method Head -ErrorAction ignore
    }
    catch
    {
        try
        {
            $response = Invoke-WebRequest -uri $uri -UseBasicParsing -MaximumRedirection 0 -ErrorAction Ignore -Method Get
        }
        catch
        {
            return $null
        }
    }
    if($response.StatusCode -eq 200)
    {
        return $uri
    }
    elseif($response.StatusCode -eq 302)
    {
        Resolve-Uri -uri $response.Headers.Location
    }
    else
    {
        throw "Could not resolve uri: $($uri.AbsoluteUri)"
    }
}