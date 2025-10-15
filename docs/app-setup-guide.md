# Application Configuration Guide (Generic Template)

This is a **generic template** for application configuration. Your organization should create a customized version of this guide with your specific applications, server addresses, and support contacts.

**For organizations using this project:** Create your own version of this guide in your `domains/[your-domain]/IT/` folder and store it in Google Drive alongside your Stage 2 installation script.

**Prerequisites:** Users must have completed the [Windows Setup Guide](windows-setup-guide.md) and run both Stage 1 and Stage 2 installation scripts.

---

## Overview

After running the Stage 1 and Stage 2 installation scripts, users will have applications installed but may need configuration guidance for:
- Signing into accounts
- Connecting to custom servers
- Testing functionality
- Creating shortcuts and pinning apps

This template provides examples for common business applications. Customize it for your organization's specific needs.

---

## Post-Installation Configuration

After the automated installation completes, follow these steps to configure each application.

### 1. Google Chrome Setup

1.  **Launch Chrome** from the Start menu or desktop
2.  **Sign in** with your Google Workspace account (`@your-domain.com`)
3.  **Sync settings** will automatically enable bookmarks and extensions
4.  **Show Bookmarks Bar:** Press `Ctrl + Shift + B` to toggle the bookmarks bar
5.  **Pin to Taskbar:** Right-click Chrome icon in taskbar → **Pin to taskbar**
6.  **Optional:** Unpin Microsoft Edge if you won't use it

### 2. Google Drive Setup

1.  **Launch Google Drive** (should auto-start after installation)
2.  **Sign in** with your Google Workspace account
3.  **Folder Sync Configuration:**
    *   Click the Google Drive system tray icon (bottom-right corner)
    *   Click the gear icon → **Preferences**
    *   Under **"Google Drive"**, ensure your shared drives are visible
    *   Under **"My Computer"**, you can choose which folders to sync
