<#
.SYNOPSIS
    Automated Active Directory Lab Provisioning Script for VMware.
.DESCRIPTION
    Builds the organizational unit structure, user accounts, groups, and intentional
    vulnerabilities in the CORP.LOCAL domain for the VMware Red Team assessment lab.
.NOTES
    Run on DC01 (Windows Server 2022) as Domain Administrator.
    Author: İlkin Fərəcov
#>

[CmdletBinding()]
param()

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " CORP.LOCAL Active Directory Lab Automated Provisioning Script" -ForegroundColor Cyan
Write-Host " Built and validated for VMware Workstation / ESXi Lab" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

# 1. Create Organizational Units
$OUs = @(
    "Corp-Administration",
    "IT",
    "HR",
    "Users",
    "Service-Accounts",
    "Member-Servers",
    "Workstations"
)

$domainDN = (Get-ADDomain).DistinguishedName

foreach ($ou in $OUs) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -ErrorAction SilentlyContinue)) {
        Write-Host "[+] Creating OU: $ou..." -ForegroundColor Green
        New-ADOrganizationalUnit -Name $ou -Path $domainDN
    }
}

# 2. Create Security Groups
Write-Host "[+] Creating Administrative Groups..." -ForegroundColor Green
if (-not (Get-ADGroup -Filter "Name -eq 'Tier1-Admins'" -ErrorAction SilentlyContinue)) {
    New-ADGroup -Name "Tier1-Admins" -GroupScope Global -Path "OU=Corp-Administration,$domainDN"
}
if (-not (Get-ADGroup -Filter "Name -eq 'IT-Helpdesk'" -ErrorAction SilentlyContinue)) {
    New-ADGroup -Name "IT-Helpdesk" -GroupScope Global -Path "OU=IT,$domainDN"
}

# Helper function to create user
function Create-LabUser {
    param($Username, $OU, $Description, $Password)
    $secPass = ConvertTo-SecureString $Password -AsPlainText -Force
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue)) {
        Write-Host "    -> Creating User: $Username in OU=$OU" -ForegroundColor White
        New-ADUser -Name $Username -SamAccountName $Username -UserPrincipalName "$Username@corp.local" `
                   -Path "OU=$OU,$domainDN" -AccountPassword $secPass -Enabled $true -Description $Description `
                   -PasswordNeverExpires $true
    }
}

# 3. Create Users
Write-Host "[+] Provisioning Lab Accounts..." -ForegroundColor Green

# Standard Workstation User (Initial Foothold)
Create-LabUser -Username "jdoe" -OU "Users" -Description "Standard Corporate User (Workstation Foothold)" -Password "Summer2026!"

# IT Helpdesk Account
Create-LabUser -Username "helpdesk_admin" -OU "IT" -Description "Tier 2 Helpdesk Technician" -Password "HelpdeskSupport2026!"

# HR Account
Create-LabUser -Username "mscott" -OU "HR" -Description "Human Resources Manager" -Password "DunderMifflin2026!"

# 4. Create Vulnerable Accounts for Red Team Assessment

# 4.1 Vulnerability: AS-REP Roasting (DONT_REQ_PREAUTH)
Write-Host "[+] Configuring AS-REP Roasting Vulnerability (svc_backup)..." -ForegroundColor Yellow
Create-LabUser -Username "svc_backup" -OU "Service-Accounts" -Description "Enterprise Backup Service Identity" -Password "BackupAdminPass2026!"
Set-ADAccountControl -Identity "svc_backup" -DoesNotRequirePreAuth $true
Write-Host "    [!] DoesNotRequirePreAuth enabled on 'svc_backup'" -ForegroundColor Red

# 4.2 Vulnerability: Kerberoasting (User account with SPN)
Write-Host "[+] Configuring Kerberoasting Vulnerability (svc_sql)..." -ForegroundColor Yellow
Create-LabUser -Username "svc_sql" -OU "Service-Accounts" -Description "MSSQL Database Engine Service Account" -Password "SqlServiceDatabasePassword!"
setspn -U -S "MSSQLSvc/APP01.corp.local:1433" "svc_sql"
Write-Host "    [!] Registered SPN MSSQLSvc/APP01.corp.local:1433 to user 'svc_sql'" -ForegroundColor Red

# 5. Populate Group Memberships
Write-Host "[+] Configuring Group Relationships..." -ForegroundColor Green
Add-ADGroupMember -Identity "IT-Helpdesk" -Members "helpdesk_admin" -ErrorAction SilentlyContinue
Add-ADGroupMember -Identity "Tier1-Admins" -Members "svc_sql" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "[✓] Active Directory Lab Environment Configured Successfully!" -ForegroundColor Green
Write-Host "    Domain: CORP.LOCAL" -ForegroundColor White
Write-Host "    Vulnerabilities Active: AS-REP Roasting (svc_backup), Kerberoasting (svc_sql)" -ForegroundColor White
Write-Host "================================================================" -ForegroundColor Cyan
