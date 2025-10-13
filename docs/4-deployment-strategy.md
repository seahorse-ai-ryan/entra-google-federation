# 4. Application Deployment Strategy: Decision Report

## Executive Summary

This document compares three approaches for deploying applications to Windows devices after federation with Google Workspace. For our international, semi-distributed fleet of tech-savvy users, we have selected **Option 3: Winget-based deployment script** as the optimal balance of cost, automation, and user experience.

**Bottom Line:** By choosing a single-command Winget script over Microsoft Intune, we save **$960 per year per 10 users** while maintaining 95% automation. The one-time 2-minute user action is acceptable given our technical user base.

---

## Context & Requirements

Our organization has successfully configured identity federation between Google Workspace and Microsoft Entra ID, enabling:
- Drop-ship provisioning (users can unbox and sign in with Google credentials)
- Zero-touch Windows OOBE experience
- Automatic user account creation via SCIM

**Remaining Challenge:** We need to automatically deploy applications (Chrome, RustDesk, OBS, WhatsApp, Zoom, Google Drive, TeamViewer) to newly-provisioned devices.

**Key Constraints:**
- International users (drop-shipping is highly valuable)
- Tech-savvy but non-technical users (early adopters, not engineers)
- Small fleet size (5-10 devices initially)
- Cost-sensitive (prefer avoiding recurring per-user fees)

---

## Option 1: Microsoft Intune (Full MDM)

### How It Works
Devices joined to Entra ID during OOBE automatically enroll in Intune, which pushes applications via Win32 packages or MSI installers without user intervention.

### User Experience
**Best:** True zero-touch. Apps appear automatically 15-30 minutes after first login. No user action required.

### Technical Requirements
- Intune subscription: $8/user/month
- Package each app as `.intunewin` file
- Create deployment policies in Intune Admin Center
- Assign policies to user/device groups

### Costs (10 Users)
- **Monthly:** $80
- **Annual:** $960
- **3-Year:** $2,880

### Pros
- ✅ True zero-touch automation
- ✅ Centralized management dashboard
- ✅ Advanced features (compliance policies, conditional access)
- ✅ Scheduled updates and versioning
- ✅ Detailed reporting and success metrics

### Cons
- ❌ Significant recurring cost
- ❌ Steep learning curve for admins
- ❌ Overkill for small fleets
- ❌ Requires packaging apps (time investment)

### When to Choose This
- Large fleets (50+ devices)
- Complex compliance requirements
- Budget allows for per-user licensing
- Dedicated IT staff for management

---

## Option 2: Google Workspace Device Management (GCPW)

### How It Works
Devices are NOT joined to Entra ID. Instead, Google Credential Provider for Windows (GCPW) is pre-installed on each device, enabling Google-based login and enrollment in Google's Windows device management.

### User Experience
**Good:** After GCPW is installed, login is seamless. Apps deploy automatically via Google Admin Console (MSI packages pushed via OMA-URI policies).

### Technical Requirements
- Pre-install GCPW on each device before shipping (~15 min/device)
- Package apps as MSI files
- Configure OMA-URI policies in Google Admin Console
- Workspace Enterprise license (already have)

### Costs (10 Users)
- **Monthly:** $0 (included in Workspace Enterprise)
- **Annual:** $0
- **Setup Time:** 15 min × 10 devices = 2.5 hours

### Pros
- ✅ No additional licensing cost
- ✅ Manage everything in Google Admin Console
- ✅ Sufficient for basic app deployment
- ✅ BitLocker, Windows Update controls included

### Cons
- ❌ **NOT drop-ship compatible** (requires pre-installation)
- ❌ Loses Entra ID benefits (federation work becomes irrelevant)
- ❌ Less mature than Intune for Windows management
- ❌ Limited scripting capabilities
- ❌ Must wrap configs in MSI packages

### When to Choose This
- No drop-ship requirement (can prep devices locally)
- Want to minimize recurring costs
- Prefer Google-centric management
- Don't need advanced Windows policies

### Why We Didn't Choose This
**Deal-breaker:** Abandons the Entra federation we just built and eliminates drop-ship capability, which is critical for our international users.

---

## Option 3: Winget Deployment Script (Chosen Approach)

