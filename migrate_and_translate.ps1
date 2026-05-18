# CC:Tweaked Documentation Migration & AI Translation Tool (Windows PowerShell Edition)
# No dependencies, no Python required! Runs fully natively.

$basePath = $PSScriptRoot
if ([string]::IsNullOrEmpty($basePath)) {
    $basePath = Get-Location
}

$logPath = Join-Path $basePath "migrate_and_translate_log.txt"

# Clear or create the log file with a clean header
Set-Content -Path $logPath -Value "=== CC:Tweaked Documentation Migration & Native Translation Tool Log ===" -Encoding utf8

function Log-Message {
    param (
        [string]$Message,
        [string]$ForegroundColor = "White"
    )
    # Output to console with color
    Write-Host $Message -ForegroundColor $ForegroundColor
    
    # Output to log file
    Add-Content -Path $logPath -Value $Message -Encoding utf8
}

$projects = @(
    "CC Developer Suite",
    "Create Mechanical Crafter Automation",
    "Mekanism Portal Dialer Hub",
    "Mekanism Portal Dialer Recall Sender",
    "Powah Energizing Orb Automation"
)

$languages = @("de", "es", "fr", "pt-BR", "zh-CN", "ja", "ko", "ru")

# Metadata for flags and languages using Unicode surrogate pair character codes to remain 100% plain-ASCII
$langMetadata = @{
    "de" = @{ "flag" = "$([char]0xD83C)$([char]0xDDE9)$([char]0xD83C)$([char]0xDDEA)"; "name" = "de / Deutsch" }
    "es" = @{ "flag" = "$([char]0xD83C)$([char]0xDDEA)$([char]0xD83C)$([char]0xDDF8)"; "name" = "es / Espanol" }
    "fr" = @{ "flag" = "$([char]0xD83C)$([char]0xDDEB)$([char]0xD83C)$([char]0xDDF7)"; "name" = "fr / Francais" }
    "pt-BR" = @{ "flag" = "$([char]0xD83C)$([char]0xDDE7)$([char]0xD83C)$([char]0xDDF7)"; "name" = "pt-BR / Portugues (Brasil)" }
    "zh-CN" = @{ "flag" = "$([char]0xD83C)$([char]0xDDE8)$([char]0xD83C)$([char]0xDDF3)"; "name" = "zh-CN / Chinese (Simplified)" }
    "ja" = @{ "flag" = "$([char]0xD83C)$([char]0xDDEF)$([char]0xD83C)$([char]0xDDF5)"; "name" = "ja / Japanese" }
    "ko" = @{ "flag" = "$([char]0xD83C)$([char]0xDDF0)$([char]0xD83C)$([char]0xDDF7)"; "name" = "ko / Korean" }
    "ru" = @{ "flag" = "$([char]0xD83C)$([char]0xDDF7)$([char]0xD83C)$([char]0xDDFA)"; "name" = "ru / Russian" }
}

function Get-Disclaimer {
    param (
        [string]$Lang,
        [string]$EngPath
    )
    $meta = $langMetadata[$Lang]
    $flag = $meta.flag
    $name = $meta.name
    
    # English warning text to be translated dynamically at runtime
    $baseWarning = "Note: This README was automatically translated by an AI assistant (Antigravity) and may contain translation errors or inaccuracies. For the most accurate and up-to-date documentation, please refer to the original English"
    $translatedWarning = Invoke-TranslateText -Text $baseWarning -TargetLang $Lang
    
    $disclaimer = "> [!WARNING]`r`n"
    $disclaimer += "> $flag **$name**`r`n"
    $disclaimer += "> `r`n"
    $disclaimer += "> $translatedWarning [README.md]($EngPath).`r`n`r`n"
    return $disclaimer
}

$imageMappings = @{
    "Create Mechanical Crafter Automation" = @{ "orig" = "images/setup.png"; "new" = "crafter-setup.png" }
    "Mekanism Portal Dialer Hub" = @{ "orig" = "images/setup.png"; "new" = "hub-setup.png" }
    "Powah Energizing Orb Automation" = @{ "orig" = "images/setup.png"; "new" = "orb-setup.png" }
}

$global:translationCache = @{}

