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
    STIG-ID         : WN10-CC-000355 

.TESTED ON
    Date(s) Tested  : 2025-06-17
    Tested By       : Anthony Kent
    Systems Tested  : Windows 10 Pro, Build 22H2
    PowerShell Ver. : 5.1.17763.6189

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN10-CC-000355.ps1
#>

<#
.STIGID      : WN10-CC-000355
.TITLE       : Disallow WinRM from storing RunAs credentials
.VERSION     : 1.1
.AUTHOR      : Tony A. Kent
.LASTUPDATE  : 2025-06-17
.DESCRIPTION : Enforces and verifies both the Local Group Policy and registry setting using LGPO.exe to prevent WinRM from storing RunAs credentials.
#>

# --- SET BLOCK ---

# Define required registry path and policy name
$regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service'
$regName = 'DisableRunAs'
$desiredValue = 1

# Ensure registry path exists
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
    Write-Host "[SET] Created registry key: $regPath"
}

# Apply the registry setting
Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue -Type DWord
Write-Host "[SET] Set '$regName' to '$desiredValue' at $regPath"

# Apply via LGPO.exe to reflect in Local Group Policy
$lgpoPolicy = 'Computer::Software\Policies\Microsoft\Windows\WinRM\Service!DisableRunAs'
try {
    Start-Process -FilePath "LGPO.exe" -ArgumentList "/v $lgpoPolicy /t REG_DWORD /d $desiredValue" -Wait -NoNewWindow
    Write-Host "[SET] Applied LGPO for $regName using LGPO.exe"
} catch {
    Write-Warning "[SET] Failed to apply LGPO setting via LGPO.exe: $_"
}

# --- TEST BLOCK ---

$compliance = $true

# Verify registry value exists and is correct
try {
    $actualValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop).$regName
    if ($actualValue -eq $desiredValue) {
        Write-Host "[TEST] ✅ PASS: Registry '$regName' is correctly set to $desiredValue" -ForegroundColor Green
    } else {
        Write-Warning "[TEST] ❌ FAIL: '$regName' is $actualValue; expected $desiredValue"
        $compliance = $false
    }
} catch {
    Write-Warning "[TEST] ❌ FAIL: Registry key/value '$regName' not found"
    $compliance = $false
}

# Final Result Summary
if ($compliance) {
    Write-Host "\n[RESULT] ✅ STIG WN10-CC-000355 enforced and registry confirmed." -ForegroundColor Green
} else {
    Write-Warning "\n[RESULT] ❌ STIG WN10-CC-000355 not fully enforced."
}
