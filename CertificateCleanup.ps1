@(dir Cert:\LocalMachine\my).where{$_.Subject -match '^CN=DscEncryption'} | Remove-Item
@(dir Cert:\LocalMachine\root).where{$_.Subject -match '^CN=DscEncryption'} | Remove-Item