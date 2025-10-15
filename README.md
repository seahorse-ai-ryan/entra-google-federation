# Entra ↔ Google Federation Toolkit

PowerShell scripts and documentation for Zero-Touch Windows provisioning using Google Workspace as the identity provider.

## What This Does

Enables users to sign into new Windows laptops with their Google Workspace credentials during Out-of-Box Experience (OOBE), without requiring local IT support.

**Key Features:**
- ✅ Drop-ship compatible (international users can self-provision)
- ✅ Single sign-on with Google Workspace
- ✅ Automated application deployment via Winget
- ✅ No recurring per-user licensing costs (no Intune required)
- ✅ Reusable for multiple domains

## How It Works

1. **Federation:** Microsoft Entra ID trusts Google Workspace for authentication
2. **Provisioning:** User accounts sync from Google Workspace to Entra (SCIM)
3. **OOBE:** Users sign in with Google credentials during Windows setup
4. **Apps:** One PowerShell command installs all required applications

## Quick Links

📖 **[Full Documentation](docs/README.md)** - Start here for setup guides

**For Administrators:**
- [Administrator Setup Guide](docs/admin-setup.md) - One-time configuration

**For End Users:**
- [Windows Setup Guide](docs/windows-setup-guide.md) - New laptop setup
- [Application Installation Guide](docs/app-setup-guide.md) - Installing work apps

## Repository Structure

```
├── scripts/
│   ├── apply-federation-simple.ps1    # Federation setup
│   ├── stage1-install-essentials.ps1  # Chrome + Drive (all orgs)
│   ├── stage2-template.ps1            # Template for org-specific apps
│   └── ...                            # Other utility scripts
├── docs/              # Complete documentation
├── domains/           # Domain-specific configs (gitignored)
│   └── <your-domain>/
│       ├── GoogleIDPMetadata.xml      # SAML metadata
│       ├── stage2-install-apps.ps1    # Org-specific apps
│       └── *.ps1                      # Custom configs
└── README.md          # This file
```

## Requirements

- Windows 11 Pro
- Global Administrator access to Microsoft Entra
- Super Admin access to Google Workspace
- PowerShell 7.0+

## Use Cases

This toolkit is ideal for:
- Small to medium organizations (5-50 devices)
- Remote/distributed teams
- Cost-sensitive organizations avoiding Intune
- Drop-ship laptop deployments

## License

MIT

---

**Getting Started?** Head to the [Documentation](docs/README.md) for complete setup instructions.
