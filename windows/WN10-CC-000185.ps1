<#
.SYNOPSIS
    Toggles cryptographic protocols (secure vs insecure) on the system.
    Please test thoroughly in a non-production environment before deploying widely.
    Make sure to run as Administrator or with appropriate privileges.

.NOTES
    Author          : Anthony Kent
    LinkedIn        : linkedin.com/in/akentitpro/
    GitHub          : github.com/AnthonyKSec
    Date Created    : 2024-09-09
    Last Modified   : 2024-09-09
    Version         : 1.0
    CVEs            :
    Plugin IDs      : 
    STIG-ID         : WN10-CC-000185

.TESTED ON
    Date(s) Tested  : 2024-09-09
    Tested By       : Anthony Kent
    Systems Tested  : Windows Server 2019 Datacenter, Build 1809
                      Windows 10 Pro, Build 22H2
    PowerShell Ver. : 5.1.17763.6189

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN10-CC-000185.ps1 
#>

<#
.STIGID      : WN10-CC-000185
.TITLE       : Turn off AutoRun on all drives
.AUTHOR      : Tony A. Kent
.VERSION     : 1.1
.LASTUPDATE  : 2025-06-17
.DESCRIPTION : Enforces STIG WN10-CC-000185 by disabling AutoRun on all drives via registry and SecEdit.
#>

# --- SET BLOCK ---

# Registry Path and Values
$regPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
$settings = @{
    'NoDriveTypeAutoRun' = 255  # Disables AutoRun on all drives
    'NoAutoRun' = 1             # Turns off AutoRun functionality
}

# Ensure key exists
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
    Write-Host "[SET] Created registry path: $regPath"
}

# Apply registry settings
foreach ($name in $settings.Keys) {
    Set-ItemProperty -Path $regPath -Name $name -Value $settings[$name] -Type DWord
    Write-Host "[SET] Set '$name' to '$($settings[$name])'"
}

# Create INF for SecEdit
$infContent = @"
[Unicode]
Unicode=yes
[System Access]
[Event Audit]
[Registry Values]
[Version]
signature="\$CHICAGO\$"
Revision=1

[Registry Values]
MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoDriveTypeAutoRun=4,255
MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoAutoRun=4,1
"@

$tempInf = "$env:TEMP\WN10-CC-000185.inf"
$infContent | Set-Content -Path $tempInf -Encoding ASCII
Write-Host "[SET] INF file written to $tempInf"

# Apply INF using SecEdit
secedit /configure /db "$env:TEMP\secedit-WN10-CC-000185.sdb" /cfg $tempInf /quiet
Write-Host "[SET] Policy applied using SecEdit"

Remove-Item $tempInf -Force

# --- TEST BLOCK ---

$compliance = $true

# Registry verification
foreach ($name in $settings.Keys) {
    try {
        $val = (Get-ItemProperty -Path $regPath -Name $name -ErrorAction Stop).$name
        if ($val -eq $settings[$name]) {
            Write-Host "[TEST] ✅ PASS: '$name' is $val" -ForegroundColor Green
        } else {
            Write-Warning "[TEST] ❌ FAIL: '$name' is $val; expected $($settings[$name])"
            $compliance = $false
        }
    } catch {
        Write-Warning "[TEST] ❌ FAIL: '$name' not found"
        $compliance = $false
    }
}

# Final Result
if ($compliance) {
    Write-Host "`n[RESULT] ✅ STIG WN10-CC-000185 fully enforced and verified." -ForegroundColor Green
} else {
    Write-Warning "`n[RESULT] ❌ STIG WN10-CC-000185 NOT fully enforced."
}
