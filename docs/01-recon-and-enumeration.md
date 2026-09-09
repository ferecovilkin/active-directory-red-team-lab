# Phase 01: Reconnaissance & LDAP Directory Enumeration

## 1. Overview
In an enterprise Active Directory domain, unprivileged domain users possess legitimate read access to the directory partition via LDAP (Lightweight Directory Access Protocol) and RPC interfaces (SAMR). Adversaries exploit this default behavior to build a complete inventory of users, computers, organizational units, and administrative groups without generating suspicious network port scans.

---

## 2. Low-Level Mechanics

### 2.1 LDAP Queries & ADSI
Active Directory objects are queried using standard RFC 4515 LDAP search filters:
```ldap
(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))
```
* The filter above queries users configured with `DONT_REQ_PREAUTH` (bitmask `0x400000`).
* Standard Windows APIs (`ADsGetObject`, `DirectorySearcher` in .NET) query Domain Controllers over TCP port 389 (LDAP) or 636 (LDAPS).

### 2.2 SAM-R & NetSessionEnum Enumeration
* Tools enumerate remote logged-on users and active sessions by calling the `NetSessionEnum` and `NetWkstaUserEnum` Win32 APIs over Named Pipes (`\PIPE\wkssvc` / `\PIPE\srvsvc` on SMB port 445).
* This reveals where high-privilege administrators are currently logged in, marking high-value lateral movement targets.

---

## 3. Detection Engineering

| Telemetry | Log Source | Key Field / Indicator |
|---|---|---|
| **Event ID 1644** | Directory Service Diagnostic Log | High volume of LDAP search requests per minute from a single workstation IP |
| **Sysmon Event ID 3** | Network Connection | Abnormal outbound connections on port 389/636 originating from `powershell.exe` |
| **PowerShell 4104** | Microsoft-Windows-PowerShell/Operational | Script block executions containing ADSI queries or `DirectorySearcher` invocations |

---

## 4. Hardening & Defenses

1. **RPC Filter / Restrict Remote SAM:**
   * Configure `Network access: Restrict clients allowed to make remote calls to SAM` via GPO to block non-administrators from enumerating users via SAM-R.
2. **Enable LDAPS & LDAP Channel Binding:**
   * Require LDAP signing and LDAPS across all domain controllers.
3. **Honey Accounts (Canaries):**
   * Deploy decoy user accounts with alluring descriptions (e.g. `svc_backup_admin`) configured with alerting alerts when queried or touched.