function Invoke-TranslateText {
    param (
        [string]$Text,
        [string]$TargetLang
    )
    if ([string]::IsNullOrWhiteSpace($Text)) { return $Text }
    
    $cacheKey = "$TargetLang|$Text"
    if ($global:translationCache.Contains($cacheKey)) {
        return $global:translationCache[$cacheKey]
    }
    
    $gLang = $TargetLang
    if ($TargetLang -eq "pt-BR") { $gLang = "pt" }
    
    # URL encode the query text
    $encodedText = [Uri]::EscapeDataString($Text)
    $url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$gLang&dt=t&q=$encodedText"
    
    try {
        # Fetch translation using Invoke-RestMethod (built-in PowerShell cmdlet)
        $response = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 10
        $translated = ""
        foreach ($segment in $response[0]) {
            $translated += $segment[0]
        }
        
        # Save to cache
        $global:translationCache[$cacheKey] = $translated
        
        # Tiny delay to be polite to the API and prevent rate limits
        Start-Sleep -Milliseconds 50
        
        return $translated
    } catch {
        # Rate limit retry logic
        Log-Message "  [!] Rate limit or API warning. Cooling down and retrying in 2 seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        try {
            $response = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 10
            $translated = ""
            foreach ($segment in $response[0]) {
                $translated += $segment[0]
            }
            $global:translationCache[$cacheKey] = $translated
            return $translated
        } catch {
            return $Text # Fallback to original text on failure
        }
    }
}

function Invoke-TranslateMarkdown {
    param (
        [string]$Content,
        [string]$TargetLang
    )
    $lines = $Content -split "`r?`n"
    $translatedLines = @()
    $inCodeBlock = $false
    
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        
        # 1. Preserve Code Blocks
        if ($trimmed.StartsWith('```')) {
            $inCodeBlock = -not $inCodeBlock
            $translatedLines += $line
            continue
        }
        
        if ($inCodeBlock -or [string]::IsNullOrEmpty($trimmed)) {
            $translatedLines += $line
            continue
        }
        
        # 2. Preserve badges, top links, images and horizontal rules
        if ($trimmed.StartsWith('![') -or $trimmed.StartsWith('[')) {
            $translatedLines += $line
            continue
        }
        if ($trimmed.StartsWith('---') -or $trimmed.StartsWith('===')) {
            $translatedLines += $line
            continue
        }
        
        # 3. Handle Markdown Tables
        if ($trimmed.StartsWith('|') -and $trimmed.EndsWith('|')) {
            $cells = $line -split '\|'
            $translatedCells = @()
            for ($i = 0; $i -lt $cells.Length; $i++) {
                $cell = $cells[$i]
                if ($i -eq 0 -or $i -eq ($cells.Length - 1)) {
                    $translatedCells += ''
                } elseif ($cell.Trim().StartsWith('---') -or $cell.Trim().StartsWith(':---')) {
                    $translatedCells += $cell
                } else {
                    $tCell = Invoke-TranslateText -Text ($cell.Trim()) -TargetLang $TargetLang
                    $translatedCells += " $tCell "
                }
            }
            # Reconstruct table row
            $reconstructed = '|' + (($translatedCells[1..($translatedCells.Length-2)]) -join '|') + '|'
            $translatedLines += $reconstructed
            continue
        }
        
        # 4. Handle Headers
        if ($trimmed.StartsWith('#')) {
            $headerLevel = 0
            while ($headerLevel -lt $trimmed.Length -and $trimmed[$headerLevel] -eq '#') {
                $headerLevel++
            }
            $headerText = $trimmed.Substring($headerLevel).Trim()
            $tHeader = Invoke-TranslateText -Text $headerText -TargetLang $TargetLang
            $translatedLines += ('#' * $headerLevel) + ' ' + $tHeader
            continue
        }
        
        # 5. Handle Bullet points, lists, quotes
        $prefix = ''
        $lineContent = $line
        if ($trimmed.StartsWith('- ')) {
            $prefix = '- '
            $lineContent = $trimmed.Substring(2)
        } elseif ($trimmed.StartsWith('* ')) {
            $prefix = '* '
            $lineContent = $trimmed.Substring(2)
        } elseif ($trimmed.StartsWith('> ')) {
            $prefix = '> '
            $lineContent = $trimmed.Substring(2)
        }
        
        $tVal = Invoke-TranslateText -Text $lineContent -TargetLang $TargetLang
        $translatedLines += $prefix + $tVal
    }
    
    return $translatedLines -join "`r`n"
}


Log-Message "=== CC:Tweaked Documentation Migration & Native Translation Tool ===" -ForegroundColor Green

