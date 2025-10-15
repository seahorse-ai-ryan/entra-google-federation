# Windows Application Deployment Script
# Installs and configures standard applications using Winget
# Designed for Entra-joined devices after Google Workspace federation

#Requires -RunAsAdministrator

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Application Deployment Script" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will install the following applications:" -ForegroundColor Yellow
Write-Host "  - Google Chrome" -ForegroundColor White
Write-Host "  - Google Drive" -ForegroundColor White
Write-Host "  - RustDesk" -ForegroundColor White
Write-Host "  - OBS Studio" -ForegroundColor White
Write-Host "  - WhatsApp Desktop" -ForegroundColor White
Write-Host "  - Zoom" -ForegroundColor White
Write-Host "  - TeamViewer QuickSupport" -ForegroundColor White
Write-Host ""
Write-Host "Estimated time: 10-15 minutes" -ForegroundColor Yellow
Write-Host "You can continue working while apps install in the background." -ForegroundColor Green
Write-Host ""

# Configuration variables
# For RustDesk, these can be loaded from a separate config file (not in public repo)
$RustDeskServer = $null
$RustDeskKey = $null
$RustDeskPassword = $null

# Try to load RustDesk config from multiple possible locations
$configPaths = @(
    "$env:USERPROFILE\Downloads\rustdesk-config.ps1",                      # Manual download location
    "$env:USERPROFILE\Google Drive\My Drive\IT\rustdesk-config.ps1",      # Google Drive (My Drive)
    "$env:USERPROFILE\Google Drive\Shared drives\*\IT\rustdesk-config.ps1" # Google Drive (Shared drives)
)

foreach ($path in $configPaths) {
    # Handle wildcards for shared drives
    $resolvedPaths = Get-Item -Path $path -ErrorAction SilentlyContinue
    if ($resolvedPaths) {
        $configPath = $resolvedPaths[0].FullName
        Write-Host "Loading RustDesk configuration from: $configPath" -ForegroundColor Yellow
        . $configPath
        break
    }
}

# Function to install an app with error handling
function Install-WingetApp {
    param(
        [string]$AppName,
        [string]$WingetId
    )
    
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Installing $AppName..." -ForegroundColor Cyan
    
    try {
        $result = winget install --id $WingetId --silent --accept-source-agreements --accept-package-agreements 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ $AppName installed successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  ✗ $AppName installation failed (Exit code: $LASTEXITCODE)" -ForegroundColor Red
            Write-Host "  Error: $result" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "  ✗ $AppName installation failed: $_" -ForegroundColor Red
        return $false
    }
}

# Track installation results
$results = @{}

# Install applications
Write-Host "Starting installations..." -ForegroundColor Cyan
Write-Host ""

# 1. Google Chrome
$results['Chrome'] = Install-WingetApp -AppName "Google Chrome" -WingetId "Google.Chrome"
Start-Sleep -Seconds 2

# 2. Google Drive
$results['Drive'] = Install-WingetApp -AppName "Google Drive" -WingetId "Google.GoogleDrive"
Start-Sleep -Seconds 2

# 3. RustDesk
$results['RustDesk'] = Install-WingetApp -AppName "RustDesk" -WingetId "RustDesk.RustDesk"
Start-Sleep -Seconds 2

# 4. OBS Studio
$results['OBS'] = Install-WingetApp -AppName "OBS Studio" -WingetId "OBSProject.OBSStudio"
Start-Sleep -Seconds 2

# 5. WhatsApp Desktop
$results['WhatsApp'] = Install-WingetApp -AppName "WhatsApp Desktop" -WingetId "9NKSQGP7F2NH"
Start-Sleep -Seconds 2

# 6. Zoom
$results['Zoom'] = Install-WingetApp -AppName "Zoom" -WingetId "Zoom.Zoom"
Start-Sleep -Seconds 2

