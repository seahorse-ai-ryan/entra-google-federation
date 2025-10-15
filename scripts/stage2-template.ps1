#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Stage 2 Template: Install additional applications after Chrome and Google Drive.

.DESCRIPTION
    This is a TEMPLATE for Stage 2 installation. Copy this to your domain-specific folder
    (domains/<your-domain>/) and customize it for your organization's needs.
    
    This script should be placed in Google Drive (My Drive/IT/ or Shared drives/.../IT/)
    so users can run it after completing Stage 1 and signing into Google Drive.

.EXAMPLE
    Customize this template by:
    1. Copy to domains/<your-domain>/stage2-install-apps.ps1
    2. Add/remove apps in the $appsToInstall list
    3. Add any custom configuration sections
    4. Upload to your Google Drive IT folder
#>

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Stage 2: Additional Applications" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Customize this script by adding your organization's required applications." -ForegroundColor Yellow
Write-Host ""

# Configuration variables (customize as needed)
$RustDeskServer = $null
$RustDeskKey = $null
$RustDeskPassword = $null

# Try to load custom config from Google Drive
$configPaths = @(
    "$env:USERPROFILE\Google Drive\My Drive\IT\config.ps1",
    "$env:USERPROFILE\Google Drive\Shared drives\*\IT\config.ps1"
)

foreach ($path in $configPaths) {
    $resolvedPaths = Get-Item -Path $path -ErrorAction SilentlyContinue
    if ($resolvedPaths) {
        $configPath = $resolvedPaths[0].FullName
        Write-Host "Loading configuration from: $configPath" -ForegroundColor Yellow
        . $configPath
        break
    }
}

# Function to install an app
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
            return $false
        }
    } catch {
        Write-Host "  ✗ $AppName installation failed: $_" -ForegroundColor Red
        return $false
    }
}

# Define apps to install (CUSTOMIZE THIS LIST FOR YOUR ORGANIZATION)
$appsToInstall = @(
    @{ Name = "Example App 1"; WingetId = "Publisher.AppName" },
    @{ Name = "Example App 2"; WingetId = "Publisher.AppName2" }
    # Add more apps here...
    # To find Winget IDs: winget search "app name"
)

Write-Host "Apps to install:" -ForegroundColor Yellow
foreach ($app in $appsToInstall) {
    Write-Host "  - $($app.Name)" -ForegroundColor White
}
Write-Host ""

# Track results
$results = @{}

Write-Host "Starting installations..." -ForegroundColor Cyan
Write-Host ""

# Install apps
foreach ($app in $appsToInstall) {
    $results[$app.Name] = Install-WingetApp -AppName $app.Name -WingetId $app.WingetId
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Post-Installation Configuration" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Add custom configuration sections here
# Examples:
# - Configure application settings
# - Create desktop shortcuts
# - Set up default file associations
# - Configure environment variables

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Installation Summary" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

foreach ($app in $results.Keys | Sort-Object) {
    if ($results[$app]) {
        Write-Host "✓ $app" -ForegroundColor Green
    } else {
        Write-Host "✗ $app" -ForegroundColor Red
    }
}

$successCount = ($results.Values | Where-Object { $_ -eq $true }).Count
Write-Host ""
Write-Host "Installed: $successCount/$($results.Count) applications" -ForegroundColor $(if ($successCount -eq $results.Count) { "Green" } else { "Yellow" })

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to close this window..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

