# 3. End-User Guide: Signing into Your New Windows Laptop

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

4.  **Expected: PIN Setup Error (This is Normal!)**
    *   You'll see a screen that says **"Use Windows Hello with your account"**
    *   Windows will attempt to set up a PIN and **will fail** with an error like "Something went wrong - We weren't able to set up your PIN."
    *   **This is expected behavior!** The PIN setup happens before Google authentication completes.
    *   **Click "Skip for now"** at the bottom of the error screen

5.  **Google Sign-In:**
    *   After skipping PIN setup, Windows will redirect you to the familiar Google sign-in page.
    *   Enter your Google password and complete any two-factor authentication steps (like a code from your phone).

6.  **Windows Setup:**
    *   Once you've authenticated with Google, you'll be returned to the Windows setup process.
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
4.  You'll be prompted to verify your identity with Google (sign in again if needed)
5.  Create a PIN (at least 4 digits, or follow the complexity requirements shown)
6.  Click **OK** to save

**Why is this required?** Windows Entra-joined devices need a local credential (PIN) for screen unlock and reboots. Your Google password only works during initial setup and specific policy-triggered events. The PIN is your day-to-day authentication method.

**What PIN should I use?** Choose something memorable but secure. This PIN only works on this specific device and doesn't affect your Google password.

---

## **Installing Your Applications (One-Time Setup)**

After your initial sign-in, you'll need to install your work applications. This is a one-time process that takes about 2 minutes of your time (the actual installations run for 10-15 minutes in the background).

### **Step-by-Step Instructions:**

1.  **Right-click the Start button** (Windows icon in the bottom-left corner)
2.  **Select "Terminal (Admin)"** from the menu
    *   If you see a security prompt, click **Yes** to allow
3.  **Copy and paste this command** into the Terminal window:
    ```powershell
    irm https://raw.githubusercontent.com/seahorse-ai-ryan/entra-google-federation/main/scripts/deploy-apps.ps1 | iex
    ```
4.  **Press Enter** and wait for the script to start
5.  **Let it run!** You'll see progress messages as each app installs. You can minimize the Terminal window and continue working.

### **What Gets Installed:**

*   Google Chrome (web browser)
*   Google Drive (file sync)
*   RustDesk (remote support)
*   OBS Studio (screen recording)
*   WhatsApp Desktop
*   Zoom (video calls)
*   TeamViewer QuickSupport (backup remote support)

### **After Installation:**

Once the script finishes, you'll see a summary of what was installed. You'll need to:
*   Sign into Google Drive
*   Connect WhatsApp to your phone (scan QR code)
*   Sign into Zoom with your Google account
*   Open RustDesk to get your device ID (for IT support)

---

## **Troubleshooting**

*   **The PIN setup screen doesn't offer a "Skip for now" button**
    *   If you don't see the "Skip for now" option, try clicking "Try again" first. The setup will fail again and should then show the skip option.
    *   Alternatively, if there's a "Cancel" or "Back" button, use that to return to the sign-in screen and re-enter your email.
*   **I see a Microsoft password reset screen instead of Google.**
    *   This means the redirect to Google didn't work. Click "Back" and re-enter your full email address. Ensure you are typing it correctly. If the problem persists, contact IT.
*   **I get an error that my user account doesn't exist.**
    *   This is a temporary issue where your account hasn't finished syncing. Please wait 10-15 minutes and try again. If you still can't log in, contact IT.
*   **My laptop has Windows Home.**
    *   This setup only works with Windows Pro. Please contact IT for assistance with upgrading your device.
*   **Error code 0x801c044f during PIN setup**
    *   This is the expected error! Simply click "Skip for now" to continue to Google sign-in.
*   **I'm locked out after skipping PIN setup during OOBE**
    *   If you skipped PIN setup and now can't unlock your device, you'll need to reset. Hold the power button to force shutdown, then restart and try logging in. If that doesn't work, you may need to reset Windows and start OOBE again (this time, set up the PIN immediately after Google authentication completes).
*   **Can I sign in with my Google password instead of a PIN?**
    *   No. After initial setup, Entra-joined devices require a local credential (PIN, password, or Windows Hello biometric). Your Google password only works during specific policy-triggered re-authentication events, not for everyday unlock.