### How It Works
Devices join Entra ID as planned. On first login, user runs a single PowerShell command that executes a Winget-based script hosted on GitHub. The script automatically installs all required applications.

### User Experience
**Very Good:** After initial login, user copies one command into Terminal (Admin) and presses Enter. Apps install automatically over 10-15 minutes. User can continue working.

**Instruction Example:**
```
Right-click Start → Windows Terminal (Admin)
Paste this and press Enter:
irm https://raw.githubusercontent.com/seahorse-ai-ryan/entra-google-federation/main/scripts/deploy-apps.ps1 | iex
```

### Technical Requirements
- Maintain `deploy-apps.ps1` script in GitHub repo
- User must have local admin rights (granted during OOBE)
- Windows 11 includes Winget by default (no installation)

### Costs (10 Users)
- **Monthly:** $0
- **Annual:** $0
- **User Time:** 2 minutes per device (one-time)
- **Maintenance:** Update script when app versions change

### Pros
- ✅ Free (no licensing)
- ✅ Preserves Entra federation + drop-ship capability
- ✅ 95% automated (Winget handles downloads, installs, configs)
- ✅ Simple to maintain (edit one script file)
- ✅ Transparent (users/admins can review script source)
- ✅ Reliable (Winget uses official vendor repositories)
- ✅ Scalable (same effort for 10 or 100 devices)

### Cons
- ❌ Requires one manual user action (running the command)
- ❌ No centralized deployment dashboard
- ❌ Success/failure tracking requires user feedback
- ⚠️ User must follow instructions correctly

### When to Choose This
- ✅ Small to medium fleets (5-50 devices)
- ✅ Cost-conscious organizations
- ✅ Tech-savvy user base
- ✅ Want to preserve Entra federation benefits
- ✅ Drop-ship capability is valuable

---

## Decision Matrix

| Criteria | Intune (Option 1) | GCPW (Option 2) | Winget (Option 3) |
|----------|-------------------|-----------------|-------------------|
| **Zero-Touch** | ✅ Full | ⚠️ Partial | ⚠️ 95% (one command) |
| **Drop-Ship Compatible** | ✅ Yes | ❌ No | ✅ Yes |
| **Cost (10 users, 1 year)** | $960 | $0 | $0 |
| **Keeps Entra Federation** | ✅ Yes | ❌ No | ✅ Yes |
| **User Effort** | None | None | 2 minutes (one-time) |
| **Admin Complexity** | High | Medium | Low |
| **Suitable for Non-Technical Users** | ✅ Yes | ✅ Yes | ✅ Yes (with clear instructions) |

---

## Final Decision: Option 3 (Winget Script)

### Why This Is the Right Choice

1. **Cost Savings:** $960/year saved vs. Intune with no functional loss for our use case.
2. **Preserves Drop-Ship:** International users can receive and provision devices without local IT support.
3. **Minimal User Burden:** Running one command is acceptable for our "early adopter" user base.
4. **Leverages Existing Work:** Keeps the Entra federation we just configured.
5. **Transparent & Auditable:** Script is open source in our repo; anyone can review what gets installed.
6. **Easy Maintenance:** Update one script file to change app versions or add new software.

### Implementation Plan

1. Create `scripts/deploy-apps.ps1` with Winget commands for all required apps
2. Add clear user instructions to `docs/3-end-user-guide.md`
3. Test script on a pilot device
4. Distribute the single-command instruction to users after OOBE
5. Monitor feedback and iterate on script as needed

### Future Considerations

If the fleet grows beyond 50 devices or users struggle with the manual command, we can revisit Intune at that time. For now, the Winget approach provides the best value for our organization's size and technical capabilities.

---

## Appendix: Winget App IDs

For reference, the Winget package IDs for our required applications:

| Application | Winget ID |
|-------------|-----------|
| Google Chrome | `Google.Chrome` |
| Google Drive | `Google.GoogleDrive` |
| RustDesk | `RustDesk.RustDesk` |
| OBS Studio | `OBSProject.OBSStudio` |
| WhatsApp | `WhatsApp.WhatsApp` |
| Zoom | `Zoom.Zoom` |
| TeamViewer QuickSupport | `TeamViewer.TeamViewer.Host` |

**Command Example:**
```powershell
winget install --id Google.Chrome --silent --accept-source-agreements --accept-package-agreements
```

