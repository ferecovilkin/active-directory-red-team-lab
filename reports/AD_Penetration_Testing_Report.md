# Active Directory Penetration Testing & Security Assessment Report

**Target Environment:** `CORP.LOCAL` Enterprise Active Directory Forest  
**Assessment Type:** Internal Network Penetration Test / Red Team Attack Path Simulation  
**Lead Security Assessor:** İlkin Fərəcov  
**Assessment Scope:** Black-Box Foothold Transitioning to Assumed-Breach Tier-0 Dominance  
**Document Version:** 1.0 (Academic / Lab Submission)

---

## 1. Executive Summary

During this simulated penetration test, our security team performed an assumed-breach internal assessment of the `CORP.LOCAL` domain. Starting from an initial unprivileged workstation endpoint (`WKSTN01`) with low-privilege standard user rights (`jdoe`), the assessment team successfully identified, validated, and chained a series of Active Directory identity misconfigurations, excessive permissions, and legacy protocol weaknesses.

This vulnerability chain enabled the assessment team to traverse network tiers, escalate privileges locally and horizontally, and ultimately achieve complete **Domain Administrator (Tier-0) dominance** via Directory Replication Service synchronization (DCSync).

### Overall Risk Assessment: **CRITICAL**

The domain compromise was achieved without exploiting any software zero-day vulnerabilities, relying entirely on default Active Directory configuration weaknesses, unmanaged service accounts, and permissive object permissions (ACLs).

---

## 2. Attack Chain & Narrative Summary

```
[Initial Foothold: WKSTN01 (jdoe)]
               │
               ▼
[AD Enumeration & Reconnaissance via LDAP/ADSI]
               │
               ▼
[Kerberos Abuse: AS-REP Roasting & Kerberoasting]
   └── Compromise of svc_sql & svc_backup credentials
               │
               ▼
[Lateral Movement: WinRM to Member Server APP01]
               │
               ▼
[Host Privilege Analysis: LSASS Credential Exposure]
               │
               ▼
[BloodHound Graph Analysis: ACL Edge Exploitation]
   └── helpdesk_admin --(GenericAll)--> Tier1-Admins --(AdminTo)--> APP01
               │
               ▼
[Domain Dominance: DCSync Replication to DC01]
   └── Full extraction of KRBTGT & Domain Administrator credentials
```

---

## 3. Vulnerability Findings & Risk Summary

| Finding ID | Vulnerability Title | Severity | CVSS v3.1 | Status |
|---|---|---|---|---|
| **SEC-01** | Kerberos Pre-Authentication Disabled on Domain Account | **High** | 7.5 | Verified |
| **SEC-02** | Weak Service Account Credentials & SPN Exposure (Kerberoasting) | **High** | 7.4 | Verified |
| **SEC-03** | Lack of LSA Protection & In-Memory Credential Caching | **Critical** | 8.8 | Verified |
| **SEC-04** | Excessive Object Permissions & Unchecked DACL Chains | **Critical** | 9.0 | Verified |
| **SEC-05** | Credential Reuse & Missing Local Administrator Password Solution | **High** | 7.8 | Verified |
| **SEC-06** | Unrestricted Directory Replication Permissions (DCSync Exposure) | **Critical** | 9.8 | Verified |

---

## 4. Detailed Technical Findings

### Finding SEC-01: Kerberos Pre-Authentication Disabled (AS-REP Roasting)
* **Vulnerability Class:** Weak Authentication Configuration (CWE-287)
* **Affected Asset:** `CN=svc_backup,CN=Users,DC=corp,DC=local`
* **Technical Description:**  
  The `svc_backup` account had the `DONT_REQ_PREAUTH` flag enabled in its `userAccountControl` attribute. This configuration allows any entity on the network to request a Kerberos Ticket Granting Ticket (TGT) for the account without supplying a password. The returned `KRB_AS_REP` contains encrypted timestamp data that was captured and cracked offline.
* **Remediation:**  
  Ensure the `Do not require Kerberos preauthentication` checkbox is cleared across all domain user objects.

---

### Finding SEC-02: Weak Service Account Passwords & SPN Exposure (Kerberoasting)
* **Vulnerability Class:** Insufficient Password Complexity on Service Identities (CWE-521)
* **Affected Asset:** `CN=svc_sql,OU=Service-Accounts,DC=corp,DC=local` (`MSSQLSvc/APP01.corp.local:1433`)
* **Technical Description:**  
  A Service Principal Name (SPN) was associated with a standard user account using legacy `RC4-HMAC` encryption and a password susceptible to dictionary attacks. Any authenticated domain user could request a Ticket Granting Service (TGS) ticket and extract the ticket ciphertext for offline analysis.
* **Remediation:**  
  Migrate all service accounts with SPNs to **Group Managed Service Accounts (gMSA)** with 128-bit random keys managed directly by Domain Controllers.

---

### Finding SEC-03: Lack of LSA Memory Protections & In-Memory Credential Caching
* **Vulnerability Class:** Exposure of Sensitive Information in Process Memory (CWE-316)
* **Affected Asset:** `APP01.corp.local` (Windows Server 2022)
* **Technical Description:**  
  The Local Security Authority Subsystem Service (`lsass.exe`) was executing without Protected Process Light (`RunAsPPL`) enforcement and without Windows Defender Credential Guard. When privileged administrators logged on interactively, their NTLM hashes and Kerberos tickets remained resident in memory and accessible to administrative processes.
* **Remediation:**  
  Enable `RunAsPPL` via registry (`HKLM\SYSTEM\CurrentControlSet\Control\Lsa\RunAsPPL=1`) and enable Virtualization-Based Security (VBS) Credential Guard via Group Policy.

---

### Finding SEC-04: Excessive Object Permissions & Unchecked DACL Chains
* **Vulnerability Class:** Improper Access Control & Transitive Trust Loops (CWE-732)
* **Affected Asset:** Active Directory Discretionary Access Control Lists (DACLs)
* **Technical Description:**  
  Through graph-based ACL auditing (BloodHound), an unintended privilege escalation path was uncovered where standard support accounts had `GenericAll` rights over intermediate groups, allowing unauthorized group membership modification and eventual traversal to Tier-1 infrastructure.
* **Remediation:**  
  Implement strict Active Directory delegation boundaries. Remove explicit write permissions on security groups and audit ACL inheritance.

---

### Finding SEC-05: Missing Local Administrator Password Solution (LAPS)
* **Vulnerability Class:** Default/Shared Administrative Password Usage (CWE-259)
* **Affected Assets:** `WKSTN01.corp.local`, `APP01.corp.local`
* **Technical Description:**  
  Workstations and member servers shared identical local administrator passwords. Compounding this, standard users had local administrative rights, permitting horizontal lateral movement across subnet boundaries without domain credentials.
* **Remediation:**  
  Deploy Microsoft Windows LAPS across all endpoints to ensure unique, high-entropy passwords that rotate automatically.

---

### Finding SEC-06: Unrestricted Directory Replication Rights (DCSync Exposure)
* **Vulnerability Class:** Overly Permissive Administrative Delegation (CWE-250)
* **Affected Asset:** `DC01.corp.local` (Domain Controller)
* **Technical Description:**  
  Accounts elevated through the ACL chain inherited `DS-Replication-Get-Changes-All` rights on the domain root object. This permitted execution of Directory Replication Service (MS-DRSR) synchronization calls, dumping the password hashes of all domain accounts including `krbtgt`.
* **Remediation:**  
  Strictly restrict Directory Replication permissions exclusively to Domain Controller computer accounts and authorized Azure AD/Entra ID Connect synchronization accounts.
