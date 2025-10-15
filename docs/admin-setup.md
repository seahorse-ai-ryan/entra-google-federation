# Administrator's Guide to Federation Setup

This guide details the one-time setup that an IT administrator must perform to federate Google Workspace and Microsoft Entra.

**Your Role (Human):** You will be performing actions in the Google Workspace Admin Console and the Microsoft Entra Admin Center. You will also be asked to sign in to your administrator account when the scripts prompt you.

**Running Scripts:** You can run the PowerShell scripts yourself, or use an AI agent with CLI tool access (like Cursor, GitHub Copilot, etc.) to execute them on your behalf. Some tasks **must** be done by a human (signing in, clicking buttons in web UIs).

## **Prerequisites**

1.  **Global Administrator Account:** An account with "Global Administrator" rights in your Microsoft Entra tenant (e.g., `admin@<your-tenant>.onmicrosoft.com`).
2.  **Google Workspace Admin Account:** An account with "Super Admin" rights in your Google Workspace.
3.  **Verified Domain:** Your custom domain (e.g., `<your-domain.com>`) must be successfully added and verified in **both** Google Workspace and Microsoft Entra.
4.  **PowerShell Scripts:** The scripts from this repository must be available on your local machine.

### **Important: Set Up Multiple Administrators (Redundancy)**

For business continuity, you should have at least 2-3 administrators in both systems:

**Microsoft Entra:**
1.  Go to `entra.microsoft.com`
2.  Navigate to `Identity > Users > All users`
3.  Select a user (or create a new one)
4.  Click `Assigned roles` → `Add assignments`
5.  Search for and select **"Global Administrator"**
6.  Click **Add**

**Google Workspace:**
1.  Go to `admin.google.com`
2.  Navigate to `Directory > Users`
3.  Select a user
4.  Click `Admin roles and privileges`
5.  Toggle **"Super Admin"** to ON
6.  Click **Save**

**Recommended admin setup:**
- At least 2 Super Admins in Google Workspace
- At least 2 Global Administrators in Microsoft Entra
- Use work email addresses (not personal ones)
- Document admin accounts in a secure location

---

## **Step 1: Configure Device Settings in Entra (CRITICAL)**

**Goal:** Ensure users automatically get local administrator rights when they join devices to Entra. This is **required** for PIN setup to work.

**Human Action Required:**

1.  **Navigate to Device Settings:**
    *   Go to `entra.microsoft.com`
    *   Navigate to `Identity > Devices > Device settings`
2.  **Configure Local Administrator Settings:**
    *   Find **"Local administrator settings"** section
    *   Set **"Global administrator role is added as local administrator"** to **Yes**
    *   Set **"Registering user is added as local administrator"** to **All**
3.  **Save:**
    *   Click **Save** at the top of the page

**Why this is critical:** Windows Hello PIN setup requires local administrator privileges. Without this setting, users cannot set up a PIN after joining the device, and they'll be locked out after the first reboot.

---

## **Step 2: Configure the SAML App in Google Workspace**

**Goal:** To configure the "Microsoft Office 365" app in Google Workspace, which will act as the identity provider for Microsoft and generate the metadata we need.

**Human Action Required:**

1.  **Navigate to Web and Mobile Apps:**
    *   Go to `admin.google.com`.
    *   In the menu, navigate to `Apps > Web and mobile apps`.
2.  **Add the App:**
    *   Click `Add app > Search for apps` and search for "Microsoft Office 365".
    *   Select the official app and proceed through the initial screens.
