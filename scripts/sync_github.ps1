param(
    [Parameter(Mandatory = $false, HelpMessage = "URL del repositorio GitHub para compilar el .ipa en GitHub Actions")]
    [string]$RepoUrl = "https://github.com/skrapy135/StreamIOS-cineverse.git",
    [switch]$ForcePush
)

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path -Parent $PSScriptRoot

Write-Host "=== Preparando Build de iOS (CineVerse_Flutter_iOS) para GitHub Actions ===" -ForegroundColor Red
Set-Location $ProjectDir

if (-not (Test-Path ".git")) {
    git init
}

git checkout -B main
git add -A
$status = git status --porcelain
if ($status) {
    git commit -m "feat(flutter-ios): complete CineVerse Xuper TV Flutter iOS app and automated .ipa build pipeline"
}

$existingRemote = git remote
if ($existingRemote -contains "origin") {
    git remote set-url origin $RepoUrl
}
else {
    git remote add origin $RepoUrl
}

if ($ForcePush) {
    git push -u origin main --force
}
else {
    git push -u origin main
}

Write-Host "`n¡Proyecto sincronizado exitosamente con $RepoUrl!" -ForegroundColor Green
Write-Host "GitHub Actions compilará automáticamente CineVerse_XuperTV_Flutter_iOS.ipa en la pestaña 'Actions'." -ForegroundColor Cyan

