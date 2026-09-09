# Phase 03: LSASS Memory Architecture, Credential Theft & Defense

## 1. Overview
The Local Security Authority Subsystem Service (`lsass.exe`) is the core Windows operating system process responsible for enforcing security policies, handling authentications, and storing active logon sessions and credential materials in virtual memory.

---

## 2. Low-Level Infiltration Mechanics

### 2.1 Security Support Providers (SSPs)
LSASS loads dynamic link libraries known as Security Support Providers to handle different authentication protocols:
* `msv1_0.dll` - NTLM authentication (stores NTLM hashes for active sessions).
* `kerberos.dll` - Kerberos authentication (stores TGTs, TGS tickets, and session keys).
* `wdigest.dll` - WDigest authentication (historically cached plaintext passwords in memory).
* `tspkg.dll` - CredSSP for Remote Desktop Protocol.

### 2.2 Process Memory Access
To extract credential material from memory:
1. An attacker with `SeDebugPrivilege` calls `OpenProcess` with access masks `PROCESS_VM_READ` (`0x0010`) and `PROCESS_QUERY_INFORMATION` (`0x0400`).
2. Tools read memory structures (`MiniDumpWriteDump` API or direct handle reading) to extract ticket caches and hashes.

---

## 3. Detection Engineering

### Sysmon Event ID 10 (ProcessAccess)
Monitor access requests targeting `lsass.exe`:
```xml
<RuleGroup name="LsassMemoryAccess" groupRelation="or">
  <ProcessAccess onmatch="include">
    <TargetImage condition="end with">\lsass.exe</TargetImage>
    <GrantedAccess condition="contains any">0x1010;0x1038;0x1410;0x1fffff</GrantedAccess>
  </ProcessAccess>
</RuleGroup>
```

### Windows Security Event ID 4672 / 4688
Monitor assignment of `SeDebugPrivilege` and anomalous process creation spawning command interpreters under administrative tokens.

---

## 4. Hardening & Defenses

1. **Enable LSA Protection (`RunAsPPL`):**
   * Configures `lsass.exe` to run as a Protected Process Light (PPL).
   * Registry: `HKLM\SYSTEM\CurrentControlSet\Control\Lsa\RunAsPPL = 1`
   * Prevents non-protected processes, even running as `NT AUTHORITY\SYSTEM`, from opening `PROCESS_VM_READ` handles to LSASS.
2. **Deploy Windows Defender Credential Guard:**
   * Utilizes Virtualization-Based Security (VBS) and Hyper-V micro-virtualization to isolate credential secrets inside an isolated virtual container (`LsaIso.exe`).
   * Even kernel-level malware in the main OS cannot read credentials stored inside the isolated VBS container.
3. **Disable WDigest Caching:**
   * Registry: `HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest\UseLogonCredential = 0`.
