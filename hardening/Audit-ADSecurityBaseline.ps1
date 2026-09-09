<#
.SYNOPSIS
    Active Directory Security Baseline & Misconfiguration Audit Script.
.DESCRIPTION
    Scans the current Active Directory domain for high-risk misconfigurations targeted
    by red teams, including AS-REP Roasting, Kerberoasting vectors, delegation risks,
    and missing tiered protections. Designed for defensive auditors and Purple Teams.
.EXAMPLE
    .\Audit-ADSecurityBaseline.ps1 -ExportHtmlReport
.NOTES
    Author: Active Directory Lab Project (İlkin Fərəcov)
    License: MIT
#>

[CmdletBinding()]
param(
    [switch]$ExportHtmlReport = $false,
    [string]$ReportPath = ".\AD_Security_Audit_Report.html"
)

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Active Directory Security Baseline Audit Tool" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "[*] Auditing domain identity posture and vulnerability surface..." -ForegroundColor Yellow

$auditResults = [ordered]@{}

# 1. Check for Accounts with Kerberos Pre-Authentication Disabled (AS-REP Roasting)
Write-Host "[+] Auditing accounts with DONT_REQ_PREAUTH (AS-REP Roasting risk)..." -ForegroundColor White
$asrepAccounts = Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true -and Enabled -eq $true} -Properties DoesNotRequirePreAuth, MemberOf, LastLogonDate
$auditResults["AS-REP Roasting (No Pre-Auth)"] = @{
    Severity = "HIGH"
    Count    = $asrepAccounts.Count
    Accounts = $asrepAccounts | Select-Object SamAccountName, DistinguishedName, LastLogonDate
    Remediation = "Clear the 'Do not require Kerberos preauthentication' flag via Active Directory Users and Computers (Account tab)."
}

# 2. Check for User Accounts with ServicePrincipalNames (Kerberoasting)
Write-Host "[+] Auditing user accounts with ServicePrincipalName (Kerberoasting risk)..." -ForegroundColor White
$kerbAccounts = Get-ADUser -Filter {ServicePrincipalName -like "*" -and Enabled -eq $true} -Properties ServicePrincipalName, MemberOf, PasswordLastSet | 
    Where-Object { $_.DistinguishedName -notlike "*CN=Managed Service Accounts*" }
$auditResults["Kerberoasting (SPN on User Accounts)"] = @{
    Severity = "HIGH"
    Count    = $kerbAccounts.Count
    Accounts = $kerbAccounts | Select-Object SamAccountName, ServicePrincipalName, PasswordLastSet
    Remediation = "Migrate service accounts to Group Managed Service Accounts (gMSA) or enforce 25+ character complex passphrases."
}

# 3. Check for Accounts with Unconstrained Delegation
Write-Host "[+] Auditing accounts with Unconstrained Delegation (TGT theft risk)..." -ForegroundColor White
$unconstrainedComputers = Get-ADComputer -Filter {TrustedForDelegation -eq $true -and Enabled -eq $true} -Properties TrustedForDelegation |
    Where-Object { $_.PrimaryGroupID -ne 516 } # Exclude Domain Controllers
$auditResults["Unconstrained Delegation (Non-DC)"] = @{
    Severity = "CRITICAL"
    Count    = $unconstrainedComputers.Count
    Accounts = $unconstrainedComputers | Select-Object Name, DistinguishedName
    Remediation = "Disable unconstrained delegation. Migrate to Resource-Based Constrained Delegation (RBCD)."
}

# 4. Check for Privileged Accounts Not in 'Protected Users'
Write-Host "[+] Auditing privileged accounts missing 'Protected Users' membership..." -ForegroundColor White
$domainAdmins = Get-ADGroupMember -Identity "Domain Admins" | Select-Object -ExpandProperty SamAccountName
$protectedUsersMembers = Get-ADGroupMember -Identity "Protected Users" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty SamAccountName
$unprotectedDAs = $domainAdmins | Where-Object { $protectedUsersMembers -notcontains $_ }
$auditResults["Privileged Accounts Outside Protected Users"] = @{
    Severity = "MEDIUM"
    Count    = $unprotectedDAs.Count
    Accounts = $unprotectedDAs
    Remediation = "Add Tier-0 administrative accounts to the 'Protected Users' security group to disable NTLM caching and weak ciphers."
}

# 5. Check for Accounts with Passwords That Never Expire
Write-Host "[+] Auditing accounts with Passwords Set to Never Expire..." -ForegroundColor White
$neverExpire = Get-ADUser -Filter {PasswordNeverExpires -eq $true -and Enabled -eq $true} -Properties PasswordNeverExpires, PasswordLastSet
$auditResults["Password Never Expires"] = @{
    Severity = "LOW"
    Count    = $neverExpire.Count
    Accounts = $neverExpire | Select-Object SamAccountName, PasswordLastSet
    Remediation = "Audit legacy exceptions and enforce password lifecycle policies."
}

# Output Summary to Console
Write-Host ""
Write-Host "=== AUDIT SUMMARY ===" -ForegroundColor Cyan
foreach ($key in $auditResults.Keys) {
    $item = $auditResults[$key]
    $color = switch ($item.Severity) {
        "CRITICAL" { "Red" }
        "HIGH"     { "Magenta" }
        "MEDIUM"   { "Yellow" }
        default    { "Gray" }
    }
    Write-Host ("[{0}] {1}: {2} finding(s)" -f $item.Severity, $key, $item.Count) -ForegroundColor $color
}

Write-Host ""
Write-Host "[*] Active Directory baseline scan completed." -ForegroundColor Green
