<#
.SYNOPSIS
    Creates a new person file for 1:1s and people management.
.DESCRIPTION
    Creates a person file in 03_people/ with standard sections.
.EXAMPLE
    ./New-Person.ps1 "Tron"
    ./New-Person.ps1 -Name "Tron" -Role "Senior Artist"
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Name,
    
    [string]$Role = ""
)

$WorkRoot = Join-Path $HOME "work"
$PeopleDir = Join-Path $WorkRoot "03_people"

# Ensure people directory exists
if (-not (Test-Path $PeopleDir)) {
    New-Item -ItemType Directory -Path $PeopleDir -Force | Out-Null
}

# Create slug from name (first name or full slug)
$slug = $Name.ToLower() -replace '[^a-z0-9]+', '-' -replace '^-|-$', ''
$filename = "$slug.md"
$filepath = Join-Path $PeopleDir $filename

if (Test-Path $filepath) {
    Write-Host "Person file already exists: $filepath" -ForegroundColor Yellow
    & nvim $filepath
    exit
}

$displayName = (Get-Culture).TextInfo.ToTitleCase($Name)
$today = Get-Date -Format "yyyy-MM-dd"

$template = @"
# $displayName

**Role:** $Role  
**Started:** $today  

## Context


## Strengths
- 

## Areas to Support
- 

## Goals
- 

## 1:1 Notes

### $today
- 

## Follow-ups
- [ ] 

## Meeting History
<!-- Link to meetings: [Meeting Title](../04_meetings/YYYY-MM-DD-slug.md) -->
"@

$template | Set-Content -Path $filepath -NoNewline
Write-Host "Created: $filepath" -ForegroundColor Green

& nvim $filepath
