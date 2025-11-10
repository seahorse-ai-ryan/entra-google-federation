# Administrator's Guide to Federation Setup

This guide details the one-time setup that an IT administrator must perform to federate Google Workspace and Microsoft Entra.

**Your Role (Human):** You will be performing actions in the Google Workspace Admin Console and the Microsoft Entra Admin Center. You will also be asked to sign in to your administrator account when the scripts prompt you.

**Running Scripts:** You can run the PowerShell scripts yourself, or use an AI agent with CLI tool access (like Cursor, GitHub Copilot, etc.) to execute them on your behalf. Some tasks **must** be done by a human (signing in, clicking buttons in web UIs).

---

## **Step 0: Create Your Microsoft Entra Tenant (First-Time Only)**

**If you already have a Microsoft Entra tenant, skip to Prerequisites below.**

As of May 2025, Microsoft requires a paid license to create new Entra tenants directly through Azure Portal. The workaround is to create a tenant through a Microsoft 365 trial.

### **Create Tenant via Microsoft 365 Trial**

1.  **Go to:** https://www.microsoft.com/en-us/microsoft-365/enterprise/office-365-e3
2.  **Click:** "Free trial" (requires payment method, but you can cancel before being charged)
3.  **During setup:**
    *   Use any email address to start (e.g., your personal email)
    *   Choose your organization name (e.g., "LGITech")
    *   This creates your `.onmicrosoft.com` domain (e.g., `lgitech.onmicrosoft.com`)
    *   Create your first admin account (e.g., `admin@lgitech.onmicrosoft.com`)
4.  **Complete trial setup:**
    *   Set up Microsoft Authenticator for MFA
    *   You now have a functioning Entra ID tenant (free tier)
5.  **Cancel the trial** (optional):
    *   After setup completes, you can cancel the Microsoft 365 trial
    *   **The Entra ID tenant remains free and active** - it doesn't get deleted

### **Add Your Custom Domain**

1.  **Sign in to:** https://entra.microsoft.com with your `.onmicrosoft.com` account
2.  **Navigate to:** `Identity > Settings > Domain names`
3.  **Click:** "+ Add custom domain"
4.  **Enter your domain:** `your-domain.com` (e.g., `lgitech.net`)
5.  **Copy the TXT record Microsoft provides:**
    *   Microsoft will show a verification screen with a TXT record
    *   Example: `MS=ms82479095` (your value will be unique)
    *   **Keep this browser tab open** - you'll need to click "Verify" after adding DNS
6.  **Add DNS TXT record to your domain:**
    *   Go to your DNS provider (Cloudflare, GoDaddy, Namecheap, etc.)
    *   Add a new record:
        * **Record Type:** TXT
        * **Name:** `@` (or leave blank - some providers auto-fill your domain)
        * **Value:** The `MS=ms...` string from Microsoft (paste exactly as shown)
        * **TTL:** Auto or 3600
    *   **Save** the DNS record
7.  **Wait for DNS propagation:** 5-30 minutes (sometimes faster)
    *   Test with: `nslookup -type=TXT lgitech.net` (replace with your domain)
    *   You should see the MS= value in the response
8.  **Return to Entra and click "Verify"**
    *   If successful, your domain status changes to "Verified"
    *   If it fails, wait longer and try again (DNS can be slow)
9.  **Domain is now verified** and ready for user creation

**Important:** This TXT record is ONLY for domain verification. You'll add different DNS records (CNAMEs) later in Step 6 for device enrollment.

### **Create Your First Admin with Custom Domain**

1.  **Navigate to:** `Identity > Users > All users`
2.  **Click:** "New user" → "Create new user"
3.  **Fill in:**
    *   User principal name: `yourname@your-domain.com` (use your verified custom domain)
    *   Display name: Your name
    *   **Uncheck** "Auto-generate password" → Set a temporary password
4.  **Assign Global Administrator role:**
    *   Click "Assignments" tab
    *   Click "Add role" → Select "Global Administrator"
5.  **Create user**
6.  **Send the temporary password** to yourself securely
7.  **Sign out** and **sign back in** with your new custom domain account
8.  **Change password** and **set up MFA** when prompted

