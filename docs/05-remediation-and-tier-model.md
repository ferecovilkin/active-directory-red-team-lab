# Phase 05: Enterprise Hardening & Tiered Administrative Model

## 1. The Clean Source & Administrative Tiering Model

The most effective strategy to counter identity-based attack chains is the strict enforcement of an **Active Directory Tiering Model** (or Microsoft Enterprise Access Model).

```
   ┌─────────────────────────────────────────────────────────────┐
   │ TIER 0: CONTROL PLANE                                       │
   │ Domain Controllers, AD CS PKI, ADFS, Entra Connect, Tier-0  │
   │ Accounts & Privileged Access Workstations (PAW)             │
   └──────────────────────────────┬──────────────────────────────┘
                                  │ Prohibit logon downward
                                  ▼
   ┌─────────────────────────────────────────────────────────────┐
   │ TIER 1: SERVER PLANE                                        │
   │ Application Servers, MSSQL, IIS, Web Farms, Backup Storage  │
   │ & Server Administrators                                     │
   └──────────────────────────────┬──────────────────────────────┘
                                  │ Prohibit logon downward
                                  ▼
   ┌─────────────────────────────────────────────────────────────┐
   │ TIER 2: WORKSTATION & USER PLANE                            │
   │ End-user laptops, Helpdesk staff, Standard user accounts,   │
   │ Network printers & mobile endpoints                         │
   └─────────────────────────────────────────────────────────────┘
```

---

## 2. Core Operational Rules

1. **Credentials Never Cross Downward Boundaries:**
   * A Tier-0 account (`Domain Admin`) MUST NEVER log on interactively or via RDP to a Tier-1 or Tier-2 asset.
   * Rationale: Prevents credential material from being dumped from LSASS memory on lower-tier computers.
2. **Dedicated Administrative Accounts:**
   * Administrators possess distinct accounts for each tier:
     * `jdoe` (Tier 2 standard email/browsing)
     * `jdoe-t1` (Tier 1 server administration)
     * `jdoe-t0` (Tier 0 domain controller administration, usable ONLY from a PAW)
3. **Privileged Access Workstations (PAWs):**
   * Tier-0 administration is performed exclusively from dedicated, hardened physical or virtual workstations with no internet access or email clients.

---

## 3. Mandatory Security Controls

| Control | Mechanism | Impact |
|---|---|---|
| **Windows LAPS v2** | GPO / Native AD extension | Randomizes local administrator passwords; kills Pass-the-Hash across endpoints |
| **Protected Users Group** | Active Directory Security Group | Disables NTLM authentication, RC4 ciphers, and ticket delegation for members |
| **Credential Guard** | VBS / Hyper-V Isolation | Encapsulates LSASS secrets inside a hardware-isolated container |
| **gMSA (Group Managed Service Accounts)** | Active Directory KDS | Eliminates crackable static service account passwords |
| **RC4 Deprecation** | GPO Kerberos Policy | Blocks Kerberoasting ticket downgrades to legacy ciphers |
| **User Rights Assignment** | GPO | `Deny access to this computer from the network` for Tier 0 accounts on Tier 1/2 |
