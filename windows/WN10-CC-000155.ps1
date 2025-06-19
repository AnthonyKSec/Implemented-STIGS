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
    STIG-ID         : WN10-CC-000155

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
STIG ID: WN10-CC-000155
Title: Windows 10 STIG
Description: Disable Solicited Remote Assistance
#>

Write-Host "=== Applying STIG WN10-CC-000155 ===" -ForegroundColor Cyan

# --- SET BLOCK ---
# Ensure registry path exists
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

Set-ItemProperty -Path $regPath -Name "fAllowToGetHelp" -Value 0 -Force
Write-Host "Registry setting applied: $regPath\fAllowToGetHelp = 0"

# --- TEST BLOCK ---
Write-Host "=== Verifying STIG WN10-CC-000155 Compliance ===" -ForegroundColor Yellow

$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$name = "fAllowToGetHelp"
$expected = 0

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