**Important Notes:**
- The Microsoft password you set is **temporary** - after federation, users will authenticate via Google Workspace
- You can create additional admins now, or wait until after SCIM provisioning (they'll sync automatically from Google Workspace)
- Keep the `.onmicrosoft.com` account credentials in a secure location as a backup

---

## **Prerequisites**

1.  **Global Administrator Account:** An account with "Global Administrator" rights in your Microsoft Entra tenant (e.g., `admin@<your-tenant>.onmicrosoft.com`). Entra ID is **free** - no paid subscription required.
2.  **Google Workspace Admin Account:** An account with "Super Admin" rights in your Google Workspace.
    *   **Required license:** Business Plus ($22/user/mo), Enterprise Standard ($27/user/mo), or Enterprise Plus ($35/user/mo)
    *   **Not supported:** Business Starter, Business Standard, Free, or Non-profit editions (these lack SAML SSO)
    *   *(Pricing approximate as of Oct 2025, varies by region/contract)*
3.  **Verified Domain:** Your custom domain (e.g., `<your-domain.com>`) must be successfully added and verified in **both** Google Workspace and Microsoft Entra.
4.  **PowerShell Scripts:** The scripts from this repository must be available on your local machine.
5.  **DNS Access:** Ability to add CNAME records to your domain (required for device enrollment).

### **Important: Set Up Multiple Administrators (Redundancy)**

For business continuity, you should have at least 2-3 administrators in both systems.

**Timing matters:** You have two options for adding additional admins:

#### **Option A: Add Admins Before Federation (Manual)**

If you need multiple Global Administrators to help with the initial federation setup:

**Microsoft Entra:**
1.  Go to `entra.microsoft.com`
2.  Navigate to `Identity > Users > All users`
3.  Click "New user" → "Create new user"
4.  Create user with your custom domain (e.g., `alex@your-domain.com`)
5.  Set a temporary password
6.  Click `Assigned roles` → `Add assignments`
7.  Search for and select **"Global Administrator"**
8.  Click **Add**
9.  Send the temporary password securely to the user

**Note:** The Microsoft password is temporary - after federation, they'll authenticate via Google Workspace.

**Google Workspace:**
1.  Go to `admin.google.com`
2.  Navigate to `Directory > Users`
3.  Create or select a user
4.  Click `Admin roles and privileges`
5.  Toggle **"Super Admin"** to ON
6.  Click **Save**

#### **Option B: Add Admins After Federation (Recommended)**

After you complete Steps 1-5 (federation + SCIM provisioning):

1.  **Create user in Google Workspace** (`admin.google.com > Directory > Users`)
2.  **User automatically appears in Entra** (via SCIM sync, wait 5-10 minutes)
3.  **Promote to Global Admin in Entra:**
    *   Go to `entra.microsoft.com > Identity > Users`
    *   Find the synced user
    *   Click `Assigned roles` → `Add assignments` → "Global Administrator"
4.  **Done** - they sign in with their Google Workspace password (no Microsoft password needed)

**Recommended admin setup:**
- At least 2 Super Admins in Google Workspace
- At least 2 Global Administrators in Microsoft Entra
- Use work email addresses (not personal ones)
- Keep the `.onmicrosoft.com` backup account credentials in a secure location

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
3.  **Configure SAML Settings (Service Provider Details):**
    
    **On the "Service provider details" screen:**
    
    *   **ACS URL:** `https://login.microsoftonline.com/login.srf` (pre-filled, do not change)
    *   **Entity ID:** `urn:federation:MicrosoftOnline` (pre-filled, do not change)
    *   **Start URL (optional):** Leave blank or add domain hint (see below)
    *   **Signed response:** Leave **unchecked**
    
    **Optional - Add Domain Hint to Start URL:**
    If you want the "Test login" button to work properly, add:
    ```
    https://login.microsoftonline.com/login.srf?wa=wsignin1.0&whr=your-domain.com
    ```
    (Replace `your-domain.com` with your actual domain like `lgitech.net`)
    
    **On the "Attribute mapping" screen:**
    
    *   **Name ID format:** Select **"EMAIL"**
    *   **Name ID:** Map to **"Basic Information > Primary Email"**
    
    Click **Continue**
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
    *   In your "Microsoft Office 365" SAML app in Google Workspace, find the "Auto-provisioning" section and click **Configure auto-provisioning**.
2.  **Initial Attribute Mapping Screen (before authorization):**
    *   The first page shows a single mapping (`Primary email → IDPEmail`)
    *   Leave the default mapping as-is and click **Continue**
3.  **Authorize (use `.onmicrosoft.com` admin if needed):**
    *   You will be redirected to a Microsoft sign-in page
    *   Sign in with a Global Administrator account **that is not yet federated** (your bootstrap `@<tenant>.onmicrosoft.com` admin works best)
    *   On the "Permissions requested" screen, check **Consent on behalf of your organization** and click **Accept**
    *   If you sign in with a freshly federated admin and see `invalid_scope`, retry using the `.onmicrosoft.com` admin
4.  **Full Attribute Mapping (after authorization):**
    *   After granting consent, Google shows the full attribute list
    *   Configure the required mappings:
        *   **`userPrincipalName` (Required):** `Contact Information > Email > Value`
        *   **`onPremisesImmutableId` (Required):** `Contact Information > Email > Value`
        *   **`mailNickname` (Required):** `Additional details > Alias name` (or map to a static expression)
    *   Optionally map `givenName`, `surname`, `jobTitle`, etc.
    *   Always choose **Email > Value** (not "Is Primary") for email fields
    *   Click **Continue**
5.  **Provisioning Scope (optional):**
    *   Choose whether to sync all users or specific groups
    *   For most small organizations, "Sync all users" is simplest
    *   Click **Next**
6.  **Deprovisioning Settings:**
    *   Decide how to handle suspensions/deletions
    *   Recommended: **Suspend** Microsoft accounts when a user is disabled, but do **not hard delete** (prevents accidental data loss)
    *   Adjust timing as desired (24 hours default is fine)
    *   Click **Finish**
7.  **Enable Provisioning:**
    *   Back on the Auto-provisioning overview, set the status to **ON**
    *   Google will perform an initial sync; monitor the log for any errors

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

## **Step 6: Configure DNS Records for Device Enrollment (REQUIRED)**

**Goal:** Add DNS records so Windows devices can find and join your Entra tenant during OOBE.

**Why this is required:** Without these DNS records, Windows devices won't know where to enroll when a user signs in with `@your-domain.com` credentials. The device join will fail silently, and users won't be able to complete setup.

**Human Action Required:**

1.  **Identify your DNS provider:**
    *   This is where your domain's DNS is hosted (e.g., Cloudflare, GoDaddy, Namecheap, Google Domains)
    *   Not sure? Check your domain registrar or ask your IT team
2.  **Get the DNS record values from Entra:**
    *   Go to `entra.microsoft.com`
    *   Navigate to `Identity > Devices > Device settings`
    *   Scroll down to **"Entra domain join"** or look for **"MDM and MAM"** section
    *   You should see instructions showing the CNAME records needed
    *   **Alternative:** Use the standard Microsoft values below (they work for most tenants)
3.  **Add two CNAME records to your DNS:**

| Record Type | Name | Target/Value |
|------------|------|--------------|
| CNAME | `enterpriseenrollment` | `enterpriseenrollment-s.manage.microsoft.com` |
| CNAME | `enterpriseregistration` | `enterpriseregistration.windows.net` |

**Example for `seahorsetwin.com`:**
- `enterpriseenrollment.seahorsetwin.com` → `enterpriseenrollment-s.manage.microsoft.com`
- `enterpriseregistration.seahorsetwin.com` → `enterpriseregistration.windows.net`

4.  **Verify DNS propagation:**
    *   DNS changes can take 5-60 minutes to propagate
    *   Test using: `nslookup enterpriseenrollment.your-domain.com`
    *   You should see the Microsoft target in the response

**DNS Provider-Specific Instructions:**

- **Cloudflare:** DNS > Records > Add record > Type: CNAME
- **GoDaddy:** DNS Management > Add > Type: CNAME
- **Namecheap:** Advanced DNS > Add New Record > Type: CNAME Record
- **Google Domains:** DNS > Custom resource records > Type: CNAME

**Important Notes:**
- Some DNS providers auto-append your domain name - enter just `enterpriseenrollment` without `.your-domain.com`
- Disable "Proxy" mode in Cloudflare for these records (set to "DNS only")
- TTL can be set to "Auto" or 3600 (1 hour)

---

## **Step 7: Enable Google Workspace Device Management (Recommended)**

While devices are joined to Entra for authentication, you should also enable Google Workspace device management for easier device tracking and remote wipe capabilities.

**Human Action Required:**

1.  **Navigate to Windows Settings:**
    *   Go to `admin.google.com`
    *   Navigate to `Devices > Mobile and endpoints > Settings > Windows`
2.  **Enable Device Management (WITHOUT GCPW):**
    *   Under **"Windows management setup"** section:
        * Set **"Windows device management"** to **"Enabled"**
        * Click **Save**
    *   Under **"Account settings"** section:
        * **Leave "Administrative privileges" as "Not configured"**
        * **Do NOT configure GCPW account settings** - Entra handles sign-in and admin rights
3.  **Verify:** Devices will appear in Google Workspace admin after users sign in

**Important - What NOT to Configure:**
- ❌ **Do NOT enable "Account settings > Administrative privileges"** - This is for GCPW sign-in, which conflicts with Entra federation
- ❌ **Do NOT set "User account type"** - Leave this section untouched
- ✅ **ONLY enable "Windows device management"** - This tracks devices without changing how users sign in

**Why enable device management?**
- ✅ **Easier management:** Google Workspace admin console is simpler than Entra
- ✅ **Remote wipe:** Ability to remotely wipe lost/stolen devices
- ✅ **Device tracking:** See which devices users have signed into
- ✅ **Redundancy:** Devices tracked in both Google Workspace AND Entra
- ✅ **No Entra dependency:** Manage devices from Google Workspace, rarely need to touch Entra

**Device Management Locations:**
- **Google Workspace (Primary):** `admin.google.com > Devices > Mobile and endpoints > Devices`
- **Microsoft Entra (Backup):** `entra.microsoft.com > Identity > Devices > All devices`

**Note:** This device tracking does NOT interfere with Entra federation. Users still sign in via Entra (using Google credentials), but devices are tracked in both systems for redundancy.

---

## **Step 8: Prepare the Application Installer Workflow**

Users install everything with **one PowerShell command**. The public script lives in this repository (`scripts/stage1-install-essentials.ps1`) so it can be run directly from GitHub. Your job is to make sure the command and any follow-up instructions reach users in the welcome email.

### 8.1 Host the Public Script (already done in this repo)
- Keep `scripts/stage1-install-essentials.ps1` in a public GitHub repository
- Users run it with:
  ```powershell
  irm https://raw.githubusercontent.com/seahorse-ai-ryan/entra-google-federation/main/scripts/stage1-install-essentials.ps1 | iex
  ```
- The script installs Chrome, Google Drive, WhatsApp Desktop, RustDesk (binary only), OBS Studio, Zoom, and TeamViewer QuickSupport
- It sets Chrome as the default browser and retries Winget automatically if the App Installer service is still warming up

### 8.2 Provide Private Configuration Separately
Sensitive data (e.g., RustDesk server URL, public key, shared support password) should **not** live in the public script. Store those details in a private Google Drive document inside your `IT` folder. Reference that document in the welcome email and end-user instructions so users can paste the values after the installer finishes.

Recommended folder structure in Google Drive:
```
IT/
  ├── LGITech App Config Reference (Google Doc or PDF)
  └── Other internal guides
```

### 8.3 Update the Welcome Email
Use the template in `domains/<your-domain>/IT/welcome-email-template.md` as a starting point. Make sure it includes:
- The copy/paste PowerShell command shown above
- A link to the Google Drive IT folder (read-only for users)
- A reminder to open the private configuration document after the script finishes

### 8.4 Test the Flow End-to-End
1. Create a new test user in Google Workspace
2. Confirm the welcome email arrives with the command and Drive link
3. On a fresh Windows device, follow the user guide:
   - Run the PowerShell command from Edge (Terminal as Administrator)
   - After it completes, open the configuration document and apply any private settings
4. Verify all required applications are installed and functional

This streamlined process eliminates the old two-stage workflow and keeps sensitive data out of the public installer while still giving users a simple, repeatable setup experience.

---

## **Step 9: (Optional) Maintain Private Configuration References**

If any applications require credentials or settings that should not live in the public installer (e.g., RustDesk server settings, VPN profiles, license keys), store them in your private Google Drive IT folder.

**Example: RustDesk with Custom Server**

1. Create a document in the IT folder (Google Doc or PDF) named something like **"RustDesk Support Settings"**
2. Include the values users must paste after the installer runs:
   - Server address
   - Public key
   - Shared support password or PIN
3. Reference this document in the welcome email and user instructions so they know where to copy the values
4. Update the document whenever credentials change; users can refer back without downloading a new script

**Applies to any custom configs:** VPN servers, proxy settings, internal URLs, license keys, or anything else that should remain private. Keep those details in the IT folder rather than in the GitHub repository.

---

## **Step 10: Maintenance - Updating the Signing Certificate**

Google's SAML certificates have variable expiration dates. Check your Microsoft Office 365 app in Google Workspace admin console to see when your certificate expires (typically 3-5 years from creation).

**When to update:** You'll see an expiration warning in Google Workspace admin console, or your certificate details will show an approaching expiration date.

**How to update:**
1.  **Human Action:** Download the new `GoogleIDPMetadata.xml` file from the Google SAML app
2.  **Run update script:** Execute `update-federation-certificate.ps1` with the new metadata file
3.  **Verify:** Test authentication after updating

**Pro tip:** Set a calendar reminder for 30 days before expiration to avoid any service interruption.
