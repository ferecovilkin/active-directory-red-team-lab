# Evidence 05: Lateral Movement to Member Server (`APP01`)

**Source:** `WKSTN01.CORP.LOCAL` (192.168.100.15)  
**Destination:** `APP01.CORP.LOCAL` (192.168.100.20)  
**Authentication Material:** Acquired credentials for `svc_sql`  
**Protocol:** Windows Remote Management (WinRM / TCP 5985)

---

## Terminal Verification Output

```powershell
PS C:\Users\jdoe> $cred = New-Object System.Management.Automation.PSCredential ("corp\svc_sql", ($secPass))
PS C:\Users\jdoe> Enter-PSSession -ComputerName APP01.corp.local -Credential $cred

[APP01.corp.local]: PS C:\Users\svc_sql\Documents> whoami /priv

PRIVILEGES INFORMATION
----------------------
Privilege Name                Description                    State
============================= ============================== =======
SeAssignPrimaryTokenPrivilege Replace a process-level token  Disabled
SeIncreaseQuotaPrivilege      Adjust memory quotas for process Disabled
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled

[APP01.corp.local]: PS C:\Users\svc_sql\Documents> hostname; ipconfig | findstr "IPv4"
APP01
   IPv4 Address. . . . . . . . . . . : 192.168.100.20
```

---

## Screenshot Reference

![Lateral Movement](05_lateral.png)
*(Screenshot: PowerShell Remoting session established from WKSTN01 to APP01 as svc_sql verifying local host access)*
