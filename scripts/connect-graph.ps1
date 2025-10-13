param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [switch]$BrowserAuth,
    [switch]$SaveContext
)

Write-Host "Checking for Microsoft.Graph modules..."
Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Identity.SignIns)) {
    Install-Module Microsoft.Graph.Identity.SignIns -Scope CurrentUser -Force
}
Import-Module Microsoft.Graph.Authentication -Force
Write-Host "Required modules are installed." -ForegroundColor Green

try { Disconnect-MgGraph -ErrorAction SilentlyContinue } catch {}

$requiredScopes = @(
    "Domain.ReadWrite.All",
    "Directory.AccessAsUser.All",
    "Policy.Read.All",
    "Policy.ReadWrite.ConditionalAccess",
    "Policy.ReadWrite.SecurityDefaults",
    "User.Read.All"
)

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
if ($BrowserAuth) {
    Connect-MgGraph -TenantId $TenantId -Scopes $requiredScopes
} else {
    Connect-MgGraph -TenantId $TenantId -Scopes $requiredScopes -UseDeviceCode
}
Write-Host "Authentication successful." -ForegroundColor Green

if ($SaveContext) {
    $contextPath = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "graph_context.clixml"
    Write-Host "Saving authentication context to $contextPath..." -ForegroundColor Yellow
    $context = Get-MgContext
    if (-not $context) {
        Write-Host "Unable to retrieve Microsoft Graph context." -ForegroundColor Red
        exit 1
    }
    $context | Export-Clixml -Path $contextPath -Force
    Write-Host "Context saved." -ForegroundColor Green
}
