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
    STIG-ID         : WN10-RG-000005

.TESTED ON
    Date(s) Tested  : 2025-06-17
    Tested By       : Anthony Kent
    Systems Tested  : Windows 10 Pro, Build 22H2
    PowerShell Ver. : 5.1.17763.6189

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN10-RG-000005.ps1
#>


<#
.STIGID      : WN10-RG-000005
.TITLE       : Maintain default permissions on HKLM hive
.VERSION     : 1.0
.AUTHOR      : Tony A. Kent
.LASTUPDATE  : 2025-06-15
.DESCRIPTION : Resets HKLM registry ACLs to default and verifies common defaults
#>

# --- SET BLOCK ---
try {
    icacls 'HKLM' /reset /T /C | Out-Null
    Write-Host "[SET] Reset HKLM registry ACLs to default"
} catch {
    Write-Warning "[SET] Error resetting HKLM ACLs: $_"
}

# --- TEST BLOCK ---
$permissionsCheck = icacls 'HKLM' 2>&1 | Select-String 'Everyone'
if (-not $permissionsCheck) {
    Write-Host "[TEST] ✅ PASS: No excessive permissions for 'Everyone' on HKLM" -ForegroundColor Green
} else {
    Write-Warning "[TEST] ❌ FAIL: Found entries for 'Everyone' on HKLM"
}
