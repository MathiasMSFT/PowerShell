Function LoadProfile {
<#
.SYNOPSIS
Offering a tab to select which profile do you want to use.

.DESCRIPTION
Offering a tab to select which profile do you want to use.
To load different profile or switch profile

.EXAMPLE
PS> LoadProfile

.NOTES
....
#>
    Param(
        [Parameter(Mandatory=$false)][string]$TenantName
    )

    Try{
        stop-transcript|out-null
    }
    Catch [System.InvalidOperationException]{}

    ## Variables
    $UserName = [Environment]::UserName
    $PowershellProfilePath = (Get-Item $PROFILE.CurrentUserCurrentHost).PSParentPath

    ## Load JSON - MacOS
    $Profiles = Get-Content -Raw -Path "~/.local/share/powershell/Modules/Powershell-Profile/Config.json" | ConvertFrom-Json
    $Global:TranscriptFolder = $Profiles.TranscriptFolder

    If ($TenantName) {
        $Global:SelectedProfile = $Profiles.List | Where-Object TenantName -eq $TenantName
    } Else {
        $Global:SelectedProfile = $Profiles.List | Out-ConsoleGridView -OutputMode Single
    }

    # $Global:SelectedProfile = $Profiles.List | Out-ConsoleGridView -OutputMode Single
    If (($($SelectedProfile.Account).Count) -ne 1) {
        Write-Host "Select one option. Reload the function." -ForegroundColor Red
    } Else {

        #####################################################
        $Histo = (" Current : V0.4
        Powershell Profile $($SelectedProfile.TenantName)
        v0.1 - Creation - 2021-07-30 - Mathias Dumont
        v0.2 - New function - 2021-09-21 - Mathias Dumont
        v0.3 - New parameter TenantName - 2021-10-27 - Mathias Dumont / Steve Gauvin
        v0.4 - Adding list of functions in start display - 2021-10-27 - Mathias Dumont / Steve Gauvin
        v0.5 - Adding EXO function, MgGrapg connection and Managed Identity permission assignment - 2025-08-28 - Mathias Dumont
        ")
        #####################################################

        # ============ PSDefaultParameterValues =================
        $PSDefaultParameterValues['Export-CSV:Delimiter'] = ";"
        $PSDefaultParameterValues['Export-CSV:NoTypeInformation'] = $true
        $PSDefaultParameterValues['Export-CSV:Encoding'] = "Default"
    
        # ============ Alias ============
        New-Alias -Name gh  -Value Get-Help       -Description "glm"
        New-Alias -Name gmh -Value moreHelp       -Description "glm"

        # ============ Function ==============
        #--------------------------------------------------------------
        Function Histo {
            write-host $histo
        }
        # ============ Initialise Powershell ===========================
        cls
        "Loading..."
        (get-host).UI.RawUI.windowTitle = "Tenant $($SelectedProfile.TenantName)" 
        (get-host).privatedata.ErrorBackgroundColor = "darkblue"

        "Charging..."

        $host.PrivateData.ErrorForegroundColor = "green"

        ### To avoid to be prompted 2 times
        <#If ($TenantName) {
            $Global:SelectedProfile = $Profiles.List | Where-Object TenantName -eq $TenantName
        }
        Else {
            $Global:SelectedProfile = $Profiles.List | Out-ConsoleGridView -OutputMode Single
        }#>


        Write-Host -ForegroundColor yellow @"
Profil personalisé pour $($SelectedProfile.TenantName) - Bienvenue $UserName
===============================

        Tenant: $($Global:SelectedProfile.TenantName)
        Account: $($Global:SelectedProfile.Account)
        Role: $($Global:SelectedProfile.Role)

        Functions:
            - startTranscript
            - stopTranscript
            - ConnectAAD
            - InvokeScript
            - ConnectMgGraph
            - EXOHideGAL
            - EXOUserMailboxToSharedMailbox
            - EXOExtractPermissions
            - MIAssignment


===============================
       
Emplacement par défaut $($SelectedProfile.Folder)
Transcript sauvegardé dans $TranscriptFolder

Session démarrée à : $(get-date)
"@
        Write-Host -ForegroundColor yellow "Dernière modification du profile $($SelectedProfile.TenantName) :" (Get-Item "~/.local/share/powershell/Modules/Powershell-Profile/Powershell-Profile.psm1").LastWriteTime
        Set-Location -Path $($SelectedProfile.Folder)
    }
}
Function startTranscript() {
<#
.SYNOPSIS
Start transcript.

.DESCRIPTION
Start transcript.
Save datas to transcript file

.EXAMPLE
PS> startTranscript

.NOTES
....
#>
    $dte = (get-date).tostring()
    $dte = $dte -replace "[:\s/]","."
    start-transcript -path "$TranscriptFolder\$($SelectedProfile.TenantName)-$dte.txt"
}
Function ConnectAAD {
<#
.SYNOPSIS
Connect to Azure AD with UPN included in json file

.DESCRIPTION
Connect to Azure AD with UPN included in json file

.EXAMPLE
PS> Connect-AzureAD -AccountId $($SelectedProfile.Account)

.NOTES
....
#>
    Connect-AzureAD -AccountId $($SelectedProfile.Account)
}
Function ConnectMgGraph {
<#
.SYNOPSIS
Connect to Azure AD with UPN included in json file

.DESCRIPTION
Connect to Azure AD with UPN included in json file

.EXAMPLE
PS> Connect-AzureAD -AccountId $($SelectedProfile.Account)

.NOTES
....
#>
    Param (
        [Parameter(Mandatory=$false)][string[]]$Scopes
    )
    Connect-MgGraph -Scopes $Scopes -NoWelcome
    Get-MgContext
}
Function stopTranscript() {
<#
.SYNOPSIS
Stop transcript

.DESCRIPTION
stop-transcript

.EXAMPLE
PS> StopTranscript

.NOTES
....
#>
    stop-Transcript
}
Function InvokeScript {
<#
.SYNOPSIS
Invoke a script.

.DESCRIPTION
Invoke a script.
Execute a script stored somewhere (GitHub)

.EXAMPLE
PS> InvokeScript -Url ''

.NOTES
....
#>
param (
    [Parameter(Mandatory=$true, Position=0)]
    $Url
)


    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ScriptFromGitHub = Invoke-WebRequest $Url
    Invoke-Expression $($ScriptFromGitHub.Content)
}
Function GetDeviceCodeFlow {
    # Retrieve who does a DeviceCode flow
    Connect-MgGraph -Scopes AuditLog.Read.All
    Get-MgBetaAuditLogSignIn -Filter "AuthenticationProtocol eq 'deviceCode'"
}