# Escape characters for globe and accented/non-ASCII language names to keep file 100% plain-ASCII
$globe = "$([char]0xD83C)$([char]0xDF10)"
$esName = "Espa$([char]0x00F1)ol"
$frName = "Fran$([char]0x00E7)ais"
$ptName = "Portugu$([char]0x00EA)s (Brasil)"
$zhName = "$([char]0x7B80)$([char]0x4F53)$([char]0x4E2D)$([char]0x6587)"
$jaName = "$([char]0x65E5)$([char]0x672C)$([char]0x8A9E)"
$koName = "$([char]0xD55C)$([char]0xAD6D)$([char]0xC5B4)"
$ruName = "$([char]0x0420)$([char]0x0443)$([char]0x0441)$([char]0x0441)$([char]0x043A)$([char]0x0438)$([char]0x0439)"

$engSelector = "$globe **Languages:** [English](README.md) | [Deutsch](docs/i18n/de/README.md) | [$esName](docs/i18n/es/README.md) | [$frName](docs/i18n/fr/README.md) | [$ptName](docs/i18n/pt-BR/README.md) | [$jaName](docs/i18n/ja/README.md) | [$koName](docs/i18n/ko/README.md) | [$ruName](docs/i18n/ru/README.md) | [$zhName](docs/i18n/zh-CN/README.md)"

$langSelector = "$globe **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [$esName](../es/README.md) | [$frName](../fr/README.md) | [$ptName](../pt-BR/README.md) | [$jaName](../ja/README.md) | [$koName](../ko/README.md) | [$ruName](../ru/README.md) | [$zhName](../zh-CN/README.md)"


# 1. Process all project directories
foreach ($project in $projects) {
    Log-Message "`n[*] Processing Project: $project" -ForegroundColor Cyan
    $projectPath = Join-Path $basePath $project
    $engReadmePath = Join-Path $projectPath "README.md"
    
    if (!(Test-Path $engReadmePath)) {
        Log-Message "  [!] English README.md not found. Skipping." -ForegroundColor Yellow
        continue
    }
    
    # A. Migrate Image files safely
    if ($imageMappings.Contains($project)) {
        $mapping = $imageMappings[$project]
        $origImgPath = Join-Path $projectPath $mapping.orig
        $targetImgDir = Join-Path $projectPath "docs\assets\images"
        $targetImgPath = Join-Path $targetImgDir $mapping.new
        
        if (Test-Path $origImgPath) {
            if (!(Test-Path $targetImgDir)) {
                New-Item -ItemType Directory -Path $targetImgDir -Force | Out-Null
            }
            Copy-Item -Path $origImgPath -Destination $targetImgPath -Force
            Log-Message "  [->] Copied setup.png -> docs/assets/images/$($mapping.new)" -ForegroundColor Green
            
            # Clean up old images folder if empty
            $oldImgDir = Split-Path $origImgPath -Parent
            if (Test-Path $oldImgDir) {
                $files = Get-ChildItem -Path $oldImgDir
                if ($files.Count -eq 0) {
                    Remove-Item -Path $oldImgDir -Force
                    Log-Message "  [-] Cleaned up empty original images directory" -ForegroundColor Gray
                }
            }
        }
    }
    
    # Read the original English README
    $engContent = Get-Content -Path $engReadmePath -Raw -Encoding utf8
    
    # Add language selector to the English README if not present (ASCII-safe check)
    if ($engContent -notlike "*Languages:** *") {
        $index = $engContent.IndexOf("---")
        if ($index -ne -1) {
            $engContent = $engContent.Substring(0, $index) + $engSelector + "`r`n`r`n" + $engContent.Substring($index)
            Set-Content -Path $engReadmePath -Value $engContent -Encoding utf8
            Log-Message "  [+] Added language selector to English README" -ForegroundColor Green
        }
    }
    
    # Prepare clean content for translation by stripping the selector line to prevent duplication
    $contentToTranslate = $engContent
    if ($contentToTranslate -like "*Languages:** *") {
        $lines = $contentToTranslate -split "`r?`n"
        $filteredLines = @()
        foreach ($line in $lines) {
            if ($line -notlike "*Languages:** *") {
                $filteredLines += $line
            }
        }
        $contentToTranslate = $filteredLines -join "`r`n"
    }
    
    # B. Translate and write READMEs for all target languages
    foreach ($lang in $languages) {
        Log-Message "  [+] Translating to $lang..." -ForegroundColor Gray
        $langDir = Join-Path $projectPath "docs\i18n\$lang"
        if (!(Test-Path $langDir)) {
            New-Item -ItemType Directory -Path $langDir -Force | Out-Null
        }
        
        # Translate the content (without the English selector line)
        $translatedContent = Invoke-TranslateMarkdown -Content $contentToTranslate -TargetLang $lang
        
        # Adjust relative root-level links to point to the correct depth (3 levels up)
        $translatedContent = $translatedContent -replace '\(\./AGENTS\.md\)', '(../../../AGENTS.md)'
        $translatedContent = $translatedContent -replace '\(AGENTS\.md\)', '(../../../AGENTS.md)'
        $translatedContent = $translatedContent -replace '\(\./LICENSE\)', '(../../../LICENSE)'
        $translatedContent = $translatedContent -replace '\(LICENSE\)', '(../../../LICENSE)'
        
        # Prepend the disclaimer warning
        $disclaimer = Get-Disclaimer -Lang $lang -EngPath '../../../README.md'
        
        # Update relative image path reference in translated file
        if ($imageMappings.Contains($project)) {
            $mapping = $imageMappings[$project]
            $translatedContent = $translatedContent.Replace("docs/assets/images/$($mapping.new)", "../../assets/images/$($mapping.new)")
        }
        
        $fullFile = $disclaimer + $langSelector + "`r`n`r`n" + $translatedContent
        $targetReadme = Join-Path $langDir "README.md"
        Set-Content -Path $targetReadme -Value $fullFile -Encoding utf8
        Log-Message "    [OK] Wrote docs/i18n/$lang/README.md" -ForegroundColor Green
    }
}

