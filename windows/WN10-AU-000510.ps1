<#
.STIGID      : WN10-AU-000510
.TITLE       : Set Security Event Log Maximum Size to 196608 KB
.AUTHOR      : Tony A. Kent
.VERSION     : 1.0
.LASTUPDATE  : 2025-06-17
.DESCRIPTION : Sets required registry key and local GPO using LGPO.exe to comply with STIG WN10-AU-000510.
#>

# --- SET BLOCK ---

# Registry Setting
$regPath = 'HKLM:\Software\Policies\Microsoft\Windows\EventLog\Security'
$regName = 'MaxSize'
$desiredValue = 196608

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
    Write-Host "[SET] Created registry key: $regPath"
}

Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue -Type DWord
Write-Host "[SET] Set registry '$regName' to '$desiredValue' KB in $regPath"

# Local GPO Setting via LGPO.exe
$lgpoText = @"
Computer\HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\EventLog\Security!MaxSize DWORD:196608
"@


$lgpoFile = "$env:TEMP\WN10-AU-000510.lgpo.txt"
$lgpoText | Set-Content -Path $lgpoFile -Encoding ASCII

$lgpoPath = "C:\Tools\LGPO\LGPO.exe"
if (Test-Path $lgpoPath) {
    & $lgpoPath /t $lgpoFile
    Write-Host "[SET] LGPO applied via LGPO.exe"
    Remove-Item $lgpoFile -Force
} else {
    Write-Warning "LGPO.exe not found at $lgpoPath. GPO setting not applied."
}

# --- TEST BLOCK ---

$compliance = $true

# Check registry value
try {
    $actualValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop).$regName
    if ($actualValue -eq $desiredValue) {
        Write-Host "[TEST] ✅ Registry PASS: '$regName' is set to $desiredValue" -ForegroundColor Green
    } else {
        Write-Warning "[TEST] ❌ Registry FAIL: '$regName' is $actualValue; expected $desiredValue"
        $compliance = $false
    }
} catch {
    Write-Warning "[TEST] ❌ Registry key/value not found"
    $compliance = $false
}

# Check GPO value
$gpoResult = gpresult /R /Scope Computer | Out-String
if ($gpoResult -match "Specify the maximum log size \(KB\)") {
    Write-Host "[TEST] ✅ GPO PASS: GPO setting appears applied" -ForegroundColor Green
} else {
    Write-Warning "[TEST] ❌ GPO FAIL: GPO setting not detected"
    $compliance = $false
}

# Final result
if ($compliance) {
    Write-Host "`n[RESULT] ✅ STIG WN10-AU-000510 fully enforced and verified." -ForegroundColor Green
} else {
    Write-Warning "`n[RESULT] ❌ STIG WN10-AU-000510 NOT fully enforced."
}
