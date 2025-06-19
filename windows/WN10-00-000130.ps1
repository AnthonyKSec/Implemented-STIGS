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
    STIG-ID         : WN10-00-000130

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
.STIGID      : WN10-00-000130
.TITLE       : Peer Name Resolution Protocol must be disabled.
.AUTHOR      : Tony Kent
.VERSION     : 1.0
.LASTUPDATE  : 2025-06-18
.DESCRIPTION : Disables the Peer Name Resolution Protocol service per STIG WN10-00-000130.
Reference: https://stigaview.com/products/win10/v3r1/WN10-00-000130/
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires administrative privileges. Please run as Administrator."
    exit 1
}

# Disable the service
$serviceName = "PNRPsvc"
try {
    Set-Service -Name $serviceName -StartupType Disabled
    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
    Write-Host "[SET] Disabled and stopped service '$serviceName'"
} catch {
    Write-Warning "[SET] Failed to configure service: $($_.Exception.Message)"
}

# TEST block
$compliance = $true
try {
    $svc = Get-Service -Name $serviceName -ErrorAction Stop
    if ($svc.Status -eq "Stopped" -and $svc.StartType -eq "Disabled") {
        Write-Host "[TEST] ✅ PASS: Service '$serviceName' is stopped and disabled." -ForegroundColor Green
    } else {
        Write-Warning "[TEST] ❌ FAIL: Service '$serviceName' not properly configured."
        $compliance = $false
    }
} catch {
    Write-Warning "[TEST] ❌ FAIL: Service '$serviceName' not found."
    $compliance = $false
}

if ($compliance) {
    Write-Host "`n[RESULT] ✅ STIG WN10-00-000130 fully enforced and verified." -ForegroundColor Green
} else {
    Write-Warning "`n[RESULT] ❌ STIG WN10-00-000130 not fully enforced."
}
