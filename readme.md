# Presentation Recording
[PowerShell Summit 2016 North America](https://www.youtube.com/watch?v=eGrOp-p4gOM&index=15&list=PLfeA8kIs7Coc1Jn5hC4e_XgbFUaS5jY2i)

#  Machine setup
First run setup with reboot, this will clear any history so it must be done first.
Note: ** It will automatically reboot the machine **
```PowerShell
'.\Setup.ps1 -reboot
```

After that is finished, run the second setup:
Note:  this may tell you that reboot setup is not finished, just wait a little bit and run it again.
```PowerShell
'.\Setup.ps1 
```

# Prep for demo
First run the following in the same powershell windows before running a demo 
```PowerShell
'.\init.ps1
```

## running the Get-DscConfigurationStatus demo

```PowerShell
cd .\GetDscConfigurationStatus
Start-Demo
```

## running the Encryption demo

```PowerShell
cd .\Encryption
Start-Demo
```
