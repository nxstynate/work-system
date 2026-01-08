<#
.SYNOPSIS
    Creates or opens today's log file for journaling.
.DESCRIPTION
    Creates a log file in 07_logs/ with format YYYY-MM-DD.md
    If the file already exists, opens it for appending.
.EXAMPLE
    ./New-Log.ps1
#>

$WorkRoot = Join-Path $HOME "work"
$LogsDir = Join-Path $WorkRoot "07_logs"
$TemplateDir = Join-Path $WorkRoot "08_templates"

$Today = Get-Date -Format "yyyy-MM-dd"
$DayOfWeek = (Get-Date).ToString("dddd")
$LogFile = Join-Path $LogsDir "$Today.md"

# Helper function to write with Unix line endings
function Write-UnixFile {
    param(
        [string]$Path,
        [string]$Content
    )
    $unixContent = $Content -replace "`r`n", "`n" -replace "`r", "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $unixContent, $utf8NoBom)
}

# Ensure logs directory exists
if (-not (Test-Path $LogsDir)) {
    New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
}

if (Test-Path $LogFile) {
    Write-Host "Opening existing log: $LogFile" -ForegroundColor Cyan
} else {
    # Check for template
    $templatePath = Join-Path $TemplateDir "log.md"
    
    $template = @"
# $Today ($DayOfWeek)

"@

    if (Test-Path $templatePath) {
        $template = (Get-Content $templatePath -Raw) `
            -replace '\{\{date\}\}', $Today `
            -replace '\{\{day\}\}', $DayOfWeek
    }

    Write-UnixFile -Path $LogFile -Content $template
    Write-Host "Created: $LogFile" -ForegroundColor Green
}

& nvim $LogFile
