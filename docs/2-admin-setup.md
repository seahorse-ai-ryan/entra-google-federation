# 2. Administrator's Guide to Federation Setup

This guide details the one-time setup that an IT administrator must perform to federate Google Workspace and Microsoft Entra.

**Your Role (Human):** You will be performing actions in the Google Workspace Admin Console and the Microsoft Entra Admin Center. You will also be asked to sign in to your administrator account when the scripts prompt you.

**AI's Role (Agent):** The AI will run the PowerShell scripts that perform the technical configuration.

## **Prerequisites**

1.  **Global Administrator Account:** An account with "Global Administrator" rights in your Microsoft Entra tenant (e.g., `admin@<your-tenant>.onmicrosoft.com`).
2.  **Google Workspace Admin Account:** An account with "Super Admin" rights in your Google Workspace.
3.  **Verified Domain:** Your custom domain (e.g., `<your-domain.com>`) must be successfully added and verified in **both** Google Workspace and Microsoft Entra.
4.  **PowerShell Scripts:** The scripts from this repository must be available on your local machine.

---

## **Step 1: Configure the SAML App in Google Workspace**

**Goal:** To configure the "Microsoft Office 365" app in Google Workspace, which will act as the identity provider for Microsoft and generate the metadata we need.

**Human Action Required:**

1.  **Navigate to Web and Mobile Apps:**
    *   Go to `admin.google.com`.
    *   In the menu, navigate to `Apps > Web and mobile apps`.
2.  **Add the App:**
    *   Click `Add app > Search for apps` and search for "Microsoft Office 365".
    *   Select the official app and proceed through the initial screens.
3.  **Download Metadata:**
    *   You will land on a page with "Google Identity Provider details". Click **Download Metadata**.
    *   The file will be named `GoogleIDPMetadata.xml`. Save it into the `domains/<your-domain.com>/` folder in this repository.
4.  **Finish and Assign:**
    *   Continue through the setup wizard. You do not need to change any other settings.
    *   Once the app is created, make sure to turn it **ON for everyone**.

---

## **Step 2: Configure Auto-Provisioning in Google Workspace**

**Goal:** To automatically sync users from Google Workspace to Microsoft Entra, ensuring their accounts are ready for them.

**Human Action Required:**

1.  **Navigate to Auto-Provisioning:**
    *   In your "Microsoft Office 365" SAML app in Google Workspace, find the "Auto-provisioning" section and click `Configure auto-provisioning`.
2.  **Authorize:**
    *   You will be redirected to a Microsoft sign-in page. Sign in with your Global Administrator account.
    *   On the "Permissions requested" screen, check "Consent on behalf of your organization" and click **Accept**.
3.  **Configure Attribute Mappings:**
    *   **`userPrincipalName` (Required):** Map to `Basic Information > Username`.
    *   **`onPremisesImmutableId` (Required):** Map to `Contact Information > Email > Value`.
    *   Map other attributes like `givenName` and `surname` as needed.
4.  **Enable Provisioning:**
    *   Define the scope (which users to sync) and enable auto-provisioning.

---

## **Step 3: Run the Federation Script**

**Goal:** To use the downloaded metadata to create the federation trust in Microsoft Entra.

**AI Agent Action:**

The AI will now execute the `apply-federation.ps1` script, providing the necessary details for your environment.

```powershell
pwsh ./scripts/apply-federation.ps1 `
    -TenantId "<your-entra-tenant-id>" `
    -DomainId "<your-domain.com>" `
    -MetadataPath "./domains/<your-domain.com>/GoogleIDPMetadata.xml" `
    -BrowserAuth
```

**Human Action Required:**

A browser window will open. Sign in with your Microsoft Global Administrator account. The script will then automate the rest of the process.

**Verification:**

In the Microsoft Entra Admin Center (`entra.microsoft.com`), navigate to `Identity > Domains > Custom domain names`. Your domain should now be marked as "Federated".

---

## **Step 4: Maintenance - Updating the Signing Certificate**

Google's SAML certificate expires approximately every 5 years. When it does, you'll need to update it.

1.  **Human Action:** Download the new `GoogleIDPMetadata.xml` file from the Google SAML app.
2.  **AI Agent Action:** The AI will run the `update-federation-certificate.ps1` script, which will update the trust with the new certificate.
