# Work Notes System — Usage Guide

This guide explains how to use the work notes system day-to-day.

---

## Daily Workflow

### Start of Day

1. **Open today's note** with `wt` (PowerShell), `<Space>wt` (Neovim), or `Ctrl+T, w, t` (WezTerm)
2. The system automatically:
   - Creates today's note if it doesn't exist
   - Rolls over incomplete tasks from yesterday (Focus → Focus, Tasks → Tasks, Follow-ups → Follow-ups)
3. **Review rolled-over items** and prioritize your Focus items (top 3 priorities)
4. **Check your calendar** and add any meetings to the Meetings section

### During the Day

- **Capture quick thoughts** in the Notes section of today's file
- **Track tasks** as they come up — add them to Tasks with `- [ ]`
- **Log meetings** as they happen:
  - Quick notes: add to today's Meetings section
  - Detailed notes: create a meeting file with `wnm "meeting name"`
- **Mark tasks complete** by changing `- [ ]` to `- [x]`

### End of Day

- Review your note — anything incomplete will roll over tomorrow
- Move any completed projects to `99_archive/`
- No need to close or save anything special — just close Neovim

---

## Folder Structure

```
~/work/
├── 00_inbox/      # Quick capture, dump anything here
├── 01_today/      # Daily notes (YYYY-MM-DD.md)
├── 02_projects/   # One folder per project
├── 03_people/     # One file per person
├── 04_meetings/   # Meeting notes (YYYY-MM-DD-slug.md)
├── 05_process/    # Playbooks, SOPs, how-tos
├── 06_reference/  # Stable reference material
├── 07_logs/       # Weekly/monthly reflection logs
├── 08_templates/  # Note templates
└── 99_archive/    # Completed/inactive items
```

---

## Working with Daily Notes

### The Daily Note Template

```markdown
# 2025-01-06

## Focus
- [ ] Top priority #1
- [ ] Top priority #2
- [ ] Top priority #3

## Meetings
- 10:00 Standup
- 14:00 1:1 with Alex

## Tasks
- [ ] Review PR
- [ ] Send invoice

## Notes
- Random thought or observation

## Follow-ups
- [ ] Check back with client on Friday
```

### Task Rollover

Incomplete tasks roll over to the next day **within their section**:
- Focus items stay in Focus
- Tasks stay in Tasks
- Follow-ups stay in Follow-ups

Completed tasks (`- [x]`) do NOT roll over.

---

## Working with Projects

### Create a Project

```
wnp "project-name"
```

This creates a folder with:
- `overview.md` — Summary, goals, scope, timeline
- `tasks.md` — Active, backlog, and completed tasks
- `decisions.md` — Decision log with context
- `notes.md` — Running notes
- `risks.md` — Risk register

### Browse Projects

```
wp
```

Opens Telescope to find and open project files.

---

## Working with People

### Create a Person File

```
wne "Alex Chen"
```

Creates `~/work/03_people/alex-chen.md` with sections for:
- Role and context
- Strengths and areas to support
- 1:1 notes (dated)
- Follow-ups
- Meeting history (links)

### Browse People

```
we
```

### Link People in Meetings

In a meeting note, link to people like this:

```markdown
**Attendees:** [Alex](../03_people/alex-chen.md), [Jordan](../03_people/jordan.md)
```

In Neovim, use `<Space>wil` to insert a person link at your cursor.

---

## Working with Meetings

### Quick Meeting Note

Add to today's daily note under `## Meetings`:

```markdown
## Meetings
- 10:00 Standup — discussed blockers, Alex taking point on API
- 14:00 1:1 Jordan — see [[../04_meetings/2025-01-06-1on1-jordan.md]]
```

### Detailed Meeting Note

Create a dedicated meeting file:

```
wnm "1on1 Jordan"
```

Creates `~/work/04_meetings/2025-01-06-1on1-jordan.md`

### Browse Meetings