# 7. TeamViewer QuickSupport
$results['TeamViewer'] = Install-WingetApp -AppName "TeamViewer QuickSupport" -WingetId "TeamViewer.TeamViewer.Host"
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Post-Installation Configuration" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Configure RustDesk if it was successfully installed
if ($results['RustDesk']) {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Configuring RustDesk..." -ForegroundColor Cyan
    
    if ($RustDeskServer -and $RustDeskKey -and $RustDeskPassword) {
        $rustDeskConfigPath = "$env:ProgramFiles\RustDesk\RustDesk2.toml"
        
        if (Test-Path $rustDeskConfigPath) {
            try {
                $configContent = @"
[server]
host = '$RustDeskServer'
key = '$RustDeskKey'

[options]
permanent_password = '$RustDeskPassword'
"@
                $configContent | Set-Content -Path $rustDeskConfigPath -Encoding UTF8 -Force
                Write-Host "  ✓ RustDesk configured with server settings" -ForegroundColor Green
            } catch {
                Write-Host "  ✗ Failed to configure RustDesk: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "  ⚠ RustDesk config file not found. You may need to configure manually." -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ⚠ RustDesk config not loaded. Manual configuration required." -ForegroundColor Yellow
        Write-Host "    See docs for instructions on setting up server connection." -ForegroundColor Gray
    }
}

# Configure OBS Studio default recording path if it was successfully installed
if ($results['OBS']) {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Configuring OBS Studio..." -ForegroundColor Cyan
    
    $obsBasePath = "$env:APPDATA\obs-studio"
    $capturesPath = "$env:USERPROFILE\Videos\Captures"
    
    try {
        # Create Captures folder
        if (-not (Test-Path $capturesPath)) {
            New-Item -ItemType Directory -Path $capturesPath -Force | Out-Null
            Write-Host "  ✓ Created Captures folder at $capturesPath" -ForegroundColor Green
        }
        
        # Note: OBS creates its config on first launch, so we can't pre-configure here
        Write-Host "  ℹ OBS will create its config on first launch" -ForegroundColor Yellow
        Write-Host "    Recommended: Set recording path to $capturesPath" -ForegroundColor Yellow
    } catch {
        Write-Host "  ✗ Failed to configure OBS: $_" -ForegroundColor Red
    }
}

# Create desktop shortcuts for easy access
Write-Host ""
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Creating desktop shortcuts..." -ForegroundColor Cyan

$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcuts = @{
    "Google Drive" = "$env:ProgramFiles\Google\Drive File Stream\GoogleDriveFS.exe"
    "RustDesk" = "$env:ProgramFiles\RustDesk\rustdesk.exe"
    "OBS Studio" = "$env:ProgramFiles\obs-studio\bin\64bit\obs64.exe"
}

$shell = New-Object -ComObject WScript.Shell

foreach ($name in $shortcuts.Keys) {
    $targetPath = $shortcuts[$name]
    
    if (Test-Path $targetPath) {
        try {
            $shortcutPath = Join-Path $desktopPath "$name.lnk"
            $shortcut = $shell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath = $targetPath
            $shortcut.Save()
            Write-Host "  ✓ Created shortcut: $name" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Failed to create shortcut for $name" -ForegroundColor Yellow
        }
    }
}

# Summary Report
Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Installation Summary" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

$successCount = ($results.Values | Where-Object { $_ -eq $true }).Count
$totalCount = $results.Count

foreach ($app in $results.Keys) {
    if ($results[$app]) {
        Write-Host "  ✓ $app" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $app" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Installed: $successCount/$totalCount applications" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })
Write-Host ""

# Next steps
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Next Steps" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Launch Google Drive and sign in to enable file sync" -ForegroundColor White
Write-Host "2. Open WhatsApp and scan QR code to connect your phone" -ForegroundColor White
Write-Host "3. Launch Zoom and sign in with your Google account" -ForegroundColor White
Write-Host "4. Run RustDesk to get your device ID for remote support" -ForegroundColor White
Write-Host "5. Configure OBS Studio recording settings (File > Settings > Output)" -ForegroundColor White
Write-Host ""
Write-Host "Installation complete! You may need to restart some apps for full functionality." -ForegroundColor Green
Write-Host ""

# Pause to let user read the summary
Write-Host "Press any key to close this window..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

