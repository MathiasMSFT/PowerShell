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
    Try{
        stop-transcript|out-null
      }
      Catch [System.InvalidOperationException]{}

    ## Variables
    $UserName = [Environment]::UserName
    $PowershellProfilePath = (Get-Item $PROFILE.CurrentUserCurrentHost).PSParentPath

    ## Load JSON
    $Profiles = Get-Content -Raw -Path "$PowershellProfilePath\Modules\Powershell-Profile\Config.json" | ConvertFrom-Json
    $Global:TranscriptFolder = $Profiles.TranscriptFolder
    $Global:SelectedProfile = $Profiles.List | Out-Gridview -OutputMode Single
    If (($($SelectedProfile.Account).Count) -ne 1) {
        Write-Host "Select one option" -ForegroundColor Red
    } Else {

        #####################################################
        $Histo = (" Current : V0.1
        Powershell Profile $($SelectedProfile.TenantName)
        v0.1 - Creation - 2021-07-30 - Mathias Dumont
        v0.2 - New function - 2021-09-21 - Mathias Dumont
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

        "Chargement..."

        $host.PrivateData.ErrorForegroundColor = "green"

        Write-Host -ForegroundColor yellow @"
Profil personalisé pour $($SelectedProfile.TenantName) - Bienvenue $UserName
===============================

        Tenant: $($SelectedProfile.TenantName)
        Account: $($SelectedProfile.Account)
        Role: $($SelectedProfile.Role)

===============================
       
Emplacement par défaut $($SelectedProfile.Folder)
Transcript sauvegardé dans $TranscriptFolder

Session démarrée à : $(get-date)
"@
        Write-Host -ForegroundColor yellow "Dernière modification du profile $($SelectedProfile.TenantName) :" (Get-Item "$PowershellProfilePath\Modules\Powershell-Profile\Powershell-Profile.psm1").LastWriteTime
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