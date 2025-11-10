#Requires -RunAsAdministrator

<#$
.SYNOPSIS
    Single-stage installation script for LGITech.net – installs all required applications in one run.

.DESCRIPTION
    This script is intended to be run via:

        irm https://raw.githubusercontent.com/seahorse-ai-ryan/entra-google-federation/main/scripts/stage1-install-essentials.ps1 | iex

    It will install the following applications using winget:
      - Google Chrome (and set it as the default browser)
      - Google Drive
      - WhatsApp Desktop
      - RustDesk
      - OBS Studio
      - Zoom
      - TeamViewer QuickSupport

    No private configuration is embedded. RustDesk credentials should be provided to the user separately.
#>

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  LGITech Application Installation" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script installs everything you need in one pass:" -ForegroundColor Yellow
Write-Host "  - Google Chrome (web browser)" -ForegroundColor White
Write-Host "  - Google Drive (file sync)" -ForegroundColor White
Write-Host "  - WhatsApp Desktop" -ForegroundColor White
Write-Host "  - RustDesk (remote support)" -ForegroundColor White
Write-Host "  - OBS Studio (screen recording)" -ForegroundColor White
Write-Host "  - Zoom (video calls)" -ForegroundColor White
Write-Host "  - TeamViewer QuickSupport" -ForegroundColor White
Write-Host ""
Write-Host "Estimated time: 15-20 minutes" -ForegroundColor Yellow
Write-Host "You can minimize this window while installs run." -ForegroundColor Green
Write-Host ""

function Ensure-WingetReady {
    param(
        [int]$MaxAttempts = 5,
        [int]$DelaySeconds = 5
    )

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        try {
            winget --info > $null 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[Winget] Ready (attempt $attempt)." -ForegroundColor Green
                try {
                    winget source update > $null 2>&1
                } catch {
                    Write-Host "[Winget] Source update skipped: $_" -ForegroundColor Yellow
                }
                return
            }
        } catch {
            # ignore and retry
        }

        if ($attempt -lt $MaxAttempts) {
            Write-Host "[Winget] Preparing installer (attempt $attempt/$MaxAttempts) ..." -ForegroundColor Yellow
            Start-Sleep -Seconds $DelaySeconds
        }
    }

    Write-Host "[Winget] Continuing even though initialization may be incomplete." -ForegroundColor Yellow
}

function Install-WingetApp {
    param(
        [string]$AppName,
        [string]$WingetId,
        [int]$MaxRetries = 2,
        [int]$RetryDelaySeconds = 6
    )

    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Installing $AppName... (attempt $attempt/$MaxRetries)" -ForegroundColor Cyan
        try {
            $result = winget install --id $WingetId --silent --accept-source-agreements --accept-package-agreements 2>&1
            $exitCode = $LASTEXITCODE
        } catch {
            $result = $_.Exception.Message
            $exitCode = 1
        }

        if ($exitCode -eq 0) {
            Write-Host "  ✓ $AppName installed" -ForegroundColor Green
            return $true
        }

        $resultText = $result -join "\n"
        $needsRetry = ($attempt -lt $MaxRetries) -and ($resultText -match "cannot be started" -or $resultText -match "failed to run" -or $exitCode -eq 3221225781)

        if ($needsRetry) {
            Write-Host "  ⚠ $AppName install failed due to winget startup. Retrying after $RetryDelaySeconds seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds $RetryDelaySeconds
            continue
        }

        Write-Host "  ✗ $AppName installation failed (exit code $exitCode)." -ForegroundColor Red
        if ($resultText) {
            Write-Host "    Details: $resultText" -ForegroundColor Gray
        }
        return $false
    }

    return $false
}

Ensure-WingetReady

$appResults = @{}

$appResults['Chrome']     = Install-WingetApp -AppName "Google Chrome" -WingetId "Google.Chrome"
Start-Sleep -Seconds 2
$appResults['Drive']      = Install-WingetApp -AppName "Google Drive" -WingetId "Google.GoogleDrive"
Start-Sleep -Seconds 2
$appResults['WhatsApp']   = Install-WingetApp -AppName "WhatsApp Desktop" -WingetId "9NKSQGP7F2NH"
Start-Sleep -Seconds 2
$appResults['RustDesk']   = Install-WingetApp -AppName "RustDesk" -WingetId "RustDesk.RustDesk"
Start-Sleep -Seconds 2
$appResults['OBS']        = Install-WingetApp -AppName "OBS Studio" -WingetId "OBSProject.OBSStudio"
Start-Sleep -Seconds 2
$appResults['Zoom']       = Install-WingetApp -AppName "Zoom" -WingetId "Zoom.Zoom"
Start-Sleep -Seconds 2
$appResults['TeamViewer'] = Install-WingetApp -AppName "TeamViewer QuickSupport" -WingetId "TeamViewer.TeamViewer.Host"
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Post-Installation Tasks" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

if ($appResults['Chrome']) {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Setting Google Chrome as default browser..." -ForegroundColor Cyan
    try {
        Start-Process -FilePath "powershell.exe" -ArgumentList "-Command `"Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice' -Name 'Progid' -Value 'ChromeHTML' -Force`"" -Verb RunAs -WindowStyle Hidden -ErrorAction Stop
        Start-Process -FilePath "powershell.exe" -ArgumentList "-Command `"Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice' -Name 'Progid' -Value 'ChromeHTML' -Force`"" -Verb RunAs -WindowStyle Hidden -ErrorAction Stop
        Write-Host "  ✓ Chrome set as default browser (best effort)" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Could not set Chrome as default automatically: $_" -ForegroundColor Yellow
        Write-Host "    You can set it manually under Settings > Apps > Default apps." -ForegroundColor Gray
    }
}

if ($appResults['OBS']) {
    try {
        $capturesPath = "$env:USERPROFILE\Videos\Captures"
        if (-not (Test-Path $capturesPath)) {
            New-Item -ItemType Directory -Path $capturesPath -Force | Out-Null
            Write-Host "  ✓ Created Captures folder at $capturesPath" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ⚠ Could not create Captures folder: $_" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Installation Summary" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

foreach ($key in $appResults.Keys | Sort-Object) {
    if ($appResults[$key]) {
        Write-Host "✓ $key" -ForegroundColor Green
    } else {
        Write-Host "✗ $key" -ForegroundColor Red
    }
}

$successCount = ($appResults.Values | Where-Object { $_ }).Count
Write-Host ""
Write-Host "Installed: $successCount/$($appResults.Count) applications" -ForegroundColor $(if ($successCount -eq $appResults.Count) { "Green" } else { "Yellow" })

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Next Steps for the User" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Launch Chrome from the Start menu and sign in with your LGITech account." -ForegroundColor Yellow
Write-Host "2. Launch Google Drive (should auto-start) and sign in to begin syncing." -ForegroundColor Yellow
Write-Host "3. Open WhatsApp Desktop and link it with your phone (Settings -> Linked Devices)." -ForegroundColor Yellow
Write-Host "4. Sign into Zoom with 'Sign in with Google'." -ForegroundColor Yellow
Write-Host "5. Launch RustDesk and share your ID with IT for remote support." -ForegroundColor Yellow
Write-Host "6. OBS Studio and TeamViewer QuickSupport are ready if needed." -ForegroundColor Yellow
Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "Press any key to close this window..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

