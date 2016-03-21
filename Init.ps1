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
    $cert = New-SelfSignedCertificate -Type DocumentEncryptionCert -KeyUsage @('KeyEncipherment', 'DataEncipherment') -DnsName 'DscEncryptionCert'                                                                                 
    $cert |Export-Certificate -FilePath "$env:temp\DscPublicKey.cer"                                                                                                                                                               
    Import-Certificate -FilePath "$env:temp\DscPublicKey.cer" -CertStoreLocation Cert:\LocalMachine\Root
    $global:DscEncryptionCert = $cert
}