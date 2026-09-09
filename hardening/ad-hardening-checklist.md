# Active Directory Hardening & Remediation Checklist

This checklist outlines the enterprise defensive controls required to mitigate the attack vectors demonstrated in the lab simulation.

---

## 1. Identity & Credential Hygiene

- [ ] **Deploy Windows LAPS (Local Administrator Password Solution):**
  - Ensure every member server and workstation has a randomized, regularly rotated local administrator password stored securely in Active Directory.
  - Deny standard domain users read access to `ms-Mcs-AdmPwd` attributes.
- [ ] **Enforce Protected Users Security Group:**
  - Place privileged domain administrators into the `Protected Users` group.
  - Benefit: Disables NTLM caching, forces Kerberos with AES encryption, and prevents caching of plaintext credentials in memory.
- [ ] **Audit & Eliminate Weak Service Accounts:**
  - Migrate human or interactive service accounts to **Group Managed Service Accounts (gMSA)**.
  - For service accounts that cannot use gMSA, enforce minimum 25-character high-entropy passphrases to render offline Kerberoasting brute-force attacks infeasible.
- [ ] **Disable Kerberos Pre-Authentication Bypass:**
  - Audit domain for accounts where `UserAccountControl` has `DONT_REQ_PREAUTH` (flag `0x400000`) set.
  - Re-enable pre-authentication immediately on all user accounts.

---

## 2. Endpoint & OS-Level Protections

- [ ] **Enable LSA Protection (`RunAsPPL`):**
  - Configure registry: `HKLM\SYSTEM\CurrentControlSet\Control\Lsa\RunAsPPL = 1`
  - Prevents non-protected processes from reading or injecting code into `lsass.exe`.
- [ ] **Deploy Windows Defender Credential Guard:**
  - Leverage Virtualization-Based Security (VBS) to isolate LSA secrets into an isolated container inaccessible even to the host kernel.
- [ ] **Disable WDigest Cleartext Caching:**
  - Configure `HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest\UseLogonCredential = 0`.

---

## 3. Tiering & Administrative Boundaries

- [ ] **Enforce 3-Tier Administrative Architecture:**
  - **Tier 0:** Domain Controllers, PKI, Identity synchronization servers.
  - **Tier 1:** Enterprise servers, databases, core business applications.
  - **Tier 2:** Client workstations, printers, standard user devices.
- [ ] **Enforce Logon Restrictions via Group Policy (User Rights Assignment):**
  - Deny Tier-0 accounts logon access to Tier-1 and Tier-2 assets (`Deny log on locally`, `Deny log on through Remote Desktop Services`, `Deny log on as a batch job`).

---

## 4. Kerberos & Network Protocol Hardening

- [ ] **Deprecate RC4 Encryption Forest-Wide:**
  - Configure Group Policy: `Network security: Configure encryption types allowed for Kerberos` -> Enable only `AES128_HMAC_SHA1`, `AES256_HMAC_SHA1`, and `Future encryption types`.
- [ ] **Enable SMB Signing & Require SMB v3 Encryption:**
  - Prevents SMB relay and man-in-the-middle attacks across all internal subnets.
- [ ] **Enable LDAP Signing & Channel Binding:**
  - Mitigate NTLM relay attacks targeting Active Directory Certificate Services (AD CS) and domain controllers.
