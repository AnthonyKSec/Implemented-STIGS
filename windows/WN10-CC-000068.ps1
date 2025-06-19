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
    STIG-ID         : WN10-CC-000068

.TESTED ON
    Date(s) Tested  : 2025-06-19
    Tested By       : Anthony Kent
    Systems Tested  : Windows Server 2019 Datacenter, Build 1809
                      Windows 10 Pro, Build 22H2
    PowerShell Ver. : 5.1.17763.6189

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN10-CC-000068.ps1 
#>

<#
.STIGID      : WN10-CC-000068
.TITLE       : Enable Remote Host Delegation of Non-Exportable Credentials
.AUTHOR      : Grok, optimized by xAI
.VERSION     : 1.0
.LASTUPDATE  : 2025-06-19
.DESCRIPTION : Configures Windows 10 to enable Remote host delegation of non-exportable credentials per STIG WN10-CC-000068, using registry and SecEdit to support Restricted Admin mode or Remote Credential Guard.
#>

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires administrative privileges. Please run as Administrator."
    exit 1
}

# Define variables
$regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\'
$regName = 'AllowProtectedCreds'
$desiredValue = 1
$infPath = "$env:TEMP\WN10-CC-000068.inf"
$seceditLog = "$env:TEMP\WN10-CC-000068.log"

# SET block
try {
    # Ensure registry path exists
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
        Write-Host "[SET] Created registry path: $regPath"
    }
    # Set registry value
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue -Type DWord -ErrorAction Stop
    Write-Host "[SET] Configured '$regName' to $desiredValue"

    # Create SecEdit INF
    $infContent = @"
[Version]
signature="\$CHICAGO$"

[Registry Values]
MACHINE\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowProtectedCreds=4,1
"@
    $infContent | Set-Content -Path $infPath -Encoding ASCII -ErrorAction Stop

    # Apply SecEdit configuration
    secedit /configure /db secedit.sdb /cfg $infPath /log $seceditLog /quiet
    Write-Host "[SET] Applied SecEdit configuration"
} catch {
    Write-Warning "[SET] Configuration failed: $($_.Exception.Message)"
    exit 1
} finally {
    # Clean up temporary files
    foreach ($file in $infPath, $seceditLog) {
        if (Test-Path $file) { Remove-Item $file -Force -ErrorAction SilentlyContinue }
    }
}

# TEST block
$compliance = $true
try {
    $actualValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop).$regName
    if ($actualValue -eq $desiredValue) {
        Write-Host "[TEST] ✅ PASS: '$regName' is set to $desiredValue" -ForegroundColor Green
    } else {
        Write-Warning "[TEST] ❌ FAIL: '$regName' is $actualValue; expected $desiredValue"
        $compliance = $false
    }
} catch {
    Write-Warning "[TEST] ❌ FAIL: Registry key/value not found: $($_.Exception.Message)"
    $compliance = $false
}

# RESULT block
if ($compliance) {
    Write-Host "`n[RESULT] ✅ STIG WN10-CC-000068 fully enforced and verified." -ForegroundColor Green
} else {
    Write-Warning "`n[RESULT] ❌ STIG WN10-CC-000068 not fully enforced."
}
