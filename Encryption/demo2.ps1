
#EncryptedAtRest Example
get-content .\EncryptedAtRestConfiguration.psm1
import-module .\EncryptedAtRestConfiguration.psm1 -force

EncryptedAtRest

start-dscconfiguration .\EncryptedAtRest -wait -verbose -force

Get-content "$env:windir\system32\configuration\current.mof"