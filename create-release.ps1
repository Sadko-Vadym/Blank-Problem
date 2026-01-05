# GitHub Release Creation Script
# Usage: .\create-release.ps1 -Token "your_github_token"

param(
    [Parameter(Mandatory=$true)]
    [string]$Token
)

$owner = "Sadko-Vadym"
$repo = "Blank-Problem"
$tag = "v1.0.0"
$releaseName = "bot-project v1.0.0"
$releaseBody = @"
## First Release of bot-project

This release includes the Helm chart for deploying bot-project on Kubernetes.

### Features:
- Multi-arch builds support (amd64 by default)
- Kubernetes secret for TELE_TOKEN
- Configurable image repository and tag

### Installation:
\`\`\`bash
helm install bot https://github.com/Sadko-Vadym/Blank-Problem/releases/download/v1.0.0/bot-1.0.0.tgz --set secret.teleToken=YOUR_TELEGRAM_TOKEN
\`\`\`
"@

$headers = @{
    "Authorization" = "Bearer $Token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

# Step 1: Create the release
Write-Host "Creating release $tag..." -ForegroundColor Cyan

$releaseData = @{
    tag_name = $tag
    name = $releaseName
    body = $releaseBody
    draft = $false
    prerelease = $false
} | ConvertTo-Json

try {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/releases" -Method Post -Headers $headers -Body $releaseData -ContentType "application/json"
    Write-Host "Release created successfully!" -ForegroundColor Green
    Write-Host "Release ID: $($release.id)"
    Write-Host "Release URL: $($release.html_url)"
} catch {
    if ($_.Exception.Response.StatusCode -eq 422) {
        Write-Host "Release already exists, fetching existing release..." -ForegroundColor Yellow
        $releases = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/releases/tags/$tag" -Method Get -Headers $headers
        $release = $releases
    } else {
        Write-Host "Error creating release: $_" -ForegroundColor Red
        exit 1
    }
}

# Step 2: Upload the asset
$assetPath = "bot-1.0.0.tgz"
$assetName = "bot-1.0.0.tgz"

if (Test-Path $assetPath) {
    Write-Host "Uploading $assetName to release..." -ForegroundColor Cyan
    
    $uploadUrl = $release.upload_url -replace '\{.*\}', ''
    $uploadUrl = "$uploadUrl`?name=$assetName"
    
    $fileBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $assetPath))
    
    $uploadHeaders = @{
        "Authorization" = "Bearer $Token"
        "Accept" = "application/vnd.github+json"
        "Content-Type" = "application/gzip"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    try {
        $asset = Invoke-RestMethod -Uri $uploadUrl -Method Post -Headers $uploadHeaders -Body $fileBytes
        Write-Host "Asset uploaded successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "HELM CHART URL:" -ForegroundColor Green
        Write-Host $asset.browser_download_url -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Green
    } catch {
        Write-Host "Error uploading asset: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Asset file not found: $assetPath" -ForegroundColor Red
    exit 1
}

