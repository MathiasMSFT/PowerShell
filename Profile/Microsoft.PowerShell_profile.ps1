<#
.SYNOPSIS
Your Powershell profile

.DESCRIPTION
Get your profile via "$Profile" variable and then create a folder named "Powershell-Profile" and copy this file in folder

.NOTES
If you want to add module, add or change the path or copy your module in subfolder "Modules"
#>
Function Prompt {
    ## Assign Windows Title
    $host.ui.RawUI.WindowTitle = "Environment: $($SelectedProfile.TenantName)"

    ## Check if RunAs Admin => Elevated
    $IsAdmin = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

    $CurrentFolder = (Get-Location).Path

    ## Build CMD Prompt
    Write-Host ""
    Write-host ($(if ($IsAdmin) { 'Elevated ' } else { '' })) -BackgroundColor DarkRed -ForegroundColor White -NoNewline
    Write-Host " ENV:$($SelectedProfile.TenantName) " -BackgroundColor $($SelectedProfile.Color) -ForegroundColor DarkBlue -NoNewline
    Write-Host " Role:$($SelectedProfile.Role) " -BackgroundColor Magenta -ForegroundColor DarkBlue -NoNewline
    Write-Host " $CurrentFolder "  -ForegroundColor White -BackgroundColor DarkGray -NoNewline
    return "> "
}

## Import module
Import-Module "Powershell-Profile.psm1"
