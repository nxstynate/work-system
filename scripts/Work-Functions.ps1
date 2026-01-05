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
    wh      # Show help
#>

$script:WorkRoot = Join-Path $HOME "work"
$script:ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:SystemRoot = Split-Path -Parent $ScriptRoot

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
        & nvim -c "lua vim.schedule(function() require('telescope.builtin').live_grep({cwd='$($WorkRoot -replace '\\','/')'}) end)"
        Pop-Location
    }
}
Set-Alias -Name ws -Value Search-WorkNotes

# wf - Find files in work directory
function Find-WorkFiles {
    Push-Location $WorkRoot
    & nvim -c "lua vim.schedule(function() require('telescope.builtin').find_files({cwd='$($WorkRoot -replace '\\','/')'}) end)"
    Pop-Location
}
Set-Alias -Name wf -Value Find-WorkFiles

# wp - Browse projects
function Open-WorkProjects {
    $projects = Join-Path $WorkRoot "02_projects"
    if (-not (Test-Path $projects)) {
        New-Item -ItemType Directory -Path $projects -Force | Out-Null
    }
    $projectsPath = $projects -replace '\\','/'
    Set-Location $projects
    & nvim -c "lua vim.schedule(function() require('telescope.builtin').find_files({cwd='$projectsPath'}) end)"
}
Set-Alias -Name wp -Value Open-WorkProjects

# we - Browse people
function Open-WorkPeople {
    $people = Join-Path $WorkRoot "03_people"
    if (-not (Test-Path $people)) {
        New-Item -ItemType Directory -Path $people -Force | Out-Null
    }
    $peoplePath = $people -replace '\\','/'
    Set-Location $people
    & nvim -c "lua vim.schedule(function() require('telescope.builtin').find_files({cwd='$peoplePath'}) end)"
}
Set-Alias -Name we -Value Open-WorkPeople

