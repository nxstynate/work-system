<#
.SYNOPSIS
    Creates a new project directory with standard files.
.DESCRIPTION
    Creates project folder in 02_projects/ with overview, tasks, decisions, notes, and risks files.
.EXAMPLE
    ./New-Project.ps1 "pipeline-migration"
    ./New-Project.ps1 -Name "q2-renders" -Open
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Name,
    
    [switch]$Open
)

$WorkRoot = Join-Path $HOME "work"
$ProjectsDir = Join-Path $WorkRoot "02_projects"
$TemplateDir = Join-Path $WorkRoot "08_templates"

# Create slug from name
$slug = $Name.ToLower() -replace '[^a-z0-9]+', '-' -replace '^-|-$', ''
$projectPath = Join-Path $ProjectsDir $slug

if (Test-Path $projectPath) {
    Write-Host "Project already exists: $projectPath" -ForegroundColor Yellow
    if ($Open) {
        & nvim (Join-Path $projectPath "overview.md")
    }
    exit
}

# Create project directory
New-Item -ItemType Directory -Path $projectPath -Force | Out-Null

$today = Get-Date -Format "yyyy-MM-dd"
$displayName = (Get-Culture).TextInfo.ToTitleCase($Name)

# Create project files
$files = @{
    "overview.md" = @"
# $displayName

**Created:** $today  
**Status:** Active  
**Owner:** 

## Summary


## Goals
- 

## Scope


## Timeline


## Links
- 
"@
    "tasks.md" = @"
# $displayName — Tasks

## Active
- [ ] 

## Backlog
- [ ] 

## Completed
- [x] 
"@
    "decisions.md" = @"
# $displayName — Decisions

## $today
**Decision:** 
**Context:** 
**Outcome:** 
"@
    "notes.md" = @"
# $displayName — Notes

## $today
- 
"@
    "risks.md" = @"
# $displayName — Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
|      |            |        |            |
"@
}

foreach ($file in $files.GetEnumerator()) {
    $filePath = Join-Path $projectPath $file.Key
    $file.Value | Set-Content -Path $filePath -NoNewline
}

Write-Host "Created project: $projectPath" -ForegroundColor Green
Write-Host "  - overview.md" -ForegroundColor DarkGray
Write-Host "  - tasks.md" -ForegroundColor DarkGray
Write-Host "  - decisions.md" -ForegroundColor DarkGray
Write-Host "  - notes.md" -ForegroundColor DarkGray
Write-Host "  - risks.md" -ForegroundColor DarkGray

if ($Open) {
    & nvim (Join-Path $projectPath "overview.md")
}
