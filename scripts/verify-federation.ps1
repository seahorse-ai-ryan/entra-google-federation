# Quick script to verify federation configuration exists
param(
    [Parameter(Mandatory = $true)]
    [string]$DomainId,
    
    [Parameter(Mandatory = $true)]
    [string]$TenantId
)

Write-Host "Checking federation configuration for $DomainId..." -ForegroundColor Yellow

# Install if needed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
    Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force
}
Import-Module Microsoft.Graph.Authentication -Force

# Connect
try { Disconnect-MgGraph -ErrorAction SilentlyContinue } catch {}
Connect-MgGraph -TenantId $TenantId -Scopes "Domain.Read.All" -UseDeviceCode

# Check federation
try {
    $uri = "https://graph.microsoft.com/v1.0/domains/$DomainId/federationConfiguration"
    $config = Invoke-MgGraphRequest -Method GET -Uri $uri
    
    if ($config.value -and $config.value.Count -gt 0) {
        Write-Host "`n✓ Federation configuration EXISTS" -ForegroundColor Green
        Write-Host "`nDetails:" -ForegroundColor Cyan
        $fed = $config.value[0]
        Write-Host "  Display Name: $($fed.displayName)"
        Write-Host "  Issuer URI: $($fed.issuerUri)"
        Write-Host "  Passive Sign In URI: $($fed.passiveSignInUri)"
        Write-Host "  Active Sign In URI: $($fed.activeSignInUri)"
        Write-Host "  Certificate (first 50 chars): $($fed.signingCertificate.Substring(0, 50))..."
        Write-Host "`nFederation is configured correctly!" -ForegroundColor Green
    } else {
        Write-Host "`n✗ NO federation configuration found!" -ForegroundColor Red
        Write-Host "The domain shows as 'Federated' but has no federation config." -ForegroundColor Yellow
        Write-Host "This explains why PIN setup fails - there's no IdP to validate against." -ForegroundColor Yellow
    }
} catch {
    Write-Host "`n✗ Error checking federation: $_" -ForegroundColor Red
}

Disconnect-MgGraph


