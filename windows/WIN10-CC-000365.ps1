<#
.SYNOPSIS
    Toggles cryptographic protocols (secure vs insecure) on the system.
    Please test thoroughly in a non-production environment before deploying widely.
    Make sure to run as Administrator or with appropriate privileges.

.NOTES
    Author          : Anthony Kent
    LinkedIn        : linkedin.com/in/akentitpro/
    GitHub          : github.com/AnthonyKSec
    Date Created    : 2025-06-17
    Last Modified   : 2025-06-17
    Version         : 1.0
    CVEs            : 
    Plugin IDs      : 
    STIG-ID         : WN10-CC-000365

.TESTED ON
    Date(s) Tested  : 2025-06-17
    Tested By       : Anthony Kent
    Systems Tested  : Windows 10 Pro, Build 22H2
    PowerShell Ver. : 5.1.17763.6189

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WIN10-cc-000365.ps1 
#>

<#
.SYNOPSIS
  Enforces STIG WN10-CC-000365: prevent Windows apps from voice activation at lock screen.

.DESCRIPTION
  Creates or updates the registry value under AppPrivacy to Force Deny voice use above lock.
  Checks for an alternative policy that makes STIG NA before applying.

.NOTES
  Requires administrative privileges.
#>

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy'
$AboveLockName = 'LetAppsActivateWithVoiceAboveLock'
$AltName = 'LetAppsActivateWithVoice'
$DesiredValue = 2  # Force Deny

# Check for NA condition
$altValue = (Get-ItemProperty -Path $RegPath -Name $AltName -ErrorAction SilentlyContinue).$AltName
if ($altValue -eq $DesiredValue) {
    Write-Host "NA: '$AltName' is already set to $DesiredValue (Force Deny). No changes required." -ForegroundColor Yellow
    return
}

# Ensure registry path exists
if (-not (Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
    Write-Host "Created registry key: $RegPath"
}

# Set the required value
Set-ItemProperty -Path $RegPath -Name $AboveLockName -Value $DesiredValue -Type DWord
Write-Host "'$AboveLockName' set to $DesiredValue under $RegPath"

# Verification
$current = (Get-ItemProperty -Path $RegPath -Name $AboveLockName -ErrorAction SilentlyContinue).$AboveLockName
Write-Host "`n✔ Verification: '$AboveLockName' = $current (expected $DesiredValue)"
