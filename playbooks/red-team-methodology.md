# Active Directory Penetration Testing & Red Team Methodology Playbook

This playbook documents the technical tradecraft, tactical phases, and methodologies utilized by penetration testers during internal Active Directory assessments.

---

## 🎯 Tactical Phase Breakdown

```
[01. Situational Awareness & Foothold Analysis]
                       │
                       ▼
[02. Domain Enumeration & PowerView Tradecraft]
                       │
                       ▼
[03. Kerberos Protocol Attacks & Ticket Abuse]
                       │
                       ▼
[04. Memory Extraction & Credential Hygiene]
                       │
                       ▼
[05. Graph-Based Attack Path Mapping (BloodHound)]
                       │
                       ▼
[06. Lateral Movement & Transport Vectors]
                       │
                       ▼
[07. Privilege Escalation & Domain Dominance]
```

---

## Phase 01: Situational Awareness & Local Context
Upon obtaining initial code execution on an internal workstation endpoint (`WKSTN01`), the penetration tester validates the execution boundary, privilege level, and network context:
* **Context Verification:** Current user SID, domain name, token privileges (`whoami /all`, `whoami /priv`).
* **Environmental Protections:** Identifying endpoint detection agents, Antimalware Scan Interface (AMSI) providers, and PowerShell execution policies.
* **Network Neighborhood:** Determining Domain Controller IP (`[System.Net.Dns]::GetHostByName("corp.local")`), default gateways, and DNS configuration.

---

## Phase 02: Domain Reconnaissance & PowerView Tradecraft
Active Directory directory objects are queried using LDAP filters to build an operational profile of the environment:
* **Domain & Forest Mapping:** Enumerating domain controllers, forest trusts, and functional levels (`Get-Domain`, `Get-ForestDomain`).
* **High-Value Target Identification:** Enumerating members of `Domain Admins`, `Enterprise Admins`, and custom privileged groups (`Get-DomainGroupMember -Identity "Domain Admins"`).
* **Service Principal Discovery:** Querying all user accounts with registered SPNs for Kerberoasting vectors (`Get-DomainUser -SPN`).
* **Pre-Authentication Discovery:** Scanning for accounts with `DONT_REQ_PREAUTH` for AS-REP Roasting (`Get-DomainUser -PreauthNotRequired`).
* **Local Administrator Mapping:** Identifying workstations where the current user or acquired identities have administrative rights (`Find-LocalAdminAccess`).

---

## Phase 03: Kerberos Abuse & Ticket Extraction (Rubeus Mechanics)
Kerberos abuse focuses on exploiting symmetric key ticket exchanges to obtain offline crackable credentials:
* **AS-REP Roasting Mechanics:** Requesting ticket-granting tickets without pre-authentication for vulnerable accounts. The returned encrypted timestamp is extracted for offline dictionary validation.
* **Kerberoasting Mechanics:** Requesting service tickets (TGS) for accounts with SPNs. Targeting legacy `RC4-HMAC` (encryption type `0x17`) tickets to enable rapid dictionary recovery.
* **Pass-the-Ticket (PtT) & Ticket Injection:** Re-importing acquired Kerberos tickets into the current logon session (`LUID`) to authenticate to target services without supplying plaintext passwords.

---

## Phase 04: Credential Access & Memory Architecture (Mimikatz Concepts)
When local administrator privileges are achieved on a member server:
* **LSASS Process Inspection:** Examining cached logon sessions within the Local Security Authority Subsystem Service (`lsass.exe`).
* **Credential Vaults:** Extracting NTLM password hashes and Kerberos encryption keys stored in memory packages (`MSV1_0`, `Kerberos`).
* **Token Impersonation & Manipulation:** Reviewing processes for available administrative tokens to perform privilege escalation using `SeDebugPrivilege` or `SeImpersonatePrivilege`.

---

## Phase 05: Graph Relationship Analysis (BloodHound / SharpHound)
Manual permission analysis in complex Active Directory environments is time-prohibitive. Automated graph collection models access control relationships:
* **Data Ingestion:** Gathering domain users, groups, computers, sessions, and object security descriptors (DACLs) via SharpHound collectors.
* **Graph Path Queries:**
  * Shortest Paths to Domain Admins / Unconstrained Delegation systems.
  * Searching for Dangerous ACEs:
    * `GenericAll` / `GenericWrite`: Full object modification.
    * `WriteDacl`: Granting oneself arbitrary permissions.
    * `WriteOwner`: Taking ownership of an object.
    * `ForceChangePassword`: Resetting target user passwords without knowing previous credentials.

---

## Phase 06: Lateral Movement & Transport Vectors
Traversing between compromised workstations and target servers:
* **Windows Remote Management (WinRM):** Authenticating over TCP port 5985/5986 using PowerShell Remoting (`Enter-PSSession`).
* **Pass-the-Hash (PtH):** Authenticating over SMB/RPC using acquired NTLM hashes without needing the plaintext passphrase.
* **WMI Execution:** Invoking process creation remotely via Windows Management Instrumentation (`Win32_Process.Create`).

---

## Phase 07: Domain Dominance & Persistence (DCSync)
Achieving full forest takeover:
* **DCSync Mechanics:** Utilizing Directory Replication Service (`MS-DRSR`) APIs to impersonate a domain controller. Requesting account synchronization secrets for the `krbtgt` account.
* **Golden Ticket Generation:** Using the `krbtgt` NTLM hash to forge Ticket Granting Tickets (TGTs) with arbitrary user identities, group memberships (e.g. `Domain Admins`, SID `512`), and extended lifetimes.
