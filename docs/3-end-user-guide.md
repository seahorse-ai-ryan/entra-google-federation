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
    *   Windows will automatically redirect you to the familiar Google sign-in page.
    *   Enter your Google password and complete any two-factor authentication steps (like a code from your phone).

4.  **Windows Setup:**
    *   Once you've authenticated with Google, you'll be returned to the Windows setup process.
    *   Follow the remaining on-screen prompts (like setting up a PIN) to finish.

5.  **Done!**
    *   Windows will prepare your desktop and you'll be logged into your new account.

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

*   **I see a Microsoft password reset screen.**
    *   This means the redirect to Google didn't work. Click "Back" and re-enter your full email address. Ensure you are typing it correctly. If the problem persists, contact IT.
*   **I get an error that my user account doesn't exist.**
    *   This is a temporary issue where your account hasn't finished syncing. Please wait 10-15 minutes and try again. If you still can't log in, contact IT.
*   **My laptop has Windows Home.**
    *   This setup only works with Windows Pro. Please contact IT for assistance with upgrading your device.
