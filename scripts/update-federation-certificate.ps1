param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string]$DomainId,

    [Parameter(Mandatory = $true)]
    [string]$MetadataPath,

    [switch]$BrowserAuth,
    [switch]$SkipConnect
)

$scopes = @(
    "Domain.ReadWrite.All",
    "Directory.AccessAsUser.All",
    "Policy.Read.All",
    "Policy.ReadWrite.ConditionalAccess",
    "Policy.ReadWrite.SecurityDefaults",
    "User.Read.All"
)

if (-not $SkipConnect) {
    try {
        Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
        if ($BrowserAuth) {
            Connect-MgGraph -Scopes $scopes -TenantId $TenantId -ErrorAction Stop
        } else {
            Connect-MgGraph -Scopes $scopes -TenantId $TenantId -UseDeviceCode -ErrorAction Stop
        }
        Write-Host "Connected." -ForegroundColor Green
    } catch {
        Write-Host "Failed to connect to Microsoft Graph." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}

Write-Host "Loading new signing certificate from '$MetadataPath'..." -ForegroundColor Yellow
try {
    $metadataContent = Get-Content -Path $MetadataPath -Raw -ErrorAction Stop
    [xml]$metadata = $metadataContent
} catch {
    Write-Host "Metadata file not found or could not be read." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

$signingCert = ($metadata.EntityDescriptor.IDPSSODescriptor.KeyDescriptor | Where-Object { $_.use -eq 'signing' -or -not $_.use }) | Select-Object -First 1
if (-not $signingCert) {
    Write-Host "No signing certificate found in metadata." -ForegroundColor Red
    exit 1
}
$signingCert = $signingCert.KeyInfo.X509Data.X509Certificate -join ''
$signingCert = $signingCert -replace '\s',''

Write-Host "Retrieving current federation configuration for $DomainId..." -ForegroundColor Yellow
$federations = Get-MgDomainFederationConfiguration -DomainId $DomainId
if (-not $federations) {
    Write-Host "Federation configuration not found." -ForegroundColor Red
    exit 1
}
$federation = $federations | Select-Object -First 1

Write-Host "Disabling Security Defaults..." -ForegroundColor Yellow
Update-MgPolicyIdentitySecurityDefaultEnforcementPolicy -IsEnabled:$false

try {
    Write-Host "Updating federation configuration with new certificate..." -ForegroundColor Yellow
    Update-MgDomainFederationConfiguration -DomainId $DomainId -InternalDomainFederationId $federation.Id -ActiveSignInUri $federation.ActiveSignInUri -DisplayName $federation.DisplayName -FederatedIdpMfaBehavior $federation.FederatedIdpMfaBehavior -IssuerUri $federation.IssuerUri -MetadataExchangeUri $federation.MetadataExchangeUri -PassiveSignInUri $federation.PassiveSignInUri -SignOutUri $federation.SignOutUri -SigningCertificate $signingCert -PreferredAuthenticationProtocol $federation.PreferredAuthenticationProtocol
    Write-Host "Federation configuration updated." -ForegroundColor Green
} finally {
    Write-Host "Re-enabling Security Defaults..." -ForegroundColor Yellow
    Update-MgPolicyIdentitySecurityDefaultEnforcementPolicy -IsEnabled:$true
}

$currentCert = (Get-MgDomainFederationConfiguration -DomainId $DomainId | Select-Object -First 1).SigningCertificate
Write-Host "Current Signing Certificate (truncated):" -ForegroundColor Cyan
Write-Host ($currentCert.Substring(0,[Math]::Min(80,$currentCert.Length)) + '...')
