<#
.SYNOPSIS
    Opens today's daily note, creating it if needed with automatic task rollover.
.DESCRIPTION
    - Creates $HOME/work directory structure if missing
    - Rolls over incomplete tasks from the most recent previous daily note
    - Opens today's note in Neovim
.EXAMPLE
    ./Open-Today.ps1
    ./Open-Today.ps1 -NoEdit  # Create/rollover only, don't open editor
#>

param(
    [switch]$NoEdit
)

$WorkRoot = Join-Path $HOME "work"
$TodayDir = Join-Path $WorkRoot "01_today"
$TemplateDir = Join-Path $WorkRoot "08_templates"

$Today = Get-Date -Format "yyyy-MM-dd"
$TodayFile = Join-Path $TodayDir "$Today.md"

# Initialize directory structure if missing
function Initialize-WorkStructure {
    $folders = @(
        "00_inbox",
        "01_today",
        "02_projects",
        "03_people",
        "04_meetings",
        "05_process",
        "06_reference",
        "07_logs",
        "08_templates",
        "99_archive"
    )
    
    foreach ($folder in $folders) {
        $path = Join-Path $WorkRoot $folder
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
            Write-Host "Created: $folder" -ForegroundColor Green
        }
    }
}

# Get incomplete tasks from a markdown file
function Get-IncompleteTasks {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) { return @() }
    
    $content = Get-Content $FilePath -Raw
    $tasks = [regex]::Matches($content, '^\s*-\s*\[\s*\]\s*.+$', 'Multiline')
    return $tasks | ForEach-Object { $_.Value.Trim() }
}

# Find most recent daily note before today
function Get-PreviousDailyNote {
    if (-not (Test-Path $TodayDir)) { return $null }
    
    $files = Get-ChildItem -Path $TodayDir -Filter "*.md" |
        Where-Object { $_.BaseName -match '^\d{4}-\d{2}-\d{2}$' -and $_.BaseName -lt $Today } |
        Sort-Object BaseName -Descending |
        Select-Object -First 1
    
    return $files
}

# Create today's note from template with rolled-over tasks
function New-DailyNote {
    $templatePath = Join-Path $TemplateDir "daily.md"
    
    # Default template if file doesn't exist
    $template = @"
# $Today

## Focus
- [ ] 
- [ ] 
- [ ] 

## Meetings
- 

## Tasks
- [ ] 

## Notes
- 

## Follow-ups
- [ ] 
"@

    if (Test-Path $templatePath) {
        $template = (Get-Content $templatePath -Raw) -replace '\{\{date\}\}', $Today
    }

    # Get tasks to roll over
    $previousNote = Get-PreviousDailyNote
    $rolledTasks = @()
    
    if ($previousNote) {
        $rolledTasks = Get-IncompleteTasks -FilePath $previousNote.FullName
        if ($rolledTasks.Count -gt 0) {
            Write-Host "Rolling over $($rolledTasks.Count) task(s) from $($previousNote.BaseName)" -ForegroundColor Yellow
        }
    }

    # Insert rolled tasks under ## Tasks
    if ($rolledTasks.Count -gt 0) {
        $taskSection = "## Tasks`n"
        foreach ($task in $rolledTasks) {
            $taskSection += "$task`n"
        }
        $taskSection += "- [ ] "
        $template = $template -replace '## Tasks\s*\n-\s*\[\s*\]\s*', $taskSection
    }

    $template | Set-Content -Path $TodayFile -NoNewline
    Write-Host "Created: $TodayFile" -ForegroundColor Green
}

# Main execution
Initialize-WorkStructure

if (-not (Test-Path $TodayFile)) {
    New-DailyNote
} else {
    Write-Host "Today's note exists: $TodayFile" -ForegroundColor Cyan
}

if (-not $NoEdit) {
    & nvim $TodayFile
}
