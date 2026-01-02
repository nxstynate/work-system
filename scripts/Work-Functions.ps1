<#
.SYNOPSIS
    Utility functions for the work notes system.
.DESCRIPTION
    Source this file in your PowerShell profile to get quick access functions.
.EXAMPLE
    . ~/work-system/scripts/Work-Functions.ps1
    wt      # Open today's note
    wnm     # Create new meeting
    ws      # Search notes
#>

$script:WorkRoot = Join-Path $HOME "work"
$script:ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# ============================================
# BROWSE COMMANDS
# ============================================

# wt - Open today's daily note
function Open-WorkToday {
    $scriptPath = Join-Path $ScriptRoot "Open-Today.ps1"
    & $scriptPath
}
Set-Alias -Name wt -Value Open-WorkToday

# wi - Open inbox
function Open-WorkInbox {
    $inbox = Join-Path $WorkRoot "00_inbox"
    if (-not (Test-Path $inbox)) {
        New-Item -ItemType Directory -Path $inbox -Force | Out-Null
    }
    Set-Location $inbox
    & nvim .
}
Set-Alias -Name wi -Value Open-WorkInbox

# ws - Search all work notes with ripgrep
function Search-WorkNotes {
    param([Parameter(Position=0)][string]$Query)
    if ($Query) {
        Push-Location $WorkRoot
        & rg -i --type md $Query
        Pop-Location
    } else {
        # No query = open Telescope search
        Push-Location $WorkRoot
        & nvim -c "Telescope live_grep"
        Pop-Location
    }
}
Set-Alias -Name ws -Value Search-WorkNotes

# wf - Find files in work directory
function Find-WorkFiles {
    Push-Location $WorkRoot
    & nvim -c "Telescope find_files"
    Pop-Location
}
Set-Alias -Name wf -Value Find-WorkFiles

# wp - Browse projects
function Open-WorkProjects {
    $projects = Join-Path $WorkRoot "02_projects"
    if (-not (Test-Path $projects)) {
        New-Item -ItemType Directory -Path $projects -Force | Out-Null
    }
    Set-Location $projects
    & nvim -c "Telescope find_files"
}
Set-Alias -Name wp -Value Open-WorkProjects

# we - Browse people
function Open-WorkPeople {
    $people = Join-Path $WorkRoot "03_people"
    if (-not (Test-Path $people)) {
        New-Item -ItemType Directory -Path $people -Force | Out-Null
    }
    Set-Location $people
    & nvim -c "Telescope find_files"
}
Set-Alias -Name we -Value Open-WorkPeople

# wm - Browse meetings
function Open-WorkMeetings {
    $meetings = Join-Path $WorkRoot "04_meetings"
    if (-not (Test-Path $meetings)) {
        New-Item -ItemType Directory -Path $meetings -Force | Out-Null
    }
    Set-Location $meetings
    & nvim -c "Telescope find_files"
}
Set-Alias -Name wm -Value Open-WorkMeetings

# wl - List recent daily notes
function Get-RecentDailyNotes {
    param([int]$Count = 7)
    $todayDir = Join-Path $WorkRoot "01_today"
    if (Test-Path $todayDir) {
        Get-ChildItem -Path $todayDir -Filter "*.md" |
            Sort-Object Name -Descending |
            Select-Object -First $Count |
            ForEach-Object { $_.Name }
    }
}
Set-Alias -Name wl -Value Get-RecentDailyNotes

# wd - Open a specific daily note by offset (0=today, 1=yesterday, etc.)
function Open-DailyNote {
    param([int]$DaysAgo = 0)
    $date = (Get-Date).AddDays(-$DaysAgo).ToString("yyyy-MM-dd")
    $todayDir = Join-Path $WorkRoot "01_today"
    $file = Join-Path $todayDir "$date.md"
    
    if (Test-Path $file) {
        & nvim $file
    } else {
        Write-Host "No note for $date" -ForegroundColor Yellow
    }
}
Set-Alias -Name wd -Value Open-DailyNote

# ============================================
# CREATE COMMANDS (wn*)
# ============================================

# wnm - Create new meeting
function New-WorkMeeting {
    param([Parameter(Position=0)][string]$Title)
    if (-not $Title) {
        $Title = Read-Host "Meeting title"
    }
    if ($Title) {
        $scriptPath = Join-Path $ScriptRoot "New-Meeting.ps1"
        & $scriptPath -Title $Title
    }
}
Set-Alias -Name wnm -Value New-WorkMeeting

# wnp - Create new project
function New-WorkProject {
    param([Parameter(Position=0)][string]$Name)
    if (-not $Name) {
        $Name = Read-Host "Project name"
    }
    if ($Name) {
        $scriptPath = Join-Path $ScriptRoot "New-Project.ps1"
        & $scriptPath -Name $Name -Open
    }
}
Set-Alias -Name wnp -Value New-WorkProject

# wne - Create new person
function New-WorkPerson {
    param(
        [Parameter(Position=0)][string]$Name,
        [string]$Role = ""
    )
    if (-not $Name) {
        $Name = Read-Host "Person name"
    }
    if ($Name) {
        $scriptPath = Join-Path $ScriptRoot "New-Person.ps1"
        & $scriptPath -Name $Name -Role $Role
    }
}
Set-Alias -Name wne -Value New-WorkPerson

# ============================================
# UTILITY COMMANDS
# ============================================

# cdw - Quick CD to work root
function Set-WorkLocation {
    Set-Location $WorkRoot
}
Set-Alias -Name cdw -Value Set-WorkLocation

# ============================================
# HELP
# ============================================

function Show-WorkHelp {
    Write-Host ""
    Write-Host "Work Notes System" -ForegroundColor Cyan
    Write-Host "================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Browse:" -ForegroundColor Yellow
    Write-Host "  wt          Today's note"
    Write-Host "  wi          Inbox"
    Write-Host "  ws [query]  Search notes (ripgrep or Telescope)"
    Write-Host "  wf          Find files (Telescope)"
    Write-Host "  wp          Projects"
    Write-Host "  we          People"
    Write-Host "  wm          Meetings"
    Write-Host "  wl [n]      List recent daily notes"
    Write-Host "  wd [n]      Open note n days ago"
    Write-Host ""
    Write-Host "Create:" -ForegroundColor Yellow
    Write-Host "  wnm [title] New meeting"
    Write-Host "  wnp [name]  New project"
    Write-Host "  wne [name]  New person"
    Write-Host ""
    Write-Host "Utility:" -ForegroundColor Yellow
    Write-Host "  cdw         CD to work root"
    Write-Host "  wh          Show this help"
    Write-Host ""
}
Set-Alias -Name wh -Value Show-WorkHelp

Write-Host "Work system loaded. Type 'wh' for help." -ForegroundColor Cyan
