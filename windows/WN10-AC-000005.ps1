<#
.SYNOPSIS
    Toggles cryptographic protocols (secure vs insecure) on the system.
    Please test thoroughly in a non-production environment before deploying widely.
    Make sure to run as Administrator or with appropriate privileges.

.NOTES
    Author          : Anthony Kent
    LinkedIn        : linkedin.com/in/akentitpro/
    GitHub          : github.com/AnthonyKSec
    Date Created    : 2025-06-15
    Last Modified   : 2025-06-15
    Version         : 1.0
    CVEs            : 
    Plugin IDs      : 
    STIG-ID         : WN10-AC-000005

.TESTED ON
    Date(s) Tested  : 2025-06-15
    Tested By       : Anthony Kent
    Systems Tested  : Windows Server 2019 Datacenter, Build 1809
                      Windows 10 Pro, Build 22H2
    PowerShell Ver. : 5.1.17763.6189

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN10-AC-000005.ps1 
#>

<#
.SYNOPSIS
 Sets the account lockout duration for failed logon attempts.

.DESCRIPTION
 Implements WN10-AC-000005 by configuring:
   - Account lockout duration = 15 minutes (or greater / 0)
   Uses ‘net accounts’ to apply setting without touching the registry directly.
 Requires administrative privileges.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$false)]
    [ValidatePattern('^(0|[1-9][0-9]*)$')]
    [int]$Duration = 15
)

if ($PSCmdlet.ShouldProcess("Setting account lockout duration to $Duration minutes")) {
    # Apply the account lockout duration
    net accounts /lockoutduration:$Duration | Out-Null
    Write-Host "Account lockout duration set to $Duration minute(s)."
    
    # Verify the new setting
    $settings = net accounts
    Write-Host "`n📋 Current 'Lockout duration' setting:"
    Write-Host ($settings | Select-String "Lockout duration")
    
    # Compliance check
    if (($Duration -ge 15) -or ($Duration -eq 0)) {
        Write-Host "✅ STIG WN10-AC-000005 compliance achieved."
    } else {
        Write-Warning "⚠️ Setting is non-compliant. Must be ≥ 15 or = 0."
    }
}
