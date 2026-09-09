# Phase 04: Active Directory Access Control Lists (ACLs) & Graph Attack Paths

## 1. Overview
Active Directory security is fundamentally governed by Discretionary Access Control Lists (DACLs) composed of Access Control Entries (ACEs). Over years of operational delegation, administrative drift often creates unintended transitive relationship paths that allow low-privilege accounts to take over high-privilege assets.

---

## 2. Dangerous Active Directory Permissions (ACEs)

| Permission / Right | Security Implication | Exploitation Vector |
|---|---|---|
| `GenericAll` | Full control over target object | Can reset passwords, modify group memberships, edit SPNs, or add arbitrary rights |
| `WriteDacl` | Ability to modify object's DACL | Attacker grants their own account `GenericAll` permissions |
| `WriteOwner` | Ability to seize object ownership | Attacker assumes ownership, then rewrites DACL to gain full control |
| `AllExtendedRights` | Grants all extended operations | Includes `ForceChangePassword`, `User-Force-Change-Password` |
| `AddMember` | Ability to add accounts to a group | If present on `Tier1-Admins`, user promotes themselves or another account |

---

## 3. BloodHound Graph Theory in Active Directory

BloodHound maps Active Directory as a directed graph:
* **Nodes:** Users, Computers, Groups, OUs, GPOs, Domains.
* **Edges:** Rights (`MemberOf`, `AdminTo`, `HasSession`, `GenericAll`, `WriteDacl`, `AllowedToDelegate`).

### Path Discovery Simulation:
```
[User: jdoe] 
    ──(MemberOf)──► [Group: IT-Helpdesk]
    ──(GenericAll)──► [Group: Server-Admins]
    ──(AdminTo)──► [Computer: APP01]
    ──(HasSession)──► [User: da_admin] 
    ──(MemberOf)──► [Group: Domain Admins]
```
By analyzing this chain, an attacker identifies that taking over `Server-Admins` enables memory theft on `APP01`, ultimately yielding Domain Admin privileges.

---

## 4. Defensive Auditing & Mitigation

1. **Regular ACL Auditing:**
   * Periodically run graph analysis or automated PowerShell checks against administrative groups (`Domain Admins`, `Enterprise Admins`, `Schema Admins`, `Account Operators`).
2. **Break Unintended Delegation Chains:**
   * Strip explicit user permissions on administrative groups and computer objects.
   * Restrict Helpdesk accounts to password resets exclusively on Tier-2 user OUs.
3. **Restrict Session Enumeration:**
   * Disable NetSessionEnum permissions for standard domain users by restricting RPC permissions over named pipes.
