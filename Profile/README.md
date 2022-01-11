# Profile Management

This is to configure a PowerShell profile. Select which one you want and enable transcript for it.
<img width="357" alt="image" src="https://user-images.githubusercontent.com/71237527/148556584-1a80eca0-03b4-44b3-aabd-907dd5c7410f.png">


## Project Goals
The objective is to configure your terminal to keep in mind where you are connected.
* Config.json
* Microsoft.Powershell_Profile.ps1
* Powershell-Profile.psm1

## Config.json
Contains the path of transcript file.
Contains each profile you want to propose. For each profile, configure UPN, default path, privilege or role of account, color for this profile.
Example (PowerShell 5): C:\Users\myprofile\Documents\WindowsPowershell.
Example (PowerShell 7): C:\Users\myprofile\Documents\Powershell.
![image](https://user-images.githubusercontent.com/94542446/149010446-99063b0e-86cf-470d-acd9-286c383befec.png)


## Microsoft.Powershell_Profile
### Current Version
**Version: 0.1**

### History
- Sept 16, 2021: Creation

### Using the script
Copy this file to your Powershell profile path.

## Powershell-Profile.psm1
### Current Version
**Version: 0.2**

### History
- Dec 12, 2021: Add Exchange connection and functions for Exchange
- Sept 16, 2021: Creation


### Using the script
Copy this file to a new folder named "Powershell-Profile" under module folder of your powershell profile.
Example (PowerShell 5): C:\Users\myprofile\Documents\WindowsPowershell\Modules\Powershell-Profile.
Example (PowerShell 7): C:\Users\myprofile\Documents\Powershell\Modules\Powershell-Profile.

## How to use
### Function LoadProfile
To load your profile, execute "loadprofile" command let and select your profile.
```PowerShell
loadprofile
```

### Function StartTranscript
To start transcript. The transcript file will be under the path you specified in json file.
```PowerShell
starttranscript
```

### Function StopTranscript
To stop transcript. The transcript file will be under the path you specified in json file.
```PowerShell
stoptranscript
```

### Function ConnectAAD
To connect to AAD with your UPN.
```PowerShell
ConnectAAD
```

### Function ConnectEXO
To connect to EXO.
```PowerShell
ConnectEXO
```

### Function DisconnectEXO
To disconnect to EXO
```PowerShell
DisconnectEXO
```

## Exchange
### Function Get-ModernAuth
To disconnect to EXO
```PowerShell
Get-ModernAuth
```

### Function Get-AuthPolicies
To disconnect to EXO
```PowerShell
Get-AuthPolicies
```

### Function Disable-BasicAuth
To disconnect to EXO
```PowerShell
Disable-BasicAuth
```

## Credits
Mathias Dumont


