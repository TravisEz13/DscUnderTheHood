[String] $moduleRoot = Split-Path -Parent $Script:MyInvocation.MyCommand.Path
Register-PSRepository -Name xDscDiagnostics -SourceLocation https://ci.appveyor.com/nuget/xDscDiagnostics -ErrorAction SilentlyContinue
Install-Module xDscDiagnostics -Repository xDscDiagnostics -force

Get-NetAdapter | %{Set-NetConnectionProfile  -InterfaceAlias $_.Name -NetworkCategory Private -erroraction SilentlyContinue}
Set-WSManQuickConfig -Force > $null

$env:psmodulePath = "$env:psmodulePath;$moduleroot\modules"

$cert = @(dir Cert:\LocalMachine\My).where{$_ |Test-Certificate -EKU @('1.3.6.1.4.1.311.80.1') -DNSName DscEncryptionCert -ErrorAction SilentlyContinue -WarningAction SilentlyContinue }
if($cert.Count -ge 1)
{
    $global:DscEncryptionCert = $cert
}
else {
    <#$rootCert = New-SelfSignedCertificate  -Type Custom -DnsName 'DscEncryptionSelfSignedCa' -CertStoreLocation Cert:\LocalMachine\my -KeyUsage CertSign -Provider "Microsoft RSA SChannel Cryptographic Provider"
    $cert = New-SelfSignedCertificate -Type DocumentEncryptionCert -DnsName 'DscEncryptionCert' -Signer $rootCert#>
    $cert = New-SelfSignedCertificate -Type DocumentEncryptionCert -DnsName 'DscEncryptionCert' -Provider "Microsoft RSA SChannel Cryptographic Provider"
    $cert | Export-Certificate -FilePath "$env:temp\DscPublicKey.cer"  -Force                                                              
    #$rootCert |Export-Certificate -FilePath "$env:temp\DscCaPublicKey.cer"  -Force                                                                                                                                                             
    Import-Certificate -FilePath "$env:temp\DscPublicKey.cer" -CertStoreLocation Cert:\LocalMachine\Root > $null
    $global:DscEncryptionCert = $cert
    
    <#if(!($cert|Test-Certificate -EKU @('1.3.6.1.4.1.311.80.1') -DNSName DscEncryptionCert))#>
    if(!($cert.Verify()))
    {
        throw 'certificate setup failed'
    } 
}