Function EXOUserMailboxToSharedMailbox {
    param (
        [Parameter(Mandatory=$true, Position=0)]$UserPrincipalName
    )
    # Get session
    if (-not (Get-PSSession | Where-Object { $_.ComputerName -like "*outlook.office365.com*" })) {
        Write-Host "🔌 No active session Exchange Online."
        $response = Read-Host "Do you still want to connect Exchange Online ? (y/n)"
        if ($response -match '^[oOyY]$') {
            try {
                Connect-ExchangeOnline -UserPrincipalName $($SelectedProfile.Account)
                Write-Host "✅ Successful connection."
            } catch {
                Write-Warning "❌ Connection failed : $_"
            }
        } else {
            Write-Host "⏭️ Connection aborted by the user."
        }
    } else {
        Write-Host "✅ Already connected to Exchange Online."
    }
    # Get user
    $Result_Get = Get-Mailbox -Identity $UserPrincipalName | Select-Object DisplayName,EmailAddress,Alias,RecipientTypeDetails
    $Response = Read-Host "Do you still want to migrate this UserMailbox ($($Result_Get.DisplayName)) ? (y/n)"
    if ($Response -match '^[oOyY]$') {
        try {
            $Result_Set = Set-Mailbox -Identity $UserPrincipalName -Type Shared -MessageCopyForSendOnBehalfEnabled $true
            Write-Host "✅ Migration has been done ($($Result_Set.DisplayName))."
            "Verifying..."
            IF ($(Get-Mailbox -Identity $UserPrincipalName | Select-Object RecipientTypeDetails).RecipientTypeDetails -eq "Shared") {
                Write-Host "🎉 Successful migration"
            } else {
                Write-Warning "❌ Migration failed : $_"
            }

        } catch {
            Write-Warning "❌ Migration cancelled : $_"
        }
    } else {
        Write-Host "⏭️ Migration aborted by the user."
    }

    
}

Function EXOExtractPermissions {
    Get-Mailbox |?{$_.RecipientTypeDetails -eq "SharedMailbox"} | Get-MailboxPermission|?{$_.User -ne 'nt authority./self'} |Select-Object Identity,User,AccessRights
}

Function EXOHideGAL {
    param (
        [Parameter(Mandatory=$true, Position=0)]$UserPrincipalName
    )
    # Get session
    if (-not (Get-PSSession | Where-Object { $_.ComputerName -like "*outlook.office365.com*" })) {
        Write-Host "🔌 No active session Exchange Online."
        $response = Read-Host "Do you still want to connect Exchange Online ? (y/n)"
        if ($response -match '^[oOyY]$') {
            try {
                Connect-ExchangeOnline -UserPrincipalName $($SelectedProfile.Account)
                Write-Host "✅ Successful connection."
            } catch {
                Write-Warning "❌ Connection failed : $_"
            }
        } else {
            Write-Host "⏭️ Connection aborted by the user."
        }
    } else {
        Write-Host "✅ Already connected to Exchange Online."
    }

    try {
        $Result_Set = Set-Mailbox -Identity $UserPrincipalName -HiddenFromAddressListsEnabled $true
        Write-Host "✅ The user has been hidden ($($Result_Set.DisplayName))."
    } catch {
        Write-Warning "❌ Migration cancelled : $_"
    }


    


}

@{
# Version number of this module.
ModuleVersion = '1.2'
}

Function MIAssignment{
    param (
        [Parameter(Mandatory=$true, Position=0)]$TenantID,
        [Parameter(Mandatory=$true, Position=1)][String]$DisplayNameMI,
        [Parameter(Mandatory=$true, Position=2)][String[]]$GraphPermissions
    )
    $GraphAppId = "00000003-0000-0000-c000-000000000000"
    # $DisplayNameMI = "<name of your Logc App>"
    # $GraphPermissions = @('CustomSecAttributeAssignment.Read.All','Application.Read.All')

    Connect-MgGraph -Scopes Application.Read.All,AppRoleAssignment.ReadWrite.All -TenantId $TenantID -NoWelcome

    $IdMI = Get-MgServicePrincipal -Filter "DisplayName eq '$DisplayNameMI'"

    ## Get assigned roles
    Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $IdMI.Id

    ForEach ($GraphPermission in $GraphPermissions) {
        ## Get Graph roles
        $GraphServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$GraphAppId'"
        $AppRole = $GraphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $GraphPermission -and $_.AllowedMemberTypes -contains "Application"}

        $AppRole

        $params = @{
            principalId = $IdMI.Id
            resourceId = $GraphServicePrincipal.Id
            appRoleId = $AppRole.Id
        }

        ## Add permission to Managed Identity 
        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $params.principalId -ResourceId $params.resourceId -PrincipalId $params.principalId -AppRoleId $params.appRoleId
    }

    ## Get assigned roles
    Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $IdMI.Id
}
