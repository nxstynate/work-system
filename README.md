# Work Notes System

A markdown-first, keyboard-driven work organization system for Neovim + WezTerm + PowerShell.

## Installation

### 1. Copy to your system

```powershell
# Copy work-system to your home directory
Copy-Item -Recurse work-system ~/work-system

# Initialize the work directory structure
pwsh ~/work-system/scripts/Open-Today.ps1 -NoEdit
```

### 2. Configure PowerShell

Add to your `$PROFILE`:

```powershell
. ~/work-system/scripts/Work-Functions.ps1
```

### 3. Configure Neovim

Add to your `init.lua`:

```lua
vim.opt.runtimepath:append(vim.fn.expand("$HOME/work-system/nvim"))
require("work").setup()
```

### 4. Configure WezTerm (optional)

Add to your `wezterm.lua`:

```lua
require("nxstynate.work").apply(config)
```

Place `wezterm/work.lua` in your WezTerm config folder (e.g., `nxstynate/work.lua`).

## Quick Start

After installation, reload your shell and try:

```powershell
wt          # Open today's note
wh          # Show help menu
wh commands # List all commands
wh workflow # Daily workflow guide
```

## Commands

| Command | Description |
|---------|-------------|
| `wt` | Open today's note |
| `ws` | Search notes |
| `wp` | Browse projects |
| `we` | Browse people |
| `wm` | Browse meetings |
| `wnm "title"` | New meeting |
| `wnp "name"` | New project |
| `wne "name"` | New person |
| `wng` | New daily log |
| `wh` | Show help |

## Keybindings

All tools use the same pattern after their leader key:

| Action | PowerShell | Neovim | WezTerm |
|--------|------------|--------|---------|
| Today | `wt` | `<Space>wt` | `Ctrl+T, w, t` |
| Search | `ws` | `<Space>ws` | `Ctrl+T, w, s` |
| Projects | `wp` | `<Space>wp` | `Ctrl+T, w, p` |
| People | `we` | `<Space>we` | `Ctrl+T, w, e` |
| Meetings | `wm` | `<Space>wm` | `Ctrl+T, w, m` |
| New meeting | `wnm` | `<Space>wnm` | `Ctrl+T, w, n, m` |
| New log | `wng` | `<Space>wng` | `Ctrl+T, w, n, g` |

## Directory Structure

```
~/work/
├── 00_inbox/      # Quick capture
├── 01_today/      # Daily notes
├── 02_projects/   # Project folders
├── 03_people/     # People files
├── 04_meetings/   # Meeting notes
├── 05_process/    # Playbooks
├── 06_reference/  # Reference docs
├── 07_logs/       # Weekly logs
├── 08_templates/  # Templates
└── 99_archive/    # Archive
```

## Documentation

- **USAGE.md** — Detailed usage guide, workflows, and tips
- **wh** — Interactive help in terminal

## Features

- **Task Rollover**: Incomplete tasks automatically roll to the next day (within their sections)
- **Unified Keybindings**: Same patterns across PowerShell, Neovim, and WezTerm
- **Markdown-first**: Plain text files, no database, works offline
- **Searchable**: ripgrep and Telescope integration
