# 1. Project Overview: Zero-Touch Windows Provisioning

## What is this project?
This project's goal is to create a "Zero-Touch" deployment system for new Windows laptops. This means a remote user can unbox a new computer, connect it to their Wi-Fi, and sign in using only their company Google Workspace email and password. All of their applications and settings are then configured automatically without needing help from IT.

## How does it work?
We achieve this by creating a trust relationship called **identity federation**. We are telling Microsoft's cloud (Entra ID), which controls Windows logins, to trust Google Workspace as the official place to verify a user's identity. When a user types their `@<your-domain.com>` email into Windows, Windows will redirect them to a Google sign-in page.

Once the user is authenticated, their account is automatically created in Microsoft Entra via a process called **SCIM provisioning**. From there, a mobile device management (MDM) solution like **Microsoft Intune** takes over to deploy applications and configurations.

## Why are PowerShell scripts required for this?
While both Google Workspace and Microsoft Entra have web-based admin interfaces, the process of federating a domain has historically been an administrative task done via command-line tools.

*   **Microsoft's APIs:** The specific API calls required to create or update a domain's federation settings are most reliably accessed through PowerShell. The Microsoft Entra UI does not currently expose a simple "federate this domain with Google" button.
*   **Error Handling:** The web UI can be misleading. For example, when uploading Google's metadata file, the Entra portal may show an error about a missing "ActiveSignInUri" because it's not explicitly in the file, even though the necessary information is present.
*   **Automation & Repeatability:** The included PowerShell scripts handle these API complexities, correctly parse the metadata file, and manage other dependencies (like temporarily disabling Security Defaults) in a single, repeatable process.

This repository contains the scripts to automate the federation setup, along with this detailed documentation. The scripts are designed to be reusable for any domain.
