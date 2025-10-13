# Step 1: Import the saved authentication context.
# First, ensure the necessary module is up-to-date.
Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force
Import-Module Microsoft.Graph.Authentication -Force

$contextPath = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "graph_context.clixml"
Write-Host "Importing authentication context from $contextPath..." -ForegroundColor Yellow
if (-not (Test-Path -Path $contextPath)) {
    Write-Host "Authentication context file not found. Please run 'step1_authenticate_and_save.ps1' first." -ForegroundColor Red
    exit
}
$context = Import-Clixml -Path $contextPath
if (-not $context) {
    Write-Host "Stored Microsoft Graph context could not be loaded. Aborting." -ForegroundColor Red
    exit
}
Set-MgContext -Context $context

# Step 2: Temporarily Disable Security Defaults.
Write-Host "Disabling Security Defaults..." -ForegroundColor Yellow
try {
    Update-MgPolicyIdentitySecurityDefaultEnforcementPolicy -IsEnabled:$false -ErrorAction Stop
    Write-Host "Security Defaults disabled successfully." -ForegroundColor Green
} catch {
    Write-Host "Error disabling Security Defaults. Aborting." -ForegroundColor Red; Write-Host $_.Exception.Message -ForegroundColor Red; exit
}

# Step 3: Define and Apply the Google Workspace Federation Settings.
Write-Host "Applying domain federation settings..." -ForegroundColor Yellow
try {
    $domainName = "seahorsetwin.com"
    $federationSettings = @{
        ActiveSignInUri                 = "https://accounts.google.com/o/saml2/idp?idpid=C0332l2ng"
        DisplayName                     = "seahorsetwin.com"
        FederatedIdpMfaBehavior         = "enforceMfaByFederatedIdp"
        IsSignedAuthenticationRequestRequired = $false
        IssuerUri                       = "https://accounts.google.com/o/saml2?idpid=C0332l2ng"
        MetadataExchangeUri             = "https://accounts.google.com/o/saml2/idp?idpid=C0332l2ng"
        PassiveSignInUri                = "https://accounts.google.com/o/saml2/idp?idpid=C0332l2ng"
        SignOutUri                      = "https://accounts.google.com/logout"
        SigningCertificate              = "MIIDdDCCAlygAwIBAgIGAYo5e5yHMA0GCSqGSIb3DQEBCwUAMHsxFDASBgNVBAoTC0dvb2dsZSBJbmMuMRYwFAYDVQQHEw1Nb3VudGFpbiBWaWV3MQ8wDQYDVQQDEwZHb29nbGUxGDAWBgNVBAsTD0dvb2dsZSBGb3IgV29yazELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWEwHhcNMjMwODI4MDAxMTU2WhcNMjgwODI2MDAxMTU2WjB7MRQwEgYDVQQKEwtHb29nbGUgSW5jLjEWMBQGA1UEBxMNTW91bnRhaW4gVmlldzEPMA0GA1UEAxMGR29vZ2xlMRgwFgYDVQQLEw9Hb29nbGUgRm9yIFdvcmsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMIIBIjANBgkqhkiGw0BAQEFAAOCAQ8AMIIBCgKCAQEA5o61FaRZQ6ecaWceeemQFfHbdgj32tJKfRF0twUgzlM/x0ULhE0ZwNklHON7huUt4P7JZu8MaVcU8NGscC0OkuCXKhLnjJS6NXNzd6X695WpNNcfTeCBW5hJMyYe/d+eHIJhM8+Mu1Bb0X85QA2tY7gLBBlMErwPZmFSVL3mddLiE6b7DIbZIG5VWisw6eK+KVj1Ee+qBijorUHRj2EIxBX/7Ca1ksPDVNcVe03KbkVKO5T7tE5hWWKWrl4qLy+TkoEPikz/MkNVFw6zgLpMSI21tbUlRqjXQfg8InYJszO55d7xTzSh7tZGRioPdhxBK0ngb4Cr+UzFIT9yJmp+dwIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQBt8fz7fazQWoJfhHlmMgrJswQh3vbBOEoqHnRBKmQN0lG8QvUibq8sx3g+N3GHYvRBc/j5LeE5PJGYWTOplTorvnfqfxFpSKY2gJrqeeYOZsgc5IZybwzCy0+ugC1acAiWFRnev7Wrkk3jS8j7bYlRkeb9wBlg1jsN8526zVbNV+iYzCJvbJ6jf7LBPSXfgW7vHdOJgce6qU1/dt8NfrZvfkbr46sSBIoS5afCllE8bnCQ3X/XLYIIrHQ2nqZwlDsQAXlUqBj0dEKhChnyYqRMyjjG2AJs2lxC+feX8K0Kzyy3h0N8dnxnY9qM0FHRnW7Uyide9X+u76Qrc1BScOQth"
        PreferredAuthenticationProtocol = "saml"
    }
    New-MgDomainFederationConfiguration -DomainId $domainName -BodyParameter $federationSettings -ErrorAction Stop
    Write-Host "Domain federation settings applied successfully." -ForegroundColor Green
} catch {
    Write-Host "Error applying federation settings. Aborting." -ForegroundColor Red; Write-Host $_.Exception.Message -ForegroundColor Red; exit
}

# Step 4: Re-enable Security Defaults.
Write-Host "Re-enabling Security Defaults..." -ForegroundColor Yellow
try {
    Update-MgPolicyIdentitySecurityDefaultEnforcementPolicy -IsEnabled:$true -ErrorAction Stop
    Write-Host "Security Defaults re-enabled successfully." -ForegroundColor Green
} catch {
    Write-Host "Error re-enabling Security Defaults. Please do this manually." -ForegroundColor Red; Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "---" -ForegroundColor Cyan
Write-Host "Federation setup is complete. Please test the login flow now." -ForegroundColor Cyan
