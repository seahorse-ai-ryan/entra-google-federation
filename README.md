# Entra ↔ Google Federation Toolkit

This workspace provides reusable PowerShell scripts and documentation for federating a Microsoft Entra tenant with a Google Workspace IdP and for maintaining the configuration over time.

## Directory Layout

- `scripts/`
  - `connect-graph.ps1` — launches an interactive Microsoft Graph session with all required scopes.
  - `apply-federation.ps1` — connects, disables security defaults, applies the federation payload for a domain, and reenables defaults.
  - `apply-federation-legacy.ps1` — archived two-step version kept for reference.
  - `update-federation-certificate.ps1` — imports metadata XML and rotates the signing certificate/URIs.
- `domains/<domain>/` — drop per-domain artifacts here (e.g., Google metadata, provisioning notes).
- `docs/` — project documentation (`project-goals.md`, etc.).
- `.gitignore` — excludes `domains/`, `graph_context.clixml`, and other local artifacts so the repository can be shared safely.

## Usage

1. Export metadata from Google Admin (`Download metadata`) and place it under `domains/<your-domain>/`.
2. Run `./scripts/apply-federation.ps1 -MetadataPath ./domains/<your-domain>/YourMetadata.xml -BrowserAuth` to set up federation for the domain.
3. Run `./scripts/update-federation-certificate.ps1 -MetadataPath ./domains/<your-domain>/YourMetadata.xml -BrowserAuth` whenever the Google signing cert is renewed.
4. Optional: `./scripts/connect-graph.ps1 -BrowserAuth` if you only need to launch a scoped Graph session for ad-hoc commands.

## Adding a New Domain

- Copy existing scripts; no code changes needed. Only swap in the new metadata file under `domains/<new-domain>/`.
- The scripts accept `-DomainId` so the same toolkit works for any domain.
- Document domain-specific mappings or provisioning steps in `domains/<new-domain>/README.md` if desired.

## Notes

- Security defaults are temporarily disabled and reenabled automatically inside the scripts.
- After federation, test via `https://login.microsoftonline.com/login.srf?wa=wsignin1.0&whr=<domain>`.
- Keep the domain metadata up to date and re-run the update script when Google rotates certificates.
