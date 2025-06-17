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
    STIG-ID         : WN10-CC-000310

.TESTED ON
    Date(s) Tested  : 2025-06-17
    Tested By       : Anthony Kent
    Systems Tested  : Windows 10 Pro, Build 22H2
    PowerShell Ver. : 5.1.17763.6189

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WIN10-CC-000310.ps1
#>

<#
.STIGID      : WN10-EP-000310
.TITLE       : Enable Kernel DMA Protection
.VERSION     : 1.0
.AUTHOR      : Tony A. Kent
.LASTUPDATE  : 2025-06-15
.DESCRIPTION : Enforces and verifies Kernel DMA Protection via registry
#>

# --- SET BLOCK ---
$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard'
$regName = 'EnableKernelDMAProtection'
$desiredValue = 0

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
    Write-Host "[SET] Created registry path: $regPath"
}

Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue -Type DWord
Write-Host "[SET] Set '$regName' to '$desiredValue' in $regPath"

# --- TEST BLOCK ---
$expectedValue = 0
try {
    $actualValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop).$regName
    if ($actualValue -eq $expectedValue) {
        Write-Host "[TEST] ✅ PASS: $regName is set to $expectedValue" -ForegroundColor Green
    } else {
        Write-Warning "[TEST] ❌ FAIL: $regName is set to $actualValue. Expected: $expectedValue"
    }
} catch {
    Write-Warning "[TEST] ❌ FAIL: $regName not found in $regPath"
}