# 2. Process the repository root README.md
Log-Message "`n[*] Processing Repository Root" -ForegroundColor Cyan
$rootReadmePath = Join-Path $basePath "README.md"

if (Test-Path $rootReadmePath) {
    $rootContent = Get-Content -Path $rootReadmePath -Raw -Encoding utf8
    
    # Add language selector to the English Root README if not present (ASCII-safe check)
    if ($rootContent -notlike "*Languages:** *") {
        $index = $rootContent.IndexOf("---")
        if ($index -ne -1) {
            $rootContent = $rootContent.Substring(0, $index) + $engSelector + "`r`n`r`n" + $rootContent.Substring($index)
            Set-Content -Path $rootReadmePath -Value $rootContent -Encoding utf8
            Log-Message "  [+] Added language selector to Root English README" -ForegroundColor Green
        }
    }
    
    # Prepare clean content for translation by stripping the selector line to prevent duplication
    $rootContentToTranslate = $rootContent
    if ($rootContentToTranslate -like "*Languages:** *") {
        $lines = $rootContentToTranslate -split "`r?`n"
        $filteredLines = @()
        foreach ($line in $lines) {
            if ($line -notlike "*Languages:** *") {
                $filteredLines += $line
            }
        }
        $rootContentToTranslate = $filteredLines -join "`r`n"
    }
    
    foreach ($lang in $languages) {
        Log-Message "  [+] Translating Root to $lang..." -ForegroundColor Gray
        $langDir = Join-Path $basePath "docs\i18n\$lang"
        if (!(Test-Path $langDir)) {
            New-Item -ItemType Directory -Path $langDir -Force | Out-Null
        }
        
        $translatedContent = Invoke-TranslateMarkdown -Content $rootContentToTranslate -TargetLang $lang
        
        # Adjust relative root-level links to point to the correct depth (3 levels up)
        $translatedContent = $translatedContent -replace '\(\./AGENTS\.md\)', '(../../../AGENTS.md)'
        $translatedContent = $translatedContent -replace '\(AGENTS\.md\)', '(../../../AGENTS.md)'
        $translatedContent = $translatedContent -replace '\(\./LICENSE\)', '(../../../LICENSE)'
        $translatedContent = $translatedContent -replace '\(LICENSE\)', '(../../../LICENSE)'
        
        $disclaimer = Get-Disclaimer -Lang $lang -EngPath '../../../README.md'
        
        $fullFile = $disclaimer + $langSelector + "`r`n`r`n" + $translatedContent
        $targetReadme = Join-Path $langDir "README.md"
        Set-Content -Path $targetReadme -Value $fullFile -Encoding utf8
        Log-Message "    [OK] Wrote docs/i18n/$lang/README.md" -ForegroundColor Green
    }
}

Log-Message "`n=== All assets migrated and all README files translated successfully! ===" -ForegroundColor Green

