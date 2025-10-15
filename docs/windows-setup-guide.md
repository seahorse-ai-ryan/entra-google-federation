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

## **Installing Your Applications (Two-Stage Setup)**

After your initial sign-in and PIN setup, you'll install work applications in two stages.

### **Stage 1: Install Chrome & Google Drive (5 Minutes)**

1.  **Open Microsoft Edge** (it's already installed - click the blue 'e' icon)
2.  **Right-click the Start button** → **Select "Terminal (Admin)"**
    *   If you see a security prompt, click **Yes**
    *   The window title will say **"Administrator: Windows PowerShell"**
3.  **Copy and paste this command** into the Terminal:
    ```powershell
    irm https://raw.githubusercontent.com/seahorse-ai-ryan/entra-google-federation/main/scripts/stage1-install-essentials.ps1 | iex
    ```
    *   Right-click in Terminal to paste automatically
4.  **Press Enter** and wait for Chrome and Google Drive to install (about 5 minutes)

### **Between Stages: Sign In (Important!)**

After Stage 1 completes:

1.  **Launch Chrome** from the Start menu
2.  **Sign in** with your work Google account
3.  **Google Drive should auto-launch** - sign in there too
    *   If it doesn't auto-launch, open it from the Start menu
4.  **Wait 2-3 minutes** for Google Drive to sync your files
5.  **Verify sync:** Open File Explorer → You should see "Google Drive" in the left sidebar

### **Stage 2: Install Remaining Apps (10 Minutes)**

1.  **Open File Explorer**
2.  **Navigate to Google Drive:**
    *   Click **"Google Drive"** in the left sidebar
    *   Go to **"My Drive > IT"** OR **"Shared drives > [Your Team Drive] > IT"**
    *   You should see a PowerShell script (`.ps1` file) - the filename may vary per organization
3.  **Right-click the Stage 2 script** → **"Run with PowerShell"**
    *   **Important:** You must right-click in File Explorer (not in the Google Drive web browser)
    *   If prompted "Do you want to allow this app to make changes?", click **"Yes"**
4.  **Let it run!** It will install your organization's required applications
    *   The script will show which apps are being installed
    *   You can minimize the window and continue working
    *   Estimated time: 10-15 minutes

**Troubleshooting:** If the PowerShell window opens and closes immediately:
- You may not have clicked "Yes" to the admin prompt fast enough
- Try again: Right-click → "Run with PowerShell" → Quickly click "Yes" when prompted

### **What Gets Installed:**

**Stage 1 (All organizations):**
*   Google Chrome (web browser)
*   Google Drive (file sync)

**Stage 2 (Organization-specific):**
*   Additional applications as determined by your IT department
*   This varies by organization - check with your IT admin for details

### **Expected Warnings:**

*   Some apps may show "already installed" if they came pre-installed on your device
*   Custom configuration warnings are normal (e.g., config files not found)
*   These warnings don't prevent the apps from working

### **After Installation:**

Once the script finishes, you may need to configure individual applications.

**📖 For detailed configuration instructions, see the [Application Setup Guide](app-setup-guide.md)** (for organizations using the example apps).

**General post-installation tasks:**
*   Sign into applications with your work account
*   Configure application preferences
*   Set up any required integrations
*   Test core functionality

---

## **Troubleshooting**

*   **The PIN setup screen doesn't offer a "Skip for now" button during OOBE**
    *   Look for "Cancel" or "I'll do this later" options instead.
    *   If truly stuck, proceed through the setup and set up the PIN immediately after reaching the desktop.
*   **I see a Microsoft password reset screen instead of Google**
    *   This means the redirect to Google didn't work. Click "Back" and re-enter your full email address. Ensure you are typing it correctly. If the problem persists, contact IT.
*   **I get an error that my user account doesn't exist**
    *   This is a temporary issue where your account hasn't finished syncing from Google Workspace. Wait 10-15 minutes and try again. If you still can't log in, contact IT.
*   **My laptop has Windows Home (Advanced Users Only)**
    *   This setup requires Windows Pro. You can upgrade during OOBE:
        1. At the sign-in screen, press **Fn + Shift + F10** to open Command Prompt as admin
        2. Type: `changepk.exe /ProductKey YOUR-PRO-KEY-HERE` (get the key from IT)
        3. Press Enter and wait for the upgrade to complete
        4. Close Command Prompt and continue with setup
    *   **Warning:** This is technical and easy to mess up. Strongly recommend contacting IT or purchasing a laptop with Pro pre-installed.
*   **I'm locked out after skipping PIN setup**
    *   If your screen locked before you set up a PIN, you'll need assistance from IT to reset the device. This is why setting up the PIN immediately is critical!
*   **Microsoft Authenticator setup fails**
    *   Ensure you have the Microsoft Authenticator app installed on your phone (available on iOS App Store or Google Play Store).
    *   Make sure your phone has an internet connection and Bluetooth enabled.
    *   If the QR code scan fails, try using the manual code entry option.
*   **Can I sign in with my Google password instead of a PIN?**
    *   No. After initial setup, Entra-joined devices require a local credential (PIN, password, or Windows Hello biometric) for daily sign-in and unlock. Your Google password only works during specific policy-triggered re-authentication events.
