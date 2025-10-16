# Zero-Touch Windows Provisioning Documentation

This documentation guides you through setting up Google Workspace as the identity provider for Windows laptops, enabling users to sign in with their Google credentials during Out-of-Box Experience (OOBE).

## What is This Project?

This project creates a "Zero-Touch" deployment system for new Windows laptops. Remote users can unbox a new computer, connect to Wi-Fi, and sign in using only their company Google Workspace email and password. Applications are then installed via a simple one-command script.

## How It Works

We create a trust relationship called **identity federation** between Microsoft Entra ID (Azure AD's successor - the cloud identity service for Windows, similar to Active Directory but cloud-based) and Google Workspace (your identity provider). When users type their `@<your-domain.com>` email into Windows, they're redirected to Google for authentication.

**Why Entra?** Without this federation, Windows only accepts Microsoft accounts or local accounts. Entra federation is the *only* way to enable Google Workspace sign-in on Windows. Entra is **free** for this basic usage - no licensing required.

Once authenticated, their account is automatically created in Microsoft Entra via **SCIM provisioning**. The user then runs PowerShell scripts to install organization-specific applications via **Winget** (Windows Package Manager - like apt/brew for Windows, built into Windows 11).

## Why PowerShell Scripts?

While both Google Workspace and Microsoft Entra have web-based admin interfaces, federating a domain requires specific API calls that are most reliably accessed through PowerShell. The Entra web UI can be misleading (e.g., showing errors about missing fields that aren't actually required). Our scripts handle these API complexities and correctly parse metadata files in a single, repeatable process.

---

## Setup Process Overview

### For Administrators (One-Time Setup)

The initial setup requires configuring both Google Workspace and Microsoft Entra ID, then running PowerShell scripts to establish the federation trust.

**📖 [Complete Administrator Setup Guide →](admin-setup.md)**

**Time Required:** 1-2 hours

**Prerequisites:**
- Global Administrator access to Microsoft Entra (free)
- Super Admin access to Google Workspace
  - **Required license:** Business Plus, Enterprise Standard, or Enterprise Plus
  - Business Starter/Standard do NOT support SAML SSO
- Verified custom domain in both systems
- PowerShell 7.0+

**Steps:**
1. Configure Device Settings in Entra (local admin rights)
2. Set up SAML app in Google Workspace
3. Configure auto-provisioning (SCIM)
4. Enable authentication methods (Microsoft Authenticator)
5. Run federation script
6. Verify configuration

---

### For End Users (New Laptop Setup)

Once federation is configured, users can set up new laptops themselves following a simple guide.

**📖 [End-User Setup Guide →](windows-setup-guide.md)**

**Time Required:** 15-20 minutes

**Process:**
1. Connect to Wi-Fi during OOBE
2. Choose "Set up for work or school"
3. Sign in with Google Workspace credentials
4. Skip promotional offers (Microsoft 365, McAfee, etc.)
5. **Immediately** set up Windows Hello PIN
6. Run application deployment script

---

### Application Installation

After signing into Windows, users install applications with a single PowerShell command.

**📖 [Application Installation & Configuration Guide →](app-setup-guide.md)**

**Time Required:** 2 minutes of user time, 10-15 minutes of installation time

**What Gets Installed:**
- **Stage 1 (Universal):** Chrome + Google Drive
- **Stage 2 (Organization-specific):** Custom applications such as:
  - Communication tools (Slack, Teams, Zoom, WhatsApp)
  - Development tools (VS Code, Git, Docker)
  - Productivity software (Adobe Reader, Notion)
  - Industry-specific applications
  - Remote support tools (RustDesk, TeamViewer)

---

## Additional Resources

### For Decision Makers

**📊 [Deployment Strategy Comparison](deployment-strategy.md)** - Why we chose Winget over Intune or GCPW (saves $960/year per 10 users)

### For Troubleshooting

- **Federation issues:** See [Administrator Setup Guide](admin-setup.md)
- **PIN setup failures:** See [End-User Guide](windows-setup-guide.md) troubleshooting section
- **App installation problems:** See [App Setup Guide](app-setup-guide.md)

---

## Maintenance

### Certificate Rotation (Every ~5 Years)

When Google rotates their SAML signing certificate, download the new metadata from Google Workspace and run the `update-federation-certificate.ps1` script. See the [Administrator Setup Guide](admin-setup.md) for details.

### Adding New Domains

This toolkit is designed to work with multiple domains. Simply create a new `domains/<new-domain.com>/` folder, download the metadata, and run the federation script with new parameters. No code changes required.

---

## Security Notes

- User accounts sync from Google Workspace to Entra (one-way)
- Users get local administrator rights on their devices (configurable)
- Microsoft Authenticator is required for Windows Hello PIN setup
- Federation certificates stored in Entra (not in this repository)
- Device management handled through Microsoft Entra admin center

---

## Requirements

**Hardware:**
- **Windows 11 Pro** (preferred for drop-ship)
  - Home edition *can* be upgraded during OOBE with a Pro product key, but this is technical and may confuse non-technical users
- **TPM 2.0 chip** (Trusted Platform Module - security hardware included in all laptops manufactured since 2016, required for Windows Hello PIN)

**Software:**
- PowerShell 7.0+ (for administrators)
- Microsoft.Graph PowerShell modules (for administrators)
- Winget (Windows Package Manager - included in Windows 11 by default)

**Access:**
- Global Administrator role in Microsoft Entra
- Super Admin role in Google Workspace
- Verified custom domain in both systems

---

## Quick Links

- **Administrator Guide:** [admin-setup.md](admin-setup.md)
- **End-User Guide:** [windows-setup-guide.md](windows-setup-guide.md)
- **App Installation:** [app-setup-guide.md](app-setup-guide.md)
- **Microsoft Entra Admin:** https://entra.microsoft.com
- **Google Workspace Admin:** https://admin.google.com