```
wm
```

---

## Working with Logs

Logs are for daily journaling and progress tracking — separate from your task-focused daily notes.

### Create Today's Log

```
wng
```

Creates `~/work/07_logs/2025-01-06.md` with sections for:
- Summary
- Progress
- Accomplishments
- Challenges
- Tomorrow
- Notes

### When to Use Logs vs Daily Notes

- **Daily Notes (`wt`)**: Task management, meetings, action items
- **Logs (`wng`)**: Reflection, progress tracking, journaling

### Weekly Logs

You can also create weekly summary logs manually:
- `~/work/07_logs/2025-W01.md` for week 1 of 2025

---

## Searching

### Search Content (ripgrep)

```
ws "search term"
```

Returns matching lines across all markdown files.

### Search Interactively (Telescope)

```
ws
```

Opens Telescope live grep — type to search, results update live.

### Find Files

```
wf
```

Opens Telescope file finder for the entire work directory.

---

## Command Reference

### Browse Commands

| Command | Description |
|---------|-------------|
| `wt` | Open today's daily note |
| `wi` | Open inbox folder |
| `ws [query]` | Search notes (ripgrep if query provided, Telescope if not) |
| `wf` | Find files (Telescope) |
| `wp` | Browse projects |
| `we` | Browse people |
| `wm` | Browse meetings |
| `wl [n]` | List recent n daily notes (default 7) |
| `wd [n]` | Open note from n days ago (0=today, 1=yesterday) |

### Create Commands

| Command | Description |
|---------|-------------|
| `wnm [title]` | Create new meeting note |
| `wnp [name]` | Create new project |
| `wne [name]` | Create new person file |
| `wng` | Create new daily log entry |

### Utility Commands

| Command | Description |
|---------|-------------|
| `cdw` | Change directory to work root |
| `wh` | Show help menu |

---

## Keybinding Reference

### PowerShell
Commands are typed directly: `wt`, `ws`, `wnm "title"`, etc.

### Neovim
Leader is `<Space>`. Commands follow the pattern `<Space>w` + key:
- `<Space>wt` — Today
- `<Space>ws` — Search
- `<Space>wnm` — New meeting
- `<Space><Space>` — Quick access to today

### WezTerm
Leader is `Ctrl+T`. Commands follow the pattern `Ctrl+T, w` + key:
- `Ctrl+T, w, t` — Today
- `Ctrl+T, w, s` — Search
- `Ctrl+T, w, n, m` — New meeting

---

## Tips & Best Practices

### Keep Focus Small
Limit Focus to 3 items. If you have more, they go in Tasks.

### Use Inbox Liberally
Dump anything into `00_inbox/` — process it later. Don't let capture friction stop you.

### Link Generously
Link between files to build a knowledge graph:
- Link people from meetings
- Link meetings from people
- Link projects from daily notes

### Archive Aggressively
Move completed projects to `99_archive/`. Keep your active folders clean.

### Review Weekly
Create a file in `07_logs/` like `2025-W01.md` for weekly reflections.

### Use Consistent Naming
- Dates: `YYYY-MM-DD`
- Slugs: `lowercase-with-dashes`
- People: `firstname-lastname.md`

---

## Troubleshooting

### Tasks Rolling to Wrong Section
Each section rolls over independently. Make sure your daily template has the correct section headers (`## Focus`, `## Tasks`, `## Follow-ups`).

### ^M Characters Appearing
This is a line-ending issue. The system uses Unix line endings (LF). If you see `^M`, run in Neovim:
```
:set ff=unix
:w
```

### Telescope Not Focusing
If Telescope opens but cursor is stuck, ensure you're using the latest work-system scripts which use `vim.schedule()` for proper initialization.

---

## Getting Help

- `wh` — Show interactive help menu
- `wh commands` — List all commands
- `wh workflow` — Show daily workflow
- `wh folders` — Show folder structure
