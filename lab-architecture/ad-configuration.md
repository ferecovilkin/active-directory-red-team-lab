# Active Directory Domain Configuration

This document specifies the Organizational Unit (OU) structure, user accounts, groups, and intentional test vectors configured within the `CORP.LOCAL` domain.

---

## 1. Organizational Unit (OU) Hierarchy

```
CORP.LOCAL
├── Corp-Administration (Tier 0)
│   ├── Tier0-Accounts (Domain Admins, Enterprise Admins)
│   ├── Tier0-Computers (DC01)
│   └── Tier0-Groups
├── Corp-Servers (Tier 1)
│   ├── Tier1-Accounts (Server Admins, Service Accounts)
│   └── Tier1-Servers (APP01, FILE01)
├── Corp-Workstations (Tier 2)
│   ├── Tier2-Computers (WKSTN01, WKSTN02)
│   └── Tier2-Users (Finance, HR, Sales, IT Support)
└── Service-Accounts
    ├── svc_sql (MSSQL service account with SPN configured)
    └── svc_backup (Account tested for AS-REP roasting vulnerability)
```

---

## 2. Test Accounts & Misconfiguration Matrix (Controlled Simulation)

| Account Name | Group Membership | Baseline Misconfiguration / Scenario | Purpose in Simulation |
|---|---|---|---|
| `jdoe` | `Domain Users` | Standard employee account; weak password simulation | Initial compromised endpoint context on `WKSTN01` |
| `svc_backup` | `Domain Users`, `Backup Operators` | `DONT_REQ_PREAUTH` flag enabled in UserAccountControl | Validating AS-REP Roasting detection (Event ID 4768) |
| `svc_sql` | `Domain Users` | `MSSQLSvc/APP01.corp.local:1433` SPN assigned; RC4 encryption enabled | Validating Kerberoasting detection (Event ID 4769) |
| `helpdesk_admin`| `IT Support` | Explicit `GenericAll` permission on `Tier1-Admins` group | Validating BloodHound ACL edge detection (`GenericAll`) |
| `da_admin` | `Domain Admins` | Interactive login session created on member server | Demonstrating credential exposure in LSASS memory |
