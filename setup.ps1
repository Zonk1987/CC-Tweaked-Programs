# CC:Tweaked Programs — Developer Setup Script
# Run this ONCE after cloning the repository to configure:
#   1. CC:Tweaked EmmyLua type stubs (VS Code autocomplete)
#   2. Git hooks (pre-commit luacheck)
#
# Usage: .\setup.ps1

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CC:Tweaked Programs — Dev Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- Locate git executable ---
$git = (Get-Command git -ErrorAction SilentlyContinue)?.Source
if (-not $git) {
    $candidates = @(
        "C:\Program Files\Git\bin\git.exe",
        "C:\Program Files (x86)\Git\bin\git.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { $git = $c; break }
    }
}
if (-not $git) {
    Write-Host "❌ git not found. Please install Git from https://git-scm.com and re-run this script." -ForegroundColor Red
    exit 1
}
Write-Host "  Using git: $git" -ForegroundColor DarkGray
Write-Host ""

# --- 1. CC:Tweaked EmmyLua Type Stubs ---
Write-Host "[1/2] Setting up CC:Tweaked EmmyLua type stubs..." -ForegroundColor Yellow

$stubsDir = ".stubs\cc-tweaked"

if (Test-Path $stubsDir) {
    Write-Host "  Stubs already exist — pulling latest..." -ForegroundColor Gray
    & $git -C $stubsDir pull --quiet
    Write-Host "  ✅ Stubs updated." -ForegroundColor Green
} else {
    Write-Host "  Cloning jilleJr/CC-Tweaked-EmmyLua into $stubsDir..." -ForegroundColor Gray
    & $git clone --quiet --depth 1 https://github.com/jilleJr/CC-Tweaked-EmmyLua.git $stubsDir
    Write-Host "  ✅ Stubs installed." -ForegroundColor Green
}

Write-Host ""

# --- 2. Git Hooks ---
Write-Host "[2/2] Configuring git hooks path..." -ForegroundColor Yellow
& $git config core.hooksPath .githooks
Write-Host "  ✅ Git will now use .githooks/ for pre-commit checks." -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup complete! Reload VS Code now." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
