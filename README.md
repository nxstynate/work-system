# Work Notes System

A markdown-first, keyboard-driven work organization system for Neovim + WezTerm + PowerShell + GlazeWM.

## Quick Start

### 1. Copy files to your system

```powershell
# Clone or copy work-system to your home directory
cp -r work-system ~/work-system

# Initialize the work directory structure
pwsh ~/work-system/scripts/Open-Today.ps1 -NoEdit
```

### 2. Configure PowerShell

Add to your `$PROFILE`:

```powershell
# Work notes system
. ~/work-system/scripts/Work-Functions.ps1
```

### 3. Configure Neovim

Add to your `init.lua`:

```lua
-- Add work system to runtimepath
vim.opt.runtimepath:append(vim.fn.expand("$HOME/work-system/nvim"))

-- Load and setup work keybindings
require("work").setup()
```

### 4. Configure WezTerm

In your `wezterm.lua`:

```lua
-- Load work system keybindings
package.path = package.path .. ";" .. wezterm.home_dir .. "/work-system/wezterm/?.lua"
local work = require("wezterm-work")

-- Ensure leader is set (Ctrl+T)
config.leader = { key = "t", mods = "CTRL", timeout_milliseconds = 2000 }

-- Merge work keys into your config
config.keys = config.keys or {}
for _, key in ipairs(work.keys) do
    table.insert(config.keys, key)
end

-- Merge key tables
config.key_tables = config.key_tables or {}
for name, tbl in pairs(work.key_tables) do
    config.key_tables[name] = tbl
end
```

### 5. Configure GlazeWM

Merge contents of `glazewm-work.yaml` into your `~/.glaze-wm/config.yaml`.

## Directory Structure

```
~/work/
├── 00_inbox/        # Quick capture, unstructured
├── 01_today/        # Daily notes (YYYY-MM-DD.md)
├── 02_projects/     # Project folders
│   └── project-name/
│       ├── overview.md
│       ├── tasks.md
│       ├── decisions.md
│       ├── notes.md
│       └── risks.md
├── 03_people/       # Person files (name.md)
├── 04_meetings/     # Meeting notes (YYYY-MM-DD-slug.md)
├── 05_process/      # Playbooks, SOPs
├── 06_reference/    # Stable reference docs
├── 07_logs/         # Monthly/weekly logs
├── 08_templates/    # Note templates
└── 99_archive/      # Completed/inactive items
```

## Unified Keybindings

All three tools use the same key sequences after their respective leader/prefix:

| Action      | PowerShell | Neovim       | WezTerm          |
|-------------|------------|--------------|------------------|
| Today       | `wt`       | `<Space>wt`  | `Ctrl+T, w, t`   |
| Inbox       | `wi`       | `<Space>wi`  | `Ctrl+T, w, i`   |
| Search      | `ws`       | `<Space>ws`  | `Ctrl+T, w, s`   |
| Find files  | `wf`       | `<Space>wf`  | `Ctrl+T, w, f`   |
| Projects    | `wp`       | `<Space>wp`  | `Ctrl+T, w, p`   |
| People      | `we`       | `<Space>we`  | `Ctrl+T, w, e`   |
| Meetings    | `wm`       | `<Space>wm`  | `Ctrl+T, w, m`   |
| Recent      | `wl`       | `<Space>wl`  | `Ctrl+T, w, l`   |
| New meeting | `wnm`      | `<Space>wnm` | `Ctrl+T, w, n, m`|
| New project | `wnp`      | `<Space>wnp` | `Ctrl+T, w, n, p`|
| New person  | `wne`      | `<Space>wne` | `Ctrl+T, w, n, e`|
| Help        | `wh`       | —            | `Ctrl+T, w, h`   |

### PowerShell-only Commands

| Alias | Description |
|-------|-------------|
| `wd [n]` | Open note n days ago (0=today, 1=yesterday) |
| `cdw` | CD to work root |

### Neovim-only Commands

| Mapping | Description |
|---------|-------------|
| `<Space><Space>` | Quick access to today's note |
| `<Space>wil` | Insert person link at cursor |

### GlazeWM Workspaces

| Workspace | Key | Purpose |
|-----------|-----|---------|
| 1 | `Alt+1` / `Alt+N` | Notes/Neovim |
| 2 | `Alt+2` / `Alt+T` | Teams |
| 3 | `Alt+3` / `Alt+E` | Outlook |
| 4 | `Alt+4` / `Alt+B` | Browser |
| 5 | `Alt+5` | Files |
| 6 | `Alt+6` | Project |
| 7 | `Alt+7` / `Alt+R` | Render/Blender |

## Task Rollover

When you open today's note (via any method), incomplete tasks from the previous day automatically roll forward:

```
Yesterday (2025-03-29.md):
- [x] Review renders
- [ ] Send feedback to Tron   ← incomplete
- [ ] Update timeline          ← incomplete

Today (2025-03-30.md) is created with:
## Tasks
- [ ] Send feedback to Tron   ← rolled over
- [ ] Update timeline          ← rolled over
- [ ] 
```

## Linking

### People from Meetings

```markdown
# Standup

**Attendees:** [Tron](../03_people/Tron.md), [Tron](../03_people/Tron.md)
```

### Meetings from People

```markdown
## Meeting History
- [2025-03-30 Standup](../04_meetings/2025-03-30-standup.md)
- [2025-03-28 1on1](../04_meetings/2025-03-28-1on1-Tron.md)
```

## Searching

From any tool, use `ws` (with appropriate prefix) to search all notes.

From terminal with ripgrep:
```powershell
ws "render pipeline"       # PowerShell alias
rg -i "render" ~/work      # Direct ripgrep
```

## Templates

Templates live in `~/work/08_templates/`. The system uses these placeholders:
- `{{date}}` - Current date (YYYY-MM-DD)
- `{{title}}` - Meeting title
- `{{name}}` - Person/project name

## Customization

### Change work root

Edit these files:
- `scripts/*.ps1` → `$WorkRoot`
- `nvim/work.lua` → `M.work_root`
- `wezterm/wezterm-work.lua` → `work_root`

### Extend the system

The PowerShell scripts are standalone—modify or add new ones to `scripts/`.
