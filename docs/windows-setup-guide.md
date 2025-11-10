# Windows Setup Guide: Signing into Your New Laptop

This guide will walk you through the simple process of signing into your new Windows laptop for the first time using your company Google account.

## **Prerequisites**

*   A new Windows 11 Pro laptop.
*   Your company Google Workspace email address (e.g., `<your-name>@<your-domain.com>`) and password.
*   A stable Wi-Fi connection.

---

## **First-Time Sign-In Steps**

1.  **Power On and Connect:**
    *   Unbox your new laptop, plug it in, and power it on.
    *   Proceed through the initial screens (language, keyboard layout) until you are prompted to connect to a network.
    *   Connect to your home or office Wi-Fi.

2.  **Choose Account Type:**
    *   On the "How would you like to set up this device?" screen, you **must** select **"Set up for work or school"**.

3.  **Sign In with Your Google Account:**
    *   When prompted to sign in, enter your full Google Workspace email address (e.g., `<your-name>@<your-domain.com>`).
    *   Click **Next**

4.  **Skip PIN Setup During Initial Setup**
    *   You'll see a screen that says **"Use Windows Hello with your account"**
    *   **Click "Skip for now"** to proceed without setting up a PIN yet
    *   **Important:** You must set up a PIN immediately after reaching the desktop (see next section)

5.  **Google Sign-In:**
    *   Windows will redirect you to the familiar Google sign-in page.
    *   Enter your Google password and complete any two-factor authentication steps (like a code from your phone).

6.  **Windows Setup - Skip Promotional Offers:**
    *   Once you've authenticated with Google, you'll be returned to the Windows setup process.
    *   **Important:** You may see offers for:
        *   **Microsoft 365** subscription - Click **"Decline"** or **"Skip"**
        *   **McAfee antivirus** trial - Click **"Decline"** or **"No thanks"**
        *   **OneDrive backup** - Click **"Skip"** (you'll use Google Drive instead)
        *   **Game Pass** or other services - Decline all promotional offers
    *   Follow the remaining on-screen prompts to finish.

7.  **Done!**
    *   Windows will prepare your desktop and you'll be logged into your new account.

---

## **CRITICAL: Set Up Your PIN Immediately**

**⚠️ You must set up a PIN before your screen locks, or you won't be able to unlock your device!**

After completing the initial setup, immediately follow these steps:

1.  Press `Windows + I` to open Settings
2.  Go to `Accounts > Sign-in options`
3.  Click **Windows Hello PIN** → **Set up**
4.  **Register Microsoft Authenticator:**
    *   You'll be prompted to set up Microsoft Authenticator
    *   Follow the on-screen instructions to install the app on your phone and scan the QR code
    *   This is a one-time setup required for security
5.  **Verify Your Identity:**
    *   After Authenticator is registered, you'll be prompted to verify your identity via the app
    *   Approve the authentication request on your phone
6.  **Create Your PIN:**
    *   Enter a PIN (at least 4 digits, or follow the complexity requirements shown)
    *   Confirm the PIN
    *   Click **OK** to save

**Why is this required?** Windows Entra-joined devices need a local credential (PIN) for screen unlock and reboots. Your Google password only works during initial setup and specific policy-triggered events. The PIN is your day-to-day authentication method.

**What PIN should I use?** Choose something memorable but secure. This PIN only works on this specific device and doesn't affect your Google password.

**About Microsoft Authenticator:** While you use Google Workspace for most things, Microsoft Authenticator is required for Windows Hello PIN setup. You'll rarely need to use it after initial setup.

**Note about administrator rights:** You have local administrator rights on this device, which means you can install software and change system settings. This is normal and intentional for your work laptop.

---

## Step 3: Run the Application Installer (One Command)

1. **Open Microsoft Edge** (the blue "e" icon - it's pre-installed)
2. **Go to Gmail:** Type `mail.google.com` in the address bar
3. **Sign in** with your `@<your-domain.com>` account
4. **Find your welcome email** from IT – it contains this command and a link to the configuration docs
5. **Right-click the Start button** (bottom-left corner of screen)
6. **Click "Terminal (Admin)"**
   - If Windows asks for permission, click **"Yes"**
7. **Copy this entire command:**

```powershell
irm https://raw.githubusercontent.com/seahorse-ai-ryan/entra-google-federation/main/scripts/stage1-install-essentials.ps1 | iex
```

8. **Right-click in the Terminal window** to paste the command, then press **Enter**
9. **Wait 10-15 minutes** while the script installs all required applications
   - The script warms up Winget, retries transient failures, and prints a success/failure summary
   - Keep the window open until it says **"Installation complete"**

### What the script installs automatically
- Google Chrome (sets it as the default browser)
- Google Drive for Desktop
- WhatsApp Desktop
- RustDesk (application only – you will add the server info next)
- OBS Studio
- Zoom
- TeamViewer QuickSupport

---

## Step 4: Sign Into Chrome & Google Drive

1. **Launch Google Chrome** from the Start menu
2. **Sign in** with your work Google account and allow Chrome to sync
3. **Launch Google Drive** (should auto-launch, or find it in Start menu)
4. **Sign in** with your work Google account
5. **Wait 2-3 minutes** for Google Drive to finish its first sync (look for the Drive icon in the system tray to show "Files up to date")

---

## Step 5: Apply Organization-Specific Settings

Some applications (such as RustDesk) require credentials that we **do not** include in the public script. Those values are stored in a private Google Drive document referenced in your welcome email.

1. Open the Google Drive link from the welcome email (or the IT folder shared with you)
2. Locate the document named something like **"LGITech - App Config Reference"**
3. Follow the instructions in that document to copy/paste configuration values into the applications that need them (e.g., RustDesk server, shared support password)
4. Keep the document handy for future reference – it will be updated if credentials change

---

## Step 6: Sign Into Your Applications

After the script finishes and you’ve copied any private configuration values, sign into each application:

### **WhatsApp Desktop**
1. Open WhatsApp from the Start menu
2. Open WhatsApp on your phone
3. Tap **Settings > Linked Devices > Link a Device**
4. **Scan the QR code** on your laptop screen

### **Google Chrome**
Chrome should already be signed in and set as your default browser. Pin it to your taskbar if you prefer quick access.

### **Google Drive**
Drive should continue syncing automatically. Confirm your shared drives are visible in File Explorer.

### **Zoom**
1. Open Zoom from the Start menu
2. Click **"Sign In"** → **"Sign in with Google"**
3. Choose your Google Workspace account (`@<your-domain.com>`)

### **RustDesk (after pasting config values)**
1. Open RustDesk from the Start menu
2. Verify the server fields now reflect your company’s server (from the config document)
3. Note your RustDesk ID and share it with IT if they request it for remote support

### **OBS Studio**
1. Launch OBS Studio and run the auto-configuration wizard (optimize for recording)
2. Verify the default recording path (`Videos\Captures`) was created

### **TeamViewer QuickSupport**
TeamViewer is ready for use – IT may direct you to open it if remote help is needed.

---

## Troubleshooting (Installation Script)
- **Winget error: "cannot be started"** – The script now retries automatically. If a package still fails, re-run the command once. Winget often needs a few seconds after first launch on brand-new machines.
- **Script window closed early** – Open Terminal (Admin) again and re-run the command. Stay on the machine until the summary appears.
- **App missing after script shows success** – Re-run the command; winget treats the second run as an upgrade check and will reinstall if necessary.

The remainder of this guide (PIN reminders, troubleshooting, Home-to-Pro upgrade, etc.) still applies – only the application section changed from two stages to one command.
