# Lab Architecture & Topology Specifications

This document outlines the virtual hardware, networking configurations, and component assignments used in the Active Directory simulation environment.

---

## 1. Network Subnets & Segmentation

The lab utilizes three internal host-only/isolated virtual subnets behind a pfSense/virtual router boundary:

| Subnet Zone | CIDR Block | Gateway | Description |
|---|---|---|---|
| **Tier-0 (Control Plane)** | `10.0.0.0/24` | `10.0.0.1` | Houses Domain Controllers, Key Distribution Centers (KDC), and PKI. |
| **Tier-1 (Servers)** | `10.0.10.0/24` | `10.0.10.1` | Application servers (MSSQL, IIS Web Server, File Storage) & SIEM collector. |
| **Tier-2 (Clients & Assessment)** | `10.0.20.0/24` | `10.0.20.1` | Corporate workstations and assessment emulation endpoint. |

---

## 2. Virtual Machine Specifications

| Hostname | Operating System | RAM | vCPU | IP Address | Roles / Services Installed |
|---|---|---|---|---|---|
| `DC01.corp.local` | Windows Server 2022 Standard | 4 GB | 2 | `10.0.0.5` | Active Directory Domain Services (AD DS), DNS, Kerberos KDC |
| `APP01.corp.local` | Windows Server 2022 Standard | 4 GB | 2 | `10.0.10.20` | IIS Web Services, MSSQL instance, member server |
| `SIEM01` | Ubuntu Server 22.04 LTS | 8 GB | 4 | `10.0.10.50` | Splunk Enterprise / Sysmon Log Forwarder Receiver |
| `WKSTN01.corp.local` | Windows 10/11 Enterprise | 4 GB | 2 | `10.0.20.15` | Standard domain member workstation (initial compromised endpoint) |
| `ANALYST-NODE` | Kali Linux 2024.x | 4 GB | 2 | `10.0.20.99` | Telemetry validation, query testing, and security auditing |

---

## 3. Telemetry Collection Flow

1. **Sysmon Configuration:** Deployed across all Windows endpoints using a hardened configuration profile (filtering benign noise while monitoring process injection, LSASS access, and remote thread creation).
2. **Windows Event Forwarding (WEF):** Centralized subscription pushing Security Event logs from endpoints directly to the SIEM receiver.
3. **PowerShell Auditing:** Group Policy configured for:
   * Module Logging (PowerShell 4103)
   * Script Block Logging (PowerShell 4104)
   * Transcription Logging (to a secured central share)
