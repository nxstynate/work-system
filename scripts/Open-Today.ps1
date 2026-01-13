<#
.SYNOPSIS
    Opens today's daily note, creating it if needed with automatic task rollover.
.DESCRIPTION
    - Creates $HOME/work directory structure if missing
    - Rolls over incomplete tasks from the most recent previous daily note
    - Tasks roll over within their sections (Focus->Focus, Tasks->Tasks, Follow-ups->Follow-ups)
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

# Get incomplete tasks from a specific section of a markdown file
function Get-IncompleteTasks {
    param(
        [string]$FilePath,
        [string]$SectionName
    )
    
    if (-not (Test-Path $FilePath)) { return @() }
    
    $content = Get-Content $FilePath -Raw
    
    # Match the section: ## SectionName followed by content until next ## or end
    $pattern = "(?ms)^## $SectionName\s*\n(.*?)(?=^## |\z)"
    $match = [regex]::Match($content, $pattern)
    
    if (-not $match.Success) { return @() }
    
    $sectionContent = $match.Groups[1].Value
    
    # Find incomplete tasks within this section
    $tasks = [regex]::Matches($sectionContent, '^\s*-\s*\[\s*\]\s*.+$', 'Multiline')
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

# Write content with Unix line endings (LF only, no CRLF)
function Write-UnixFile {
    param(
        [string]$Path,
        [string]$Content
    )
    
    # Normalize to Unix line endings
    $unixContent = $Content -replace "`r`n", "`n" -replace "`r", "`n"
    
    # Write as UTF8 without BOM with Unix line endings
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $unixContent, $utf8NoBom)
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

    # Get tasks to roll over from each section
    $previousNote = Get-PreviousDailyNote
    $rolledFocus = @()
    $rolledTasks = @()
    $rolledFollowups = @()
    
    if ($previousNote) {
        $rolledFocus = Get-IncompleteTasks -FilePath $previousNote.FullName -SectionName "Focus"
        $rolledTasks = Get-IncompleteTasks -FilePath $previousNote.FullName -SectionName "Tasks"
        $rolledFollowups = Get-IncompleteTasks -FilePath $previousNote.FullName -SectionName "Follow-ups"
        
        $totalRolled = $rolledFocus.Count + $rolledTasks.Count + $rolledFollowups.Count
        if ($totalRolled -gt 0) {
            Write-Host "Rolling over from $($previousNote.BaseName):" -ForegroundColor Yellow
            if ($rolledFocus.Count -gt 0) { Write-Host "  Focus: $($rolledFocus.Count)" -ForegroundColor DarkYellow }
            if ($rolledTasks.Count -gt 0) { Write-Host "  Tasks: $($rolledTasks.Count)" -ForegroundColor DarkYellow }
            if ($rolledFollowups.Count -gt 0) { Write-Host "  Follow-ups: $($rolledFollowups.Count)" -ForegroundColor DarkYellow }
        }
    }

    # Insert rolled Focus items
    if ($rolledFocus.Count -gt 0) {
        $focusSection = "## Focus`n"
        foreach ($task in $rolledFocus) {
            $focusSection += "$task`n"
        }
        $template = $template -replace '(?ms)## Focus\s*\n(- \[ \] \n?)*', $focusSection
    }

    # Insert rolled Tasks
    if ($rolledTasks.Count -gt 0) {
        $taskSection = "## Tasks`n"
        foreach ($task in $rolledTasks) {
            $taskSection += "$task`n"
        }
        $template = $template -replace '(?ms)## Tasks\s*\n(- \[ \] \n?)*', $taskSection
    }

    # Insert rolled Follow-ups
    if ($rolledFollowups.Count -gt 0) {
        $followupSection = "## Follow-ups`n"
        foreach ($task in $rolledFollowups) {
            $followupSection += "$task`n"
        }
        $template = $template -replace '(?ms)## Follow-ups\s*\n(- \[ \] \n?)*', $followupSection
    }

    # Write with Unix line endings
    Write-UnixFile -Path $TodayFile -Content $template
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
