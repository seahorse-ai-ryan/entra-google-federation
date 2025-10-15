#Requires -Version 7.0

<#
.SYNOPSIS
    Applies federation configuration using the New-MgDomainFederationConfiguration cmdlet.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,
    
    [Parameter(Mandatory = $true)]
    [string]$DomainId,
    
    [Parameter(Mandatory = $true)]
    [string]$MetadataPath
)

# Import modules
Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
Import-Module Microsoft.Graph.Identity.DirectoryManagement -ErrorAction Stop

# Connect
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
Connect-MgGraph -TenantId $TenantId -Scopes "Domain.ReadWrite.All","Directory.AccessAsUser.All" -NoWelcome
Write-Host "Connected as: $((Get-MgContext).Account)`n" -ForegroundColor Green

# Parse metadata
$resolvedPath = Resolve-Path $MetadataPath
[xml]$metadata = Get-Content -Path $resolvedPath -Raw

$issuerUri = $metadata.EntityDescriptor.entityID
$signonUrl = ($metadata.EntityDescriptor.IDPSSODescriptor.SingleSignOnService | 
    Where-Object { $_.Binding -eq "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" }).Location
$certificate = $metadata.EntityDescriptor.IDPSSODescriptor.KeyDescriptor.KeyInfo.X509Data.X509Certificate -replace '\s+', ''

Write-Host "=== CONFIGURATION ===" -ForegroundColor Cyan
Write-Host "Domain: $DomainId"
Write-Host "Issuer: $issuerUri"
Write-Host "SignOn: $signonUrl`n"

# Create federation using cmdlet
Write-Host "Applying federation configuration..." -ForegroundColor Yellow

$params = @{
    DisplayName = "Google Workspace"
    IssuerUri = $issuerUri
    PassiveSignInUri = $signonUrl
    SignOutUri = $signonUrl
    SigningCertificate = $certificate
    PreferredAuthenticationProtocol = "saml"
    FederatedIdpMfaBehavior = "acceptIfMfaDoneByFederatedIdp"
}

try {
    $result = New-MgDomainFederationConfiguration -DomainId $DomainId -BodyParameter $params
    Write-Host "✓ Federation applied successfully!" -ForegroundColor Green
    Write-Host "Federation ID: $($result.Id)" -ForegroundColor Gray
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Disconnect-MgGraph
    exit 1
}

# Verify
Write-Host "`n=== VERIFICATION ===" -ForegroundColor Cyan
$verify = Get-MgDomainFederationConfiguration -DomainId $DomainId
Write-Host "Issuer: $($verify.IssuerUri)"
Write-Host "SignOn: $($verify.PassiveSignInUri)"
Write-Host "Protocol: $($verify.PreferredAuthenticationProtocol)"

$domain = Get-MgDomain -DomainId $DomainId
Write-Host "Domain Auth Type: $($domain.AuthenticationType)"

Write-Host "`n✓ Complete! Test at: https://login.microsoftonline.com" -ForegroundColor Green

Disconnect-MgGraph

