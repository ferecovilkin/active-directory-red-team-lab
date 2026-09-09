# Evidence 02: Domain Enumeration & Reconnaissance

**Host:** `WKSTN01.CORP.LOCAL` (Windows 11 Client)  
**Executed Context:** `CORP\jdoe` (Standard Domain User)  
**Technique:** Active Directory Service Interfaces (ADSI) & PowerView LDAP querying

---

## Terminal Verification Output

```powershell
PS C:\Users\jdoe> whoami /all

USER INFORMATION
----------------
User Name    SID
============ ==============================================
corp\jdoe    S-1-5-21-3829482910-1849204918-2940294819-1104

GROUP INFORMATION
-----------------
Group Name                                  Type             SID                                           Attributes
=========================================== ================ ============================================= ==================================================
Everyone                                    Well-known group S-1-1-0                                       Mandatory group, Enabled by default, Enabled group
BUILTIN\Users                               Alias            S-1-5-32-545                                  Mandatory group, Enabled by default, Enabled group
CORP\Domain Users                           Group            S-1-5-21-3829482910-1849204918-2940294819-513 Mandatory group, Enabled by default, Enabled group

PS C:\Users\jdoe> Get-DomainUser -PreauthNotRequired | Select-Object SamAccountName, useraccountcontrol

samaccountname useraccountcontrol
-------------- ------------------
svc_backup                 4194816

PS C:\Users\jdoe> Get-DomainUser -SPN | Select-Object SamAccountName, ServicePrincipalName

samaccountname serviceprincipalname
-------------- --------------------
svc_sql        MSSQLSvc/APP01.corp.local:1433
```

---

## Screenshot Reference

![Domain Enumeration](02_enum.png)
*(Screenshot: PowerShell console on WKSTN01 displaying unprivileged enumeration of vulnerable SPN and pre-authentication attributes)*
