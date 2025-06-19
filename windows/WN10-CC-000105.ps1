
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
    STIG-ID         : WN10-CC-000105

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
STIG ID: WN10-AU-000010
Title: Windows 10 STIG
Description: Enable auditing for account logon success/failure
#>

Write-Host "=== Applying STIG WN10-AU-000010 ===" -ForegroundColor Cyan

# --- SET BLOCK ---
# Ensure registry path exists
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Audit\Configuration"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

Set-ItemProperty -Path $regPath -Name "EnableLogonSuccess" -Value 1 -Force
Write-Host "Registry setting applied: $regPath\EnableLogonSuccess = 1"

# --- TEST BLOCK ---
Write-Host "=== Verifying STIG WN10-AU-000010 Compliance ===" -ForegroundColor Yellow

$path = "HKLM:\SYSTEM\CurrentControlSet\Services\Audit\Configuration"
$name = "EnableLogonSuccess"
$expected = 1

try {
    $current = Get-ItemPropertyValue -Path $path -Name $name -ErrorAction Stop
} catch {
    $current = "Not Found"
}

$result = [PSCustomObject]@{
    Setting   = $name
    Expected  = $expected
    Actual    = $current
    Compliant = ($current -eq $expected)
}

$result | Format-Table -AutoSize
