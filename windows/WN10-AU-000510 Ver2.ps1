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
    STIG-ID         : WN10-AU-000510

.TESTED ON
    Date(s) Tested  : 2025-06-17
    Tested By       : Anthony Kent
    Systems Tested  : Windows 10 Pro, Build 22H2
    PowerShell Ver. : 5.1.17763.6189

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN10-AU-000510.ps1
#>

<#
.STIGID      : WN10-AU-000510
.TITLE       : Set Security Event Log Maximum Size to 196608 KB
.AUTHOR      : Tony A. Kent
.VERSION     : 1.1
.LASTUPDATE  : 2025-06-17
.DESCRIPTION : Applies the required policy-compliant value using secedit for STIG WN10-AU-000510.
#>

# --- SET BLOCK ---

$regPath    = 'HKLM:\Software\Policies\Microsoft\Windows\EventLog\Security'
$regName    = 'MaxSize'
$desiredVal = 196608

# Apply via secedit INF file
$infContent = @"
[Version]
Signature="$CHICAGO$"
Revision=1

[Registry Values]
HKLM\Software\Policies\Microsoft\Windows\EventLog\Security!MaxSize=$desiredVal,4
"@

$infFile = "$env:TEMP\WN10-AU-000510.inf"
$infContent | Set-Content -Path $infFile -Encoding ASCII

try {
    secedit /configure /db "$env:SystemRoot\security\Database\WN10-AU-000510.sdb" /cfg $infFile /quiet
    Write-Host "[SET] Policy applied via secedit." -ForegroundColor Green
} catch {
    Write-Warning "[SET] Failed to apply secedit policy: $_"
}

Remove-Item $infFile -Force -ErrorAction SilentlyContinue

# --- TEST BLOCK ---

$compliant = $true

try {
    $currentValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop).$regName
    if ($currentValue -eq $desiredVal) {
        Write-Host "[TEST] ✅ Registry PASS: '$regName' is $desiredVal" -ForegroundColor Green
    } else {
        Write-Warning "[TEST] ❌ Registry FAIL: '$regName' is $currentValue; expected $desiredVal"
        $compliant = $false
    }
} catch {
    Write-Warning "[TEST] ❌ Registry key/value missing"
    $compliant = $false
}

# Final Result
if ($compliant) {
    Write-Host "`n[RESULT] ✅ STIG WN10-AU-000510 fully enforced and verified." -ForegroundColor Green
} else {
    Write-Warning "`n[RESULT] ❌ STIG WN10-AU-000510 NOT fully enforced."
}