3.  **Configure SAML Settings:**
    *   Under "Service provider details", you'll see fields for ACS URL and Entity ID
    *   Leave these at their default values (Microsoft's URLs)
    *   Under "Attribute mapping", configure:
        * **Name ID format**: Select "EMAIL"
        * **Name ID**: Map to "Basic Information > Primary Email"
4.  **Download Metadata:**
    *   You will land on a page with "Google Identity Provider details". Click **Download Metadata**.
    *   The file will be named `GoogleIDPMetadata.xml`. Save it into the `domains/<your-domain.com>/` folder in this repository.
5.  **Finish and Assign:**
    *   Continue through the setup wizard
    *   Once the app is created, make sure to turn it **ON for everyone**.

---

## **Step 3: Configure Auto-Provisioning in Google Workspace**

**Goal:** To automatically sync users from Google Workspace to Microsoft Entra, ensuring their accounts are ready for them.

**Human Action Required:**

1.  **Navigate to Auto-Provisioning:**
    *   In your "Microsoft Office 365" SAML app in Google Workspace, find the "Auto-provisioning" section and click `Configure auto-provisioning`.
2.  **Authorize:**
    *   You will be redirected to a Microsoft sign-in page. Sign in with your Global Administrator account.
    *   On the "Permissions requested" screen, check "Consent on behalf of your organization" and click **Accept**.
3.  **Configure Attribute Mappings:**
    *   This is **different** from the SAML mapping - this is for auto-provisioning user accounts
    *   **`userPrincipalName` (Required):** Map to `Contact Information > Email > Value`
    *   **`onPremisesImmutableId` (Required):** Map to `Contact Information > Email > Value` (yes, same as above)
    *   **Important:** Use "Email > Value", NOT "Is Primary" (which is a boolean)
    *   Map other attributes like `givenName` and `surname` as needed
4.  **Enable Provisioning:**
    *   Define the scope (which users to sync) and enable auto-provisioning.

---

## **Step 4: Configure Authentication Methods (Required for PIN Setup)**

**Goal:** Enable the registration campaign to ensure users can set up Windows Hello PIN after joining devices.

**Human Action Required:**

1.  **Navigate to Authentication Methods:**
    *   Go to `entra.microsoft.com`
    *   Navigate to `Protection > Authentication methods > Registration campaign`
2.  **Enable Registration Campaign:**
    *   Click **Edit** next to "Microsoft Authenticator"
    *   Set **State** to **Enabled**
    *   Set **Target** to **All users**
    *   Click **Save**

**Why this is required:** Users need at least one authentication method registered before they can create a Windows Hello PIN. This campaign prompts users to register Microsoft Authenticator during their first sign-in.

---

## **Step 5: Run the Federation Script**

**Goal:** To use the downloaded metadata to create the federation trust in Microsoft Entra.

**AI Agent Action:**

The AI will now execute the `apply-federation-simple.ps1` script, providing the necessary details for your environment.

```powershell
pwsh ./scripts/apply-federation-simple.ps1 `
    -TenantId "<your-entra-tenant-id>" `
    -DomainId "<your-domain.com>" `
    -MetadataPath "./domains/<your-domain.com>/GoogleIDPMetadata.xml"
```

**Human Action Required:**

A browser window will open. Sign in with your Microsoft Global Administrator account. The script will then automate the rest of the process.

**Verification:**

In the Microsoft Entra Admin Center (`entra.microsoft.com`), navigate to `Identity > Domains > Custom domain names`. Your domain should now be marked as "Federated".

---

## **Step 6: Enable Google Workspace Device Management (Recommended)**

While devices are joined to Entra for authentication, you should also enable Google Workspace device management for easier device tracking and remote wipe capabilities.

**Human Action Required:**

1.  **Navigate to Windows Settings:**
    *   Go to `admin.google.com`
    *   Navigate to `Devices > Mobile and endpoints > Settings > Windows`
2.  **Enable Device Management:**
    *   Click **Windows management setup**
    *   Select **"Enabled"** for "Windows device management"
    *   Click **Save**
3.  **Verify:** Devices will appear in Google Workspace admin after users sign in

**Why enable this?**
- ✅ **Easier management:** Google Workspace admin console is simpler than Entra
- ✅ **Remote wipe:** Ability to remotely wipe lost/stolen devices
- ✅ **Device tracking:** See which devices users have signed into
- ✅ **Redundancy:** Devices tracked in both Google Workspace AND Entra

**Device Management Locations:**
- **Google Workspace:** `admin.google.com > Devices > Mobile and endpoints > Devices`
- **Microsoft Entra:** `entra.microsoft.com > Identity > Devices > All devices`

**Note:** Enabling Google device management does NOT interfere with Entra federation. Both systems can track devices simultaneously.

---

## **Step 7: Deploy Application Installation Scripts**

Users need access to the installation scripts after setting up Windows. You have two options:

### **Host Stage 1 Script Publicly**

Host the Stage 1 script on GitHub (public repo) or a public web server so users can access it via Edge during initial setup.

**Steps:**
1.  **Create a public GitHub repository** OR use an existing one
2.  **Upload `scripts/stage1-install-essentials.ps1`** to the repo
3.  **Get the raw file URL:**
    *   On GitHub: Click the file → Click "Raw" button → Copy URL
    *   Example: `https://raw.githubusercontent.com/your-org/your-repo/main/stage1-install-essentials.ps1`
4.  **Provide this URL to users** (they'll use Edge to access it during initial setup)

### **Create Your Stage 2 Script**

The Stage 2 script is organization-specific and must be created for your needs.

**Steps:**
1.  **Copy the template:**
    *   Use `scripts/stage2-template.ps1` as a starting point
    *   Save to `domains/<your-domain>/stage2-install-apps.ps1`
2.  **Customize for your organization:**
    *   Edit the `$appsToInstall` list to include your required applications
    *   Find Winget package IDs using: `winget search "app name"`
    *   Add any custom configuration sections
3.  **Upload to Google Drive:**
    *   Create an `IT` folder in Google Drive:
        * Option A: `My Drive > IT` (for smaller teams)
        * Option B: `Shared drives > [Your Team Drive] > IT` (recommended)
    *   Upload your customized Stage 2 script to the IT folder
    *   If using custom configs (e.g., RustDesk), upload those too
4.  **Set permissions:**
    *   Ensure all users have **"Viewer"** or **"Commenter"** access
    *   For shared drives, verify the drive is shared with your organization
5.  **Test:** Sign in as a test user and verify they can access the IT folder

**Example applications organizations commonly install:**
- Communication: Slack, Microsoft Teams, Discord
- Development: VS Code, Git, Docker
- Productivity: Notion, Evernote, Adobe Reader
- Security: VPN clients, password managers
- Industry-specific: AutoCAD, MATLAB, medical software, etc.

---

## **Step 8: (Optional) Create Custom Configuration Files**

If your Stage 2 script installs applications that require custom configuration (e.g., remote support tools with custom servers, VPN clients with server addresses, etc.), you can create configuration files that the script automatically loads.

**Example: RustDesk Remote Support Configuration**

If using a custom RustDesk server:

1.  **Create the config file:**
    *   Copy the template from `domains/<your-domain.com>/rustdesk-config.ps1`
    *   Fill in your server address, public key, and shared support password
2.  **Upload to Google Drive:**
    *   Place the config file in the same `IT` folder as your Stage 2 script
    *   Ensure all users have read access
3.  **Update your Stage 2 script:**
    *   Add logic to load and apply the config file
    *   The script template shows how to search Google Drive paths

**Applies to any application:** This pattern works for any app that needs org-specific configuration - VPN servers, proxy settings, license keys, etc.

---

## **Step 9: Maintenance - Updating the Signing Certificate**

Google's SAML certificates have variable expiration dates. Check your Microsoft Office 365 app in Google Workspace admin console to see when your certificate expires (typically 3-5 years from creation).

**When to update:** You'll see an expiration warning in Google Workspace admin console, or your certificate details will show an approaching expiration date.

**How to update:**
1.  **Human Action:** Download the new `GoogleIDPMetadata.xml` file from the Google SAML app
2.  **Run update script:** Execute `update-federation-certificate.ps1` with the new metadata file
3.  **Verify:** Test authentication after updating

**Pro tip:** Set a calendar reminder for 30 days before expiration to avoid any service interruption.