4.  **Pin Shared Drive to Quick Access (if applicable):**
    *   Open File Explorer
    *   Navigate to your shared drive (e.g., "IT" or your team's shared drive)
    *   Right-click the folder → **Pin to Quick Access**

**Chrome Extension Note:** If Chrome shows an error about an extension, enable the **"Application Launcher for Drive (by Google)"** extension.

### 3. RustDesk (Remote Support)

**Note:** This section assumes your organization uses RustDesk for remote support. Customize based on your remote support tool.

**If Using a Custom RustDesk Server:**

Your Stage 2 script can automatically configure RustDesk if you placed a `rustdesk-config.ps1` file in your Google Drive IT folder.

1.  **Open RustDesk** from the Start menu
2.  **Verify server connection:**
    *   Check that the ID Server shows your team's server (not "hbbs.rustdesk.com" or blank)
    *   If configured correctly, you'll see your custom server address
3.  **Note your RustDesk ID** - support will use this to connect to your device
4.  **Share your ID with IT** via your organization's preferred method

**If RustDesk is NOT configured:**

Users may need to manually configure the server:

1.  Click the **three dots** next to your ID → **Settings** → **Network**
2.  Click **"Unlock network settings"**
3.  Enter your server details:
    *   **ID Server:** `[your-server-address]`
    *   **Relay Server:** `[your-server-address]`
    *   **API Server:** `https://[your-server-address]`
    *   **Key:** `[your-public-key]`
4.  Click **"Apply"** and verify it says "Success"

**For Standard Setup (No Custom Server):**

If using RustDesk's public servers:

1.  **Open RustDesk** from the Start menu
2.  **Note your ID number** - support will use this to connect
3.  **No configuration needed** - it works out of the box

### 4. OBS Studio (Screen Recording)

1.  **Launch OBS Studio** for the first time
2.  **Auto-Configuration Wizard:**
    *   Select **"Optimize just for recording, I will not be streaming"**
    *   Click **Next**
3.  **Video Settings:**
    *   Base Canvas Resolution: Select **"Current"** (your screen resolution)
    *   FPS: Select **30**
    *   Click **Next** → **Apply Settings**
4.  **Add Display Capture:**
    *   In the **Sources** panel (bottom-left), click **+**
    *   Select **"Display Capture"**
    *   Click **OK** → **OK** (accept defaults)
5.  **Configure Recording Settings:**
    *   Go to **File** → **Settings** → **Output**
    *   Recording Quality: **High Quality, Medium File Size**
    *   Recording Format: **Matroska Video (.mkv)**
    *   Recording Path: `C:\Users\[YourUsername]\Videos\Captures`
        * *Note: The script should have already created this folder*
    *   Click **Apply** → **OK**
6.  **Test Audio Levels:**
    *   Speak normally and watch the Audio Mixer meters (bottom)
    *   Adjust the slider if levels hit red
    *   Ideal levels: **Yellow** when speaking, green when quiet
7.  **Create Desktop Shortcut:**
    *   Right-click OBS Studio in Start menu → **More** → **Pin to taskbar**

**Recording Path Important:** The Captures folder inside Videos will auto-sync to Google Drive, so your recordings are automatically backed up.

### 5. WhatsApp Desktop (Example)

**Note:** This is an example. Not all organizations use WhatsApp for business communication.

1.  **Open WhatsApp** from the Start menu
2.  **Setup Options:**
    *   **Option A (Phone Number):** Select **"Link with phone number"**
        * Enter your work phone number
        * Enter the code sent to your phone
    *   **Option B (QR Code):** Scan the QR code with your phone
        * Open WhatsApp on your phone → **Settings** → **Linked Devices** → **Link a Device**
3.  **Test Camera Access:**
    *   Make a test video call to ensure camera/microphone permissions are enabled
    *   **Laptop Camera Shutter:** Some laptops have a physical camera shutter - slide it open to use the camera
4.  **Enable Auto-Start:**
    *   In WhatsApp, click the gear icon (⚙️) → **Settings**
    *   Enable **"Launch WhatsApp at login"**

### 6. Zoom (Example)

**Note:** Configuration guidance for Zoom as a common video conferencing tool.

1.  **Launch Zoom** from the Start menu
2.  **Sign In:**
    *   Click **"Sign In"**
    *   Select **"Sign in with Google"**
    *   Choose your Google Workspace account (`@your-domain.com`)
3.  **Test Audio/Video:**
    *   Click your profile icon → **Settings**
    *   Go to **Audio** → **Test Speaker** and **Test Microphone**
    *   Go to **Video** → **Test Video**
4.  **Recommended Settings:**
    *   Enable **"HD video"** (if your internet connection is fast)
    *   Enable **"Join audio by computer when joining a meeting"**

### 7. Other Applications

**For additional applications in your Stage 2 script:**

- Provide sign-in instructions (with Google SSO where available)
- Note any custom server configurations needed
- List essential settings to verify
- Include testing steps

---

## Creating Desktop Shortcuts

For quick access, create desktop shortcuts for frequently used apps:

1.  Open **Start Menu**
2.  Find the app (e.g., RustDesk, OBS Studio)
3.  **Right-click** the app → **More** → **Open file location**
4.  Right-click the shortcut → **Send to** → **Desktop (create shortcut)**

**Recommended shortcuts:** RustDesk, OBS Studio, Google Drive

---

## Pinning Apps to Taskbar

For quick access, pin frequently-used apps to your taskbar:

1.  Open **Start Menu**
2.  Find the app
3.  **Right-click** → **Pin to taskbar**

**Commonly pinned apps:** Chrome, Google Drive, video conferencing tools, communication apps

---

## Recording Device Information for IT Support

IT may ask users to provide device information for tracking and support:

1.  **Windows Device Name:**
    *   Press **Windows key**
    *   Type **"About"**
    *   Click **"About your PC"**
    *   Note your **Device Name** (e.g., "DESKTOP-ABC1234")
2.  **Remote Support ID:**
    *   If using RustDesk, note your RustDesk ID (visible in the app)
    *   If using TeamViewer, note your TeamViewer ID
3.  **Share via your organization's preferred method** (email, messaging app, etc.)

---

## Troubleshooting (Common Issues)

### Chrome won't sign in
- Check your internet connection
- Try opening an incognito window: `Ctrl + Shift + N`
- Clear browser cache: **Settings** → **Privacy and security** → **Clear browsing data**

### Google Drive not syncing
- Check the Google Drive system tray icon for errors
- Right-click the icon → **Settings** → **Preferences** → **Restart Google Drive**
- Ensure you have sufficient storage space in your Google Workspace account

### Remote support tool can't connect
- Verify your internet connection
- Ensure IT has your correct ID number
- Try restarting the application
- Check firewall settings (IT may need to whitelist the application)

### Application won't launch or crashes
- Try restarting your computer
- Check for Windows updates: **Settings** → **Windows Update**
- Reinstall the application using Winget (contact IT for command)

### Camera/microphone not working
- Check camera/microphone permissions: **Settings** → **Privacy & security** → **Camera** / **Microphone**
- Some laptops have a physical camera shutter - slide it open
- Ensure no other application is using the camera/microphone

---

## Customization Notes for Organizations

When creating your own version of this guide:

1.  **Add your domain name** (`@your-domain.com`) where applicable
2.  **Include custom server addresses** for RustDesk, VPNs, or other tools
3.  **List organization-specific applications** from your Stage 2 script
4.  **Provide IT contact information** (email, messaging app, phone)
5.  **Include links to internal resources** (wikis, help desks, shared drives)
6.  **Remove sections** for applications you don't use
7.  **Add sections** for applications unique to your organization

**Example structure for your `domains/[your-domain]/IT/` folder:**
```
domains/your-domain.com/IT/
  ├── rustdesk-config.ps1 (if using custom server)
  ├── stage2-install-apps.ps1 (your org's app list)
  └── app-setup-guide-[your-domain].md (customized version of this)
```

---

## Summary

This template provides a starting point for application configuration guidance. Customize it to match your organization's specific applications, servers, and support processes. Users should follow this guide after completing Windows setup and running both installation scripts.

