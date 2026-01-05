<#
.SYNOPSIS
    Creates a new meeting note file.
.DESCRIPTION
    Creates a meeting file in 04_meetings/ with format YYYY-MM-DD-<slug>.md
.EXAMPLE
    ./New-Meeting.ps1 standup
    ./New-Meeting.ps1 "1on1 Alex"
    ./New-Meeting.ps1 -Title "project kickoff" -Date "2025-04-01"
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Title,
    
    [string]$Date = (Get-Date -Format "yyyy-MM-dd")
)

$WorkRoot = Join-Path $HOME "work"
$MeetingsDir = Join-Path $WorkRoot "04_meetings"
$TemplateDir = Join-Path $WorkRoot "08_templates"
$PeopleDir = Join-Path $WorkRoot "03_people"

# Ensure meetings directory exists
if (-not (Test-Path $MeetingsDir)) {
    New-Item -ItemType Directory -Path $MeetingsDir -Force | Out-Null
}

# Create slug from title
$slug = $Title.ToLower() -replace '[^a-z0-9]+', '-' -replace '^-|-$', ''
$filename = "$Date-$slug.md"
$filepath = Join-Path $MeetingsDir $filename

if (Test-Path $filepath) {
    Write-Host "Meeting already exists: $filepath" -ForegroundColor Yellow
    & nvim $filepath
    exit
}

# Get list of people for quick reference
$people = @()
if (Test-Path $PeopleDir) {
    $people = Get-ChildItem -Path $PeopleDir -Filter "*.md" | 
        ForEach-Object { $_.BaseName }
}

# Build template
$templatePath = Join-Path $TemplateDir "meeting.md"
$template = @"
# $Title

**Date:** $Date  
**Attendees:** 

## Agenda
- 

## Notes
- 

## Action Items
- [ ] 

## Follow-ups
- [ ] 
"@

if (Test-Path $templatePath) {
    $template = (Get-Content $templatePath -Raw) `
        -replace '\{\{title\}\}', $Title `
        -replace '\{\{date\}\}', $Date
}

# Write with Unix line endings
$unixContent = $template -replace "`r`n", "`n" -replace "`r", "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($filepath, $unixContent, $utf8NoBom)

Write-Host "Created: $filepath" -ForegroundColor Green

if ($people.Count -gt 0) {
    Write-Host "People: $($people -join ', ')" -ForegroundColor DarkGray
    Write-Host "Link format: [Name](../03_people/name.md)" -ForegroundColor DarkGray
}

& nvim $filepath
