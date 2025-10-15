#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Stage 1: Installs Chrome and Google Drive to enable access to secure resources.

.DESCRIPTION
    This is the first stage of the deployment process. It installs only Chrome and Google Drive,
    which allows users to sign in and access the second stage script from Google Drive.
    
    Users can run this script directly from the OOBE terminal using Edge (which is pre-installed).
#>

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Stage 1: Essential Applications" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will install:" -ForegroundColor Yellow
Write-Host "  - Google Chrome (web browser)" -ForegroundColor White
Write-Host "  - Google Drive (file sync)" -ForegroundColor White
Write-Host ""
Write-Host "After these install, you'll:" -ForegroundColor Yellow
Write-Host "  1. Sign into Chrome with your work account" -ForegroundColor White
Write-Host "  2. Sign into Google Drive with your work account" -ForegroundColor White
Write-Host "  3. Wait for Drive to sync" -ForegroundColor White
Write-Host "  4. Run Stage 2 script from your Google Drive" -ForegroundColor White
Write-Host ""
Write-Host "Estimated time: 5 minutes" -ForegroundColor Yellow
Write-Host ""

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
            return $false
        }
    } catch {
        Write-Host "  ✗ $AppName installation failed: $_" -ForegroundColor Red
        return $false
    }
}

# Track results
$results = @{}

# Install Chrome
$results['Chrome'] = Install-WingetApp -AppName "Google Chrome" -WingetId "Google.Chrome"
Start-Sleep -Seconds 3

# Install Google Drive
$results['Drive'] = Install-WingetApp -AppName "Google Drive" -WingetId "Google.GoogleDrive"
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Installation Complete!" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

if ($results['Chrome']) {
    Write-Host "✓ Chrome installed" -ForegroundColor Green
} else {
    Write-Host "✗ Chrome failed" -ForegroundColor Red
}

if ($results['Drive']) {
    Write-Host "✓ Google Drive installed" -ForegroundColor Green
} else {
    Write-Host "✗ Google Drive failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  NEXT STEPS - IMPORTANT!" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Launch Chrome from the Start menu" -ForegroundColor Yellow
Write-Host "2. Sign in with your work Google account" -ForegroundColor Yellow
Write-Host "3. Google Drive should auto-launch - sign in there too" -ForegroundColor Yellow
Write-Host "   (If it doesn't auto-launch, open it from Start menu)" -ForegroundColor Gray
Write-Host "4. Wait 2-3 minutes for Google Drive to sync" -ForegroundColor Yellow
Write-Host "5. Open File Explorer and navigate to:" -ForegroundColor Yellow
Write-Host "   'Google Drive > My Drive' or 'Google Drive > Shared drives'" -ForegroundColor White
Write-Host "6. Find the Stage 2 script and run it" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to close this window..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

