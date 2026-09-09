# Lab Execution Evidence & Screenshots Directory

This directory contains terminal logs, assessment command captures, and screenshot references recorded directly from the VMware testing environment.

---

## Evidence Index

| Step | Validation Phase | Focus Artifacts | Evidence File |
|---|---|---|---|
| **01** | **Domain Controller** | DC Promotion, `CORP.LOCAL`, OU Trees | [`01_domain_controller.md`](01_domain_controller.md) |
| **02** | **Domain Enumeration** | PowerView & LDAP object queries | [`02_domain_enumeration.md`](02_domain_enumeration.md) |
| **03** | **BloodHound Attack Path** | SharpHound JSON ingestion & shortest path to DA | [`03_bloodhound_attack_path.md`](03_bloodhound_attack_path.md) |
| **04** | **Kerberoasting & AS-REP** | SPN discovery & TGS ticket extraction | [`04_kerberoasting.md`](04_kerberoasting.md) |
| **05** | **Lateral Movement** | WinRM / Remote access to `APP01` | [`05_lateral_movement.md`](05_lateral_movement.md) |
| **06** | **Domain Admin Takeover** | DCSync replication output (`krbtgt` hash) | [`06_domain_admin.md`](06_domain_admin.md) |
| **07** | **Detection & Telemetry** | Security Event Log (4768, 4769, 4662) & Sysmon | [`07_detection_telemetry.md`](07_detection_telemetry.md) |
| **08** | **Hardening & Remediation** | Post-remediation verification (LAPS, gMSA, Pre-Auth) | [`08_remediation.md`](08_remediation.md) |

> 💡 **Screenshot Placement:** Place full-resolution images into this folder matching the names `01_dc.png`, `02_enum.png`, `03_bloodhound.png`, `04_kerberoast.png`, `05_lateral.png`, `06_domain_admin.png`, `07_detection.png`, `08_remediation.png`.
