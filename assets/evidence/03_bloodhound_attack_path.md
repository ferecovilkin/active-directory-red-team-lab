# Evidence 03: BloodHound Attack Path Analysis

**Platform:** BloodHound Community Edition on Kali Linux Assessment Node  
**Data Ingestion:** SharpHound v2.x JSON Collection  
**Analysis Focus:** Shortest Path to Domain Admins

---

## Graph Query Summary & Traversal Path

```
(User: jdoe)
    │
    ├── MemberOf ──► (Group: Domain Users)
    │
(User: helpdesk_admin)
    │
    ├── GenericAll ──► (Group: Tier1-Admins)
                            │
                            ├── Member ──► (User: svc_sql)
                            │                   │
                            │                   └── AdminTo ──► (Computer: APP01)
                            │                                         │
                            │                                         └── HasSession ──► (User: da_admin)
                            │                                                                  │
                            │                                                                  └── MemberOf ──► (Group: Domain Admins)
```

### Graph Analysis Details:
* **Initial Node:** `CORP\jdoe`
* **Privilege Edge:** `svc_sql` has administrative rights (`AdminTo`) on `APP01.corp.local`.
* **Session Exposure:** BloodHound session collector discovered active high-privilege token (`da_admin`) cached on member server `APP01`.
* **Target Objective:** Take over `svc_sql` via Kerberoasting, move laterally to `APP01`, extract `da_admin` credentials.

---

## Screenshot Reference

![BloodHound Attack Path](03_bloodhound.png)
*(Screenshot: BloodHound graphical user interface displaying the shortest path from unprivileged user to Domain Admin)*
