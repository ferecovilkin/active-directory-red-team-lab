# VMware Lab Architecture & Topology Specifications

**Environment Type:** Isolated Virtual Network (VMware Workstation Pro / VMware ESXi)  
**Target Domain:** `CORP.LOCAL`  
**Network Mode:** NAT Network (`VMnet8` / `192.168.100.0/24`)

---

## 1. Virtual Machine Inventory & Network Assignments

```
             ┌───────────────┐
             │     Kali      │
             │   RED TEAM    │
             │192.168.100.99 │
             └───────┬───────┘
                     │
         NAT Network (VMnet8 / 192.168.100.0/24)
                     │
        ┌────────────┴────────────┐
        │                         │
 ┌──────▼──────┐           ┌──────▼──────┐
 │   WKSTN01   │           │    APP01    │
 │ Windows 11  │           │ Win Server  │
 │192.168.100.15│          │ IIS / MSSQL │
 │ Domain User │           │192.168.100.20│
 └──────┬──────┘           └──────┬──────┘
        │                         │
        └────────────┬────────────┘
                     │
              ┌──────▼──────┐
              │    DC01     │
              │ Domain Ctrl │
              │ CORP.LOCAL  │
              │192.168.100.5 │
              └─────────────┘
```

| Hostname | Operating System | Network Adapter | IP Address | Subnet Mask | Default Gateway | Primary DNS | RAM / vCPU |
|---|---|---|---|---|---|---|---|
| **`DC01`** | Windows Server 2022 Standard | NAT (`VMnet8`) | `192.168.100.5` | `255.255.255.0` | `192.168.100.2` | `127.0.0.1` | 4 GB / 2 vCPU |
| **`APP01`** | Windows Server 2022 Standard | NAT (`VMnet8`) | `192.168.100.20` | `255.255.255.0` | `192.168.100.2` | `192.168.100.5` | 4 GB / 2 vCPU |
| **`WKSTN01`** | Windows 11 Enterprise | NAT (`VMnet8`) | `192.168.100.15` | `255.255.255.0` | `192.168.100.2` | `192.168.100.5` | 4 GB / 2 vCPU |
| **`KALI`** | Kali Linux 2024.x | NAT (`VMnet8`) | `192.168.100.99` | `255.255.255.0` | `192.168.100.2` | `192.168.100.5` | 4 GB / 2 vCPU |

---

## 2. VMware Virtual Network Configuration

1. Open **Virtual Network Editor** in VMware Workstation.
2. Select or configure **`VMnet8`**:
   * Type: **NAT** (Used to share host's IP address and provide outbound internet connectivity)
   * Subnet IP: `192.168.100.0`
   * Subnet Mask: `255.255.255.0`
   * Gateway IP: `192.168.100.2` (via NAT Settings)
   * Static IP assignments configured across all lab nodes for reliable Active Directory DNS resolution.
3. Connect all 4 VMs to the **`VMnet8` (NAT)** network adapter.

---

## 3. Provisioning Automation

The domain configuration, OU structures, user accounts, and intentional vulnerabilities can be generated automatically on `DC01` by running:

```powershell
.\scripts\Setup-LabEnvironment.ps1
```
