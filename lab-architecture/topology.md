# VMware Lab Architecture & Topology Specifications

**Environment Type:** Isolated Virtual Network (VMware Workstation Pro / VMware ESXi)  
**Target Domain:** `CORP.LOCAL`  
**Network Mode:** Host-Only (`VMnet2` / `10.0.0.0/16`)

---

## 1. Virtual Machine Inventory & Network Assignments

```
             ┌───────────────┐
             │     Kali      │
             │   RED TEAM    │
             │  10.0.20.99   │
             └───────┬───────┘
                     │
         Internal Network (VMnet2)
                     │
        ┌────────────┴────────────┐
        │                         │
 ┌──────▼──────┐           ┌──────▼──────┐
 │   WKSTN01   │           │    APP01    │
 │ Windows 11  │           │ Win Server  │
 │ 10.0.20.15  │           │ IIS / MSSQL │
 │ Domain User │           │ 10.0.10.20  │
 └──────┬──────┘           └──────┬──────┘
        │                         │
        └────────────┬────────────┘
                     │
              ┌──────▼──────┐
              │    DC01     │
              │ Domain Ctrl │
              │ CORP.LOCAL  │
              │  10.0.0.5   │
              └─────────────┘
```

| Hostname | Operating System | Network Adapter | IP Address | Subnet Mask | Default Gateway | Primary DNS | RAM / vCPU |
|---|---|---|---|---|---|---|---|
| **`DC01`** | Windows Server 2022 Standard | Custom (`VMnet2`) | `10.0.0.5` | `255.255.0.0` | `10.0.0.1` | `127.0.0.1` | 4 GB / 2 vCPU |
| **`APP01`** | Windows Server 2022 Standard | Custom (`VMnet2`) | `10.0.10.20` | `255.255.0.0` | `10.0.0.1` | `10.0.0.5` | 4 GB / 2 vCPU |
| **`WKSTN01`** | Windows 11 Enterprise | Custom (`VMnet2`) | `10.0.20.15` | `255.255.0.0` | `10.0.0.1` | `10.0.0.5` | 4 GB / 2 vCPU |
| **`KALI`** | Kali Linux 2024.x | Custom (`VMnet2`) | `10.0.20.99` | `255.255.0.0` | `10.0.0.1` | `10.0.0.5` | 4 GB / 2 vCPU |

---

## 2. VMware Virtual Network Configuration

1. Open **Virtual Network Editor** in VMware Workstation.
2. Configure **`VMnet2`**:
   * Type: **Host-only** (Connect VMs internally in a private network)
   * Subnet IP: `10.0.0.0`
   * Subnet Mask: `255.255.0.0`
   * Uncheck "Use local DHCP service to distribute IP address to VMs" (Static IP addressing is enforced across all lab nodes for reliability).
3. Connect all 4 VMs to the **`VMnet2`** network adapter.

---

## 3. Provisioning Automation

The domain configuration, OU structures, user accounts, and intentional vulnerabilities can be generated automatically on `DC01` by running:

```powershell
.\scripts\Setup-LabEnvironment.ps1
```
