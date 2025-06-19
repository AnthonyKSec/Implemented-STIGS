<#
.SYNOPSIS
    Toggles cryptographic protocols (secure vs insecure) on the system.
    Please test thoroughly in a non-production environment before deploying widely.
    Make sure to run as Administrator or with appropriate privileges.

.NOTES
    Author          : Anthony Kent
    LinkedIn        : linkedin.com/in/akentitpro/
    GitHub          : github.com/AnthonyKSec
    Date Created    : 2025-06-19
    Last Modified   : 2025-06-19
    Version         : 1.0
    CVEs            : 
    Plugin IDs      : 
    STIG-ID         : WN10-CC-000330

.TESTED ON
    Date(s) Tested  : 2025-06-19
    Tested By       : Anthony Kent
    Systems Tested  : Windows Server 2019 Datacenter, Build 1809
                      Windows 10 Pro, Build 22H2
    PowerShell Ver. : 5.1.17763.6189

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\toggle-protocols.ps1 
#>

<#
.STIGID      : WN10-CC-000330
.TITLE       : Windows PowerShell script block logging must be enabled.
.AUTHOR      : Tony Kent
.VERSION     : 1.0
.LASTUPDATE  : 2025-06-18
.DESCRIPTION : Enables PowerShell script block logging using registry and SecEdit as per STIG WN10-CC-000330.
Reference: https://stigaview.com/products/win10/v3r1/WN10-CC-000330/
#>

# Check for admin rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires administrative privileges. Please run as Administrator."
    exit 1
}

# Define variables
$regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
$regName = 'EnableScriptBlockLogging'
$desiredValue = 1
$infPath = "$env:TEMP\WN10-CC-000330.inf"
$seceditLog = "$env:TEMP\WN10-CC-000330.log"

# SET block
try {
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
        Write-Host "[SET] Created registry key: $regPath"
    }
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue -Type DWord -Force
    Write-Host "[SET] Set registry '$regName' to '$desiredValue'"

    # Create SecEdit INF
    $infContent = @"
[Version]
signature="\$CHICAGO$"

[Registry Values]
MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging\EnableScriptBlockLogging=4,1
"@
    $infContent | Set-Content -Path $infPath -Encoding ASCII

    # Apply SecEdit
    secedit /configure /db secedit.sdb /cfg $infPath /log $seceditLog /quiet
    Write-Host "[SET] Applied SecEdit configuration"
} catch {
    Write-Warning "[SET] Configuration failed: $($_.Exception.Message)"
    exit 1
} finally {
    if (Test-Path $infPath) { Remove-Item $infPath -Force }
    if (Test-Path $seceditLog) { Remove-Item $seceditLog -Force }
}

# TEST block
$compliance = $true
try {
    $actualValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop).$regName
    if ($actualValue -eq $desiredValue) {
        Write-Host "[TEST] ✅ PASS: '$regName' is set to '$desiredValue'" -ForegroundColor Green
    } else {
        Write-Warning "[TEST] ❌ FAIL: '$regName' is '$actualValue'; expected '$desiredValue'"
        $compliance = $false
    }
} catch {
    Write-Warning "[TEST] ❌ FAIL: Registry key/value not found"
    $compliance = $false
}

# RESULT block
if ($compliance) {
    Write-Host "`n[RESULT] ✅ STIG WN10-CC-000330 fully enforced and verified." -ForegroundColor Green
} else {
    Write-Warning "`n[RESULT] ❌ STIG WN10-CC-000330 not fully enforced."
}