# wm - Browse meetings
function Open-WorkMeetings {
    $meetings = Join-Path $WorkRoot "04_meetings"
    if (-not (Test-Path $meetings)) {
        New-Item -ItemType Directory -Path $meetings -Force | Out-Null
    }
    $meetingsPath = $meetings -replace '\\','/'
    Set-Location $meetings
    & nvim -c "lua vim.schedule(function() require('telescope.builtin').find_files({cwd='$meetingsPath'}) end)"
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
# HELP SYSTEM
# ============================================

function Show-WorkHelpCommands {
    Write-Host ""
    Write-Host "  BROWSE COMMANDS" -ForegroundColor Yellow
    Write-Host "  ---------------"
    Write-Host "  wt            Open today's daily note (creates if needed, rolls over tasks)"
    Write-Host "  wi            Open inbox folder for quick capture"
    Write-Host "  ws [query]    Search notes - with query uses ripgrep, without opens Telescope"
    Write-Host "  wf            Find files in work directory (Telescope)"
    Write-Host "  wp            Browse projects folder"
    Write-Host "  we            Browse people files"
    Write-Host "  wm            Browse meeting notes"
    Write-Host "  wl [n]        List recent n daily notes (default: 7)"
    Write-Host "  wd [n]        Open note from n days ago (0=today, 1=yesterday)"
    Write-Host ""
    Write-Host "  CREATE COMMANDS" -ForegroundColor Yellow
    Write-Host "  ---------------"
    Write-Host "  wnm [title]   Create new meeting note (YYYY-MM-DD-slug.md)"
    Write-Host "  wnp [name]    Create new project folder with standard files"
    Write-Host "  wne [name]    Create new person file"
    Write-Host ""
    Write-Host "  UTILITY COMMANDS" -ForegroundColor Yellow
    Write-Host "  ----------------"
    Write-Host "  cdw           Change directory to work root"
    Write-Host "  wh            Show this help (or: wh commands|workflow|folders|tips)"
    Write-Host ""
}

function Show-WorkHelpWorkflow {
    Write-Host ""
    Write-Host "  DAILY WORKFLOW" -ForegroundColor Yellow
    Write-Host "  ---------------"
    Write-Host ""
    Write-Host "  START OF DAY" -ForegroundColor Cyan
    Write-Host "  1. Run 'wt' to open today's note"
    Write-Host "  2. Review rolled-over tasks from yesterday"
    Write-Host "  3. Set your top 3 Focus items"
    Write-Host "  4. Add known meetings to the Meetings section"
    Write-Host ""
    Write-Host "  DURING THE DAY" -ForegroundColor Cyan
    Write-Host "  - Capture thoughts in Notes section"
    Write-Host "  - Add tasks as they come up: - [ ] task description"
    Write-Host "  - Mark complete: - [x] task description"
    Write-Host "  - Quick meeting notes: add to Meetings section"
    Write-Host "  - Detailed meeting: run 'wnm `"meeting title`"'"
    Write-Host ""
    Write-Host "  END OF DAY" -ForegroundColor Cyan
    Write-Host "  - Review incomplete items (they roll over automatically)"
    Write-Host "  - Move completed projects to 99_archive/"
    Write-Host "  - Close Neovim - that's it!"
    Write-Host ""
    Write-Host "  TASK ROLLOVER" -ForegroundColor Cyan
    Write-Host "  - Focus items -> roll to Focus"
    Write-Host "  - Tasks -> roll to Tasks"
    Write-Host "  - Follow-ups -> roll to Follow-ups"
    Write-Host "  - Completed tasks [x] do NOT roll over"
    Write-Host ""
}

function Show-WorkHelpFolders {
    Write-Host ""
    Write-Host "  FOLDER STRUCTURE" -ForegroundColor Yellow
    Write-Host "  -----------------"
    Write-Host ""
    Write-Host "  ~/work/"
    Write-Host "  |-- 00_inbox/      Quick capture, unstructured notes"
    Write-Host "  |-- 01_today/      Daily notes (YYYY-MM-DD.md)"
    Write-Host "  |-- 02_projects/   One folder per project"
    Write-Host "  |   +-- project-name/"
    Write-Host "  |       |-- overview.md"
    Write-Host "  |       |-- tasks.md"
    Write-Host "  |       |-- decisions.md"
    Write-Host "  |       |-- notes.md"
    Write-Host "  |       +-- risks.md"
    Write-Host "  |-- 03_people/     One file per person (name.md)"
    Write-Host "  |-- 04_meetings/   Meeting notes (YYYY-MM-DD-slug.md)"
    Write-Host "  |-- 05_process/    Playbooks, SOPs, how-tos"
    Write-Host "  |-- 06_reference/  Stable reference material"
    Write-Host "  |-- 07_logs/       Weekly/monthly reflection logs"
    Write-Host "  |-- 08_templates/  Note templates"
    Write-Host "  +-- 99_archive/    Completed/inactive items"
    Write-Host ""
}

function Show-WorkHelpTips {
    Write-Host ""
    Write-Host "  TIPS & BEST PRACTICES" -ForegroundColor Yellow
    Write-Host "  ----------------------"
    Write-Host ""
    Write-Host "  FOCUS" -ForegroundColor Cyan
    Write-Host "  - Limit Focus to 3 items max"
    Write-Host "  - Everything else goes in Tasks"
    Write-Host ""
    Write-Host "  CAPTURE" -ForegroundColor Cyan
    Write-Host "  - Use 'wi' (inbox) for quick dumps"
    Write-Host "  - Don't overthink organization - just capture"
    Write-Host "  - Process inbox during downtime"
    Write-Host ""
    Write-Host "  LINKING" -ForegroundColor Cyan
    Write-Host "  - Link people from meetings: [Name](../03_people/name.md)"
    Write-Host "  - Link meetings from people files"
    Write-Host "  - In Neovim: <Space>wil inserts a person link"
    Write-Host ""
    Write-Host "  MAINTENANCE" -ForegroundColor Cyan
    Write-Host "  - Archive completed projects to 99_archive/"
    Write-Host "  - Weekly review: create 07_logs/YYYY-WNN.md"
    Write-Host "  - Keep active folders clean"
    Write-Host ""
    Write-Host "  NAMING" -ForegroundColor Cyan
    Write-Host "  - Dates: YYYY-MM-DD"
    Write-Host "  - Files: lowercase-with-dashes"
    Write-Host "  - People: firstname-lastname.md"
    Write-Host ""
}

function Show-WorkHelpMenu {
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║         WORK NOTES SYSTEM HELP           ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Usage: wh [topic]" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  TOPICS" -ForegroundColor Yellow
    Write-Host "  -------"
    Write-Host "  wh              Show this menu"
    Write-Host "  wh commands     List all available commands"
    Write-Host "  wh workflow     Daily workflow guide"
    Write-Host "  wh folders      Folder structure explanation"
    Write-Host "  wh tips         Tips and best practices"
    Write-Host "  wh all          Show everything"
    Write-Host ""
    Write-Host "  QUICK START" -ForegroundColor Yellow
    Write-Host "  ------------"
    Write-Host "  wt              Open today's note"
    Write-Host "  ws              Search all notes"
    Write-Host "  wnm `"title`"     Create meeting note"
    Write-Host "  wnp `"name`"      Create project"
    Write-Host "  wne `"name`"      Create person file"
    Write-Host ""
    Write-Host "  Full documentation: ~/work-system/USAGE.md" -ForegroundColor DarkGray
    Write-Host ""
}

function Show-WorkHelp {
    param([Parameter(Position=0)][string]$Topic)
    
    switch ($Topic.ToLower()) {
        "commands" { Show-WorkHelpCommands }
        "workflow" { Show-WorkHelpWorkflow }
        "folders"  { Show-WorkHelpFolders }
        "tips"     { Show-WorkHelpTips }
        "all" {
            Show-WorkHelpCommands
            Show-WorkHelpWorkflow
            Show-WorkHelpFolders
            Show-WorkHelpTips
        }
        default { Show-WorkHelpMenu }
    }
}
Set-Alias -Name wh -Value Show-WorkHelp
