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
    STIG-ID         : WN10-CC-000145

.TESTED ON
    Date(s) Tested  : 2025-06-17
    Tested By       : Anthony Kent
    Systems Tested  : Windows Server 2019 Datacenter, Build 1809
                      Windows 10 Pro, Build 22H2
    PowerShell Ver. : 5.1.17763.6189

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN10-CC-000145.ps1 
#>

<#
.STIGID      : WN10-CC-000145
.TITLE       : Password must be required when resuming from sleep (on battery).
.AUTHOR      : Tony A. Kent
.VERSION     : 1.0
.LASTUPDATE  : 2025-06-17
.DESCRIPTION : Enforces password prompt on resume from sleep when on battery via registry and validates via PowerShell.
#>

# --- SET BLOCK ---

$regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51'
$regName = 'DCSettingIndex'
$desiredValue = 1

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
    Write-Host "[SET] Created registry key: $regPath"
}

Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue -Type DWord
Write-Host "[SET] Set registry '$regName' to '$desiredValue' at $regPath"

# --- TEST BLOCK ---

$compliance = $true

try {
    $actualValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop).$regName
    if ($actualValue -eq $desiredValue) {
        Write-Host "[TEST] ✅ Registry PASS: '$regName' is set to $desiredValue" -ForegroundColor Green
    } else {
        Write-Warning "[TEST] ❌ Registry FAIL: '$regName' is $actualValue; expected $desiredValue"
        $compliance = $false
    }
} catch {
    Write-Warning "[TEST] ❌ Registry key or value not found"
    $compliance = $false
}

# Final Result
if ($compliance) {
    Write-Host "`n[RESULT] ✅ STIG WN10-CC-000145 fully enforced and verified." -ForegroundColor Green
} else {
    Write-Warning "`n[RESULT] ❌ STIG WN10-CC-000145 NOT fully enforced."
}
