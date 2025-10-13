param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string]$DomainId,

    [Parameter(Mandatory = $true)]
    [string]$MetadataPath,

    [string]$DisplayName,
    [string]$SignOutUri = "https://accounts.google.com/logout",
    [string]$FederatedIdpMfaBehavior = "enforceMfaByFederatedIdp",
    [switch]$BrowserAuth
)

Write-Host "Checking for Microsoft.Graph modules..."
Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Identity.SignIns)) {
    Install-Module Microsoft.Graph.Identity.SignIns -Scope CurrentUser -Force
}
Import-Module Microsoft.Graph.Authentication -Force
Write-Host "Required modules are installed." -ForegroundColor Green

Write-Host "Clearing cached Microsoft Graph sessions..." -ForegroundColor Yellow
try { Disconnect-MgGraph -ErrorAction SilentlyContinue } catch {}
try {
    Clear-MgContext -Scope CurrentUser -Force -ErrorAction Stop
    Write-Host "Cached context cleared." -ForegroundColor Green
} catch {
    Write-Host "No cached context to clear or failed to clear." -ForegroundColor Yellow
}

$scopes = @(
    "Domain.ReadWrite.All",
    "Directory.AccessAsUser.All",
    "Policy.Read.All",
    "Policy.ReadWrite.ConditionalAccess",
    "Policy.ReadWrite.SecurityDefaults",
    "User.Read.All"
)

Write-Host "Authenticating to Microsoft Graph..." -ForegroundColor Yellow
try {
    if ($BrowserAuth) {
        Connect-MgGraph -TenantId $TenantId -Scopes $scopes
    } else {
        Connect-MgGraph -TenantId $TenantId -Scopes $scopes -UseDeviceCode
    }
    Write-Host "Authentication successful." -ForegroundColor Green
} catch {
    Write-Host "Authentication failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Resolve metadata path
try {
    $metadataPathFull = (Resolve-Path -Path $MetadataPath -ErrorAction Stop).Path
} catch {
    Write-Host "Metadata file '$MetadataPath' not found." -ForegroundColor Red
    exit 1
}

[xml]$metadata = Get-Content -Path $metadataPathFull -Raw
$issuerUri = $metadata.EntityDescriptor.entityID
$signingCertRaw = ($metadata.EntityDescriptor.IDPSSODescriptor.KeyDescriptor | Where-Object { $_.use -eq 'signing' -or -not $_.use }) | Select-Object -First 1
if (-not $signingCertRaw) {
    Write-Host "No signing certificate found in metadata." -ForegroundColor Red
    exit 1
}
$signingCert = $signingCertRaw.KeyInfo.X509Data.X509Certificate -join ''
$signingCert = $signingCert -replace "\s", ""

$ssoServices = @($metadata.EntityDescriptor.IDPSSODescriptor.SingleSignOnService)
if (-not $ssoServices) {
    Write-Host "No SingleSignOnService entries found in metadata." -ForegroundColor Red
    exit 1
}
$primarySso = $ssoServices | Where-Object { $_.Binding -match 'Redirect' } | Select-Object -First 1
if (-not $primarySso) {
    $primarySso = $ssoServices | Select-Object -First 1
}
$ssoUri = $primarySso.Location
if (-not $ssoUri) {
    Write-Host "Unable to determine SSO endpoint from metadata." -ForegroundColor Red
    exit 1
}

if (-not $DisplayName) {
    $DisplayName = $DomainId
}

$federationBody = @{
    ActiveSignInUri                 = $ssoUri
    DisplayName                     = $DisplayName
    FederatedIdpMfaBehavior         = $FederatedIdpMfaBehavior
    IsSignedAuthenticationRequestRequired = $false
    IssuerUri                       = $issuerUri
    MetadataExchangeUri             = $ssoUri
    PassiveSignInUri                = $ssoUri
    SignOutUri                      = $SignOutUri
    SigningCertificate              = $signingCert
    PreferredAuthenticationProtocol = "saml"
}

Write-Host "Disabling Security Defaults..." -ForegroundColor Yellow
try {
    Update-MgPolicyIdentitySecurityDefaultEnforcementPolicy -IsEnabled:$false -ErrorAction Stop
    Write-Host "Security Defaults disabled successfully." -ForegroundColor Green
} catch {
    Write-Host "Error disabling Security Defaults. Aborting." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "Applying federation settings for domain $DomainId..." -ForegroundColor Yellow
try {
    $existingConfig = Get-MgDomainFederationConfiguration -DomainId $DomainId -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($existingConfig) {
        Write-Host "Existing federation configuration detected. Updating..." -ForegroundColor Yellow
        Update-MgDomainFederationConfiguration -DomainId $DomainId -InternalDomainFederationId $existingConfig.Id -BodyParameter $federationBody -ErrorAction Stop
    } else {
        New-MgDomainFederationConfiguration -DomainId $DomainId -BodyParameter $federationBody -ErrorAction Stop
    }
    Write-Host "Federation settings applied successfully." -ForegroundColor Green
} catch {
    Write-Host "Error applying federation settings." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "Attempting to re-enable Security Defaults before exit..." -ForegroundColor Yellow
    try {
        Update-MgPolicyIdentitySecurityDefaultEnforcementPolicy -IsEnabled:$true -ErrorAction Stop
        Write-Host "Security Defaults re-enabled." -ForegroundColor Green
    } catch {
        Write-Host "Failed to re-enable Security Defaults." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    exit 1
}

Write-Host "Re-enabling Security Defaults..." -ForegroundColor Yellow
try {
    Update-MgPolicyIdentitySecurityDefaultEnforcementPolicy -IsEnabled:$true -ErrorAction Stop
    Write-Host "Security Defaults re-enabled successfully." -ForegroundColor Green
} catch {
    Write-Host "Error re-enabling Security Defaults. Please do this manually." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "Federation setup complete. Test the login flow." -ForegroundColor Cyan
