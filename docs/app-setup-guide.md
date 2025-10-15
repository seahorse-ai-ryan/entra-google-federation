# Application Installation & Configuration Guide

This guide details the installation and essential configuration for work applications after completing Windows setup with your Google Workspace account.

**Prerequisites:** You must have completed the [Windows Setup Guide](windows-setup-guide.md) first, including setting up your Windows Hello PIN.

---

## Automated Installation (Recommended)

### Quick Install Command

1.  **Right-click the Start button** (Windows icon in the bottom-left corner)
2.  **Select "Terminal (Admin)"** from the menu
    *   If you see a security prompt, click **Yes** to allow
    *   The window title will say **"Administrator: Windows PowerShell"**
3.  **Copy and paste this command:**
    ```powershell
    irm https://raw.githubusercontent.com/seahorse-ai-ryan/entra-google-federation/main/scripts/deploy-apps.ps1 | iex
    ```
4.  **Press Enter** and wait (10-15 minutes)

### What Gets Installed Automatically

✅ **Google Chrome** - Web browser  
✅ **Google Drive** - File sync  
✅ **RustDesk** - Remote support  
✅ **OBS Studio** - Screen recording  
✅ **WhatsApp Desktop** - Messaging  
✅ **Zoom** - Video calls  
✅ **TeamViewer QuickSupport** - Backup remote support  

---

## Post-Installation Configuration

After the automated installation completes, follow these steps to configure each application.

### 1. Google Chrome Setup

1.  **Launch Chrome** from the Start menu or desktop
2.  **Sign in** with your Google Workspace account
3.  **Sync settings** will automatically enable bookmarks and extensions
4.  **Show Bookmarks Bar:** Press `Ctrl + Shift + B` to toggle the bookmarks bar
5.  **Pin to Taskbar:** Right-click Chrome icon in taskbar → **Pin to taskbar**
6.  **Optional:** Unpin Microsoft Edge if you won't use it

### 2. Google Drive Setup

1.  **Launch Google Drive** (should auto-start after installation)
2.  **Sign in** with your Google Workspace account (Google Single Sign-On)
3.  **Folder Sync Configuration:**
    *   Click the Google Drive system tray icon (bottom-right corner)
    *   Click the gear icon → **Preferences**
    *   Under **"Google Drive"**, ensure your shared drives are visible
    *   Under **"My Computer"**, you can choose which folders to sync
4.  **Pin Shared Drive to Quick Access:**
    *   Open File Explorer
    *   Navigate to your shared drive (e.g., "Medical Assistant Shared Drive")
    *   Right-click the folder → **Pin to Quick Access**

**Chrome Extension Note:** If Chrome shows an error about an extension, enable the **"Application Launcher for Drive (by Google)"** extension.

### 3. RustDesk (Remote Support)

**Automatic Configuration (if IT has set this up):**

If your organization has a custom RustDesk server, the deployment script will automatically configure it if you've signed into Google Drive first. The config file lives in your shared drive.

1.  **Open RustDesk** from the Start menu
2.  **Verify server connection:**
    *   Check that the ID Server shows your team's server (e.g., not empty or "hbbs.rustdesk.com")
    *   If it shows your team's server, you're all set!
3.  **Note your ID number** - this is what support will use to connect to your device

**If RustDesk is NOT configured:**

The deployment script will show a warning that says "RustDesk config not loaded." This means:

1.  **Option A (Automatic):** The config file might not be in your Google Drive yet. Contact IT.
2.  **Option B (Manual):**
    *   Click the **three dots** next to your ID → **Settings** → **Network**
    *   Click **"Unlock network settings"**
    *   Enter your team's server details (get from IT)
    *   Click **"Apply"** and verify it says "Success"

**For Standard Setup (No Custom Server):**

If your organization doesn't use a custom RustDesk server:

1.  **Open RustDesk** from the Start menu
2.  **Note your ID number** - this is what support will use to connect to your device
3.  **Test connection:** Have IT support test remote access using your ID

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

### 5. WhatsApp Desktop

1.  **Open WhatsApp** from the Start menu
2.  **Setup Options:**
    *   **Option A (Phone Number):** Select **"Link with phone number"**
        * Enter your work phone number
        * Enter the code sent to your phone
    *   **Option B (QR Code):** Scan the QR code with your phone
        * Open WhatsApp on your phone → **Settings** → **Linked Devices** → **Link a Device**
3.  **Test Camera Access:**
    *   Make a test video call to ensure camera/microphone permissions are enabled
    *   **Dell Laptop Note:** Dell laptops have a physical camera shutter - slide it open to use the camera
4.  **Enable Auto-Start:**
    *   In WhatsApp, click the gear icon (⚙️) → **Settings**
    *   Enable **"Launch WhatsApp at login"**

### 6. Zoom

1.  **Launch Zoom** from the Start menu
2.  **Sign In:**
    *   Click **"Sign In"**
    *   Select **"Sign in with Google"**
    *   Choose your Google Workspace account
3.  **Test Audio/Video:**
    *   Click your profile icon → **Settings**
    *   Go to **Audio** → **Test Speaker** and **Test Microphone**
    *   Go to **Video** → **Test Video**
4.  **Recommended Settings:**
    *   Enable **"HD video"** (if your internet connection is fast)
    *   Enable **"Join audio by computer when joining a meeting"**

### 7. TeamViewer QuickSupport

**No configuration needed.** This is a backup remote support tool. Just launch it when IT support requests it, and provide the ID number shown.

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

For even quicker access:

1.  Open **Start Menu**
2.  Find the app
3.  **Right-click** → **Pin to taskbar**

**Recommended taskbar pins:** Chrome, WhatsApp, Zoom, OBS Studio, Google Drive

---

## Recording Device Information

Your administrator may ask you to record your device information:

1.  Press **Windows key**
2.  Type **"About"**
3.  Click **"About your PC"**
4.  Note your **Device Name** (e.g., "DESKTOP-ABC1234")

**For RustDesk:** Also note your RustDesk ID (visible in the RustDesk app).

---

## Troubleshooting

### Chrome won't sign in
- Check your internet connection
- Try opening an incognito window: `Ctrl + Shift + N`
- Clear browser cache: **Settings** → **Privacy and security** → **Clear browsing data**

### Google Drive not syncing
- Check the Google Drive system tray icon for errors
- Right-click the icon → **Settings** → **Preferences** → **Restart Google Drive**

### RustDesk can't connect
- Verify your internet connection
- Check that IT has your correct RustDesk ID
- Try restarting RustDesk

### OBS recordings not saving to Google Drive
- Verify the recording path in **Settings** → **Output**
- Make sure Google Drive is running and syncing
- Check that the Captures folder exists: `C:\Users\[YourUsername]\Videos\Captures`

### WhatsApp Desktop not loading
- If installed from Microsoft Store, try uninstalling and reinstalling
- Check camera/microphone permissions: **Settings** → **Privacy & security** → **Camera** / **Microphone**

### Dell camera shutter closed
- Dell laptops have a physical privacy shutter next to the camera
- Slide it to the right to open the camera

---

## Summary: Your Setup is Complete!

✅ Windows signed in with Google Workspace  
✅ Windows Hello PIN configured  
✅ All work applications installed  
✅ Google Drive syncing  
✅ Remote support tools ready  
✅ Recording software configured  

**You're ready to start working!** If you encounter any issues, reach out to IT support via RustDesk or TeamViewer.

