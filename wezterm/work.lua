-- work.lua
-- WezTerm keybindings for work notes system
-- Uses multi-character sequences matching Neovim and PowerShell
--
-- Usage in init.lua:
--   require("nxstynate.work").apply(config)

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- Work system paths
local home = wezterm.home_dir
local work_root = home .. "/work"
local scripts = home .. "/work-system/scripts"

function M.apply(config)
    -- ============================================
    -- KEY TABLES FOR MULTI-CHARACTER SEQUENCES
    -- ============================================

    config.key_tables = config.key_tables or {}

    -- Main work key table (activated by Ctrl+T, w)
    config.key_tables.work = {
        -- wt - Today's note
        {
            key = "t",
            action = wezterm.action_callback(function(window, pane)
                window:perform_action(
                    act.SpawnCommandInNewTab({
                        args = { "pwsh", "-NoProfile", "-File", scripts .. "/Open-Today.ps1" },
                        cwd = work_root,
                    }),
                    pane
                )
                local tab = window:active_tab()
                if tab then
                    tab:set_title("TODAY")
                end
            end),
        },

        -- wi - Inbox
        {
            key = "i",
            action = wezterm.action_callback(function(window, pane)
                window:perform_action(
                    act.SpawnCommandInNewTab({
                        args = { "pwsh", "-NoProfile", "-Command",
                            string.format("cd '%s/00_inbox'; nvim .", work_root)
                        },
                    }),
                    pane
                )
                local tab = window:active_tab()
                if tab then
                    tab:set_title("INBOX")
                end
            end),
        },

        -- ws - Search notes
        {
            key = "s",
            action = wezterm.action_callback(function(window, pane)
                window:perform_action(
                    act.SpawnCommandInNewTab({
                        args = { "pwsh", "-NoProfile", "-Command",
                            string.format("cd '%s'; nvim -c 'Telescope live_grep'", work_root)
                        },
                    }),
                    pane
                )
                local tab = window:active_tab()
                if tab then
                    tab:set_title("SEARCH")
                end
            end),
        },

        -- wf - Find files
        {
            key = "f",
            action = wezterm.action_callback(function(window, pane)
                window:perform_action(
                    act.SpawnCommandInNewTab({
                        args = { "pwsh", "-NoProfile", "-Command",
                            string.format("cd '%s'; nvim -c 'Telescope find_files'", work_root)
                        },
                    }),
                    pane
                )
                local tab = window:active_tab()
                if tab then
                    tab:set_title("FILES")
                end
            end),
        },

        -- wp - Projects
        {
            key = "p",
            action = wezterm.action_callback(function(window, pane)
                window:perform_action(
                    act.SpawnCommandInNewTab({
                        args = { "pwsh", "-NoProfile", "-Command",
                            string.format("cd '%s/02_projects'; nvim -c 'Telescope find_files'", work_root)
                        },
                    }),
                    pane
                )
                local tab = window:active_tab()
                if tab then
                    tab:set_title("PROJECTS")
                end
            end),
        },

        -- we - People
        {
            key = "e",
            action = wezterm.action_callback(function(window, pane)
                window:perform_action(
                    act.SpawnCommandInNewTab({
                        args = { "pwsh", "-NoProfile", "-Command",
                            string.format("cd '%s/03_people'; nvim -c 'Telescope find_files'", work_root)
                        },
                    }),
                    pane
                )
                local tab = window:active_tab()
                if tab then
                    tab:set_title("PEOPLE")
                end
            end),
        },

        -- wm - Meetings
        {
            key = "m",
            action = wezterm.action_callback(function(window, pane)
                window:perform_action(
                    act.SpawnCommandInNewTab({
                        args = { "pwsh", "-NoProfile", "-Command",
                            string.format("cd '%s/04_meetings'; nvim -c 'Telescope find_files'", work_root)
                        },
                    }),
                    pane
                )
                local tab = window:active_tab()
                if tab then
                    tab:set_title("MEETINGS")
                end
            end),
        },

        -- wl - Recent daily notes
        {
            key = "l",
            action = wezterm.action_callback(function(window, pane)
                window:perform_action(
                    act.SpawnCommandInNewTab({
                        args = { "pwsh", "-NoProfile", "-Command",
                            string.format("cd '%s/01_today'; nvim -c 'Telescope find_files'", work_root)
                        },
                    }),
                    pane
                )
                local tab = window:active_tab()
                if tab then
                    tab:set_title("RECENT")
                end
            end),
        },

        -- wn - Enter "new" submenu
        {
            key = "n",
            action = act.ActivateKeyTable({
                name = "work_new",
                one_shot = true,
                timeout_milliseconds = 2000,
            }),
        },

        -- wh - Help (show keybindings)
        {
            key = "h",
            action = wezterm.action_callback(function(window, pane)
                window:perform_action(
                    act.SpawnCommandInNewTab({
                        args = { "pwsh", "-NoProfile", "-Command", [[
Write-Host ""
Write-Host "Work Notes System - WezTerm Bindings" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Browse (Ctrl+T, w, ...):" -ForegroundColor Yellow
Write-Host "  t    Today's note"
Write-Host "  i    Inbox"
Write-Host "  s    Search notes"
Write-Host "  f    Find files"
Write-Host "  p    Projects"
Write-Host "  e    People"
Write-Host "  m    Meetings"
Write-Host "  l    Recent daily notes"
Write-Host ""
Write-Host "Create (Ctrl+T, w, n, ...):" -ForegroundColor Yellow
Write-Host "  m    New meeting"
Write-Host "  p    New project"
Write-Host "  e    New person"
Write-Host ""
Read-Host "Press Enter to close"
]] },
                    }),
                    pane
                )
                local tab = window:active_tab()
                if tab then
                    tab:set_title("HELP")
                end
            end),
        },

        -- Escape to cancel
        {
            key = "Escape",
            action = act.PopKeyTable,
        },
    }

    -- "New" submenu (activated by wn)
    config.key_tables.work_new = {
        -- wnm - New meeting
        {
            key = "m",
            action = act.PromptInputLine({
                description = "Meeting title:",
                action = wezterm.action_callback(function(window, pane, line)
                    if line and line ~= "" then
                        window:perform_action(
                            act.SpawnCommandInNewTab({
                                args = { "pwsh", "-NoProfile", "-File",
                                    scripts .. "/New-Meeting.ps1", "-Title", line },
                                cwd = work_root,
                            }),
                            pane
                        )
                        wezterm.time.call_after(0.1, function()
                            local tab = window:active_tab()
                            if tab then
                                tab:set_title("MEETING")
                            end
                        end)
                    end
                end),
            }),
        },

        -- wnp - New project
        {
            key = "p",
            action = act.PromptInputLine({
                description = "Project name:",
                action = wezterm.action_callback(function(window, pane, line)
                    if line and line ~= "" then
                        window:perform_action(
                            act.SpawnCommandInNewTab({
                                args = { "pwsh", "-NoProfile", "-File",
                                    scripts .. "/New-Project.ps1", "-Name", line, "-Open" },
                                cwd = work_root,
                            }),
                            pane
                        )
                        wezterm.time.call_after(0.1, function()
                            local tab = window:active_tab()
                            if tab then
                                tab:set_title("PROJECT")
                            end
                        end)
                    end
                end),
            }),
        },

        -- wne - New person
        {
            key = "e",
            action = act.PromptInputLine({
                description = "Person name:",
                action = wezterm.action_callback(function(window, pane, line)
                    if line and line ~= "" then
                        window:perform_action(
                            act.SpawnCommandInNewTab({
                                args = { "pwsh", "-NoProfile", "-File",
                                    scripts .. "/New-Person.ps1", "-Name", line },
                                cwd = work_root,
                            }),
                            pane
                        )
                        wezterm.time.call_after(0.1, function()
                            local tab = window:active_tab()
                            if tab then
                                tab:set_title("PERSON")
                            end
                        end)
                    end
                end),
            }),
        },

        -- Escape to cancel
        {
            key = "Escape",
            action = act.PopKeyTable,
        },
    }

    -- ============================================
    -- ADD WORK ENTRY POINT TO LEADER KEYS
    -- ============================================

    -- Entry point: Ctrl+T, w activates the work key table
    -- Note: You'll need to move your existing LEADER+w binding (workspace launcher) to a different key
    table.insert(config.keys, {
        key = "w",
        mods = "LEADER",
        action = act.ActivateKeyTable({
            name = "work",
            one_shot = true,
            timeout_milliseconds = 2000,
        }),
    })
end

return M

--[[
INTEGRATION:

In your init.lua, add this line alongside your other requires:

    require("nxstynate.work").apply(config)

Place the work.lua file in your nxstynate folder:

    ~/pro-env/files/wezterm/nxstynate/work.lua


NOTE ON KEY CONFLICT:

Your keys.lua uses LEADER+w for ShowLauncherArgs({ flags = "WORKSPACES" }).
You'll need to move that binding to a different key (e.g., LEADER+SHIFT+w).


KEYBINDING SUMMARY (all start with Ctrl+T, w):

  Browse:
    Ctrl+T, w, t    Today's note     -> tab: TODAY
    Ctrl+T, w, i    Inbox            -> tab: INBOX
    Ctrl+T, w, s    Search notes     -> tab: SEARCH
    Ctrl+T, w, f    Find files       -> tab: FILES
    Ctrl+T, w, p    Projects         -> tab: PROJECTS
    Ctrl+T, w, e    People           -> tab: PEOPLE
    Ctrl+T, w, m    Meetings         -> tab: MEETINGS
    Ctrl+T, w, l    Recent daily     -> tab: RECENT
    Ctrl+T, w, h    Help             -> tab: HELP

  Create (Ctrl+T, w, n, ...):
    Ctrl+T, w, n, m    New meeting   -> tab: MEETING
    Ctrl+T, w, n, p    New project   -> tab: PROJECT
    Ctrl+T, w, n, e    New person    -> tab: PERSON


UNIFIED SCHEME:

  | Action      | PowerShell | Neovim      | WezTerm         |
  |-------------|------------|-------------|-----------------|
  | Today       | wt         | <Space>wt   | Ctrl+T, w, t    |
  | Inbox       | wi         | <Space>wi   | Ctrl+T, w, i    |
  | Search      | ws         | <Space>ws   | Ctrl+T, w, s    |
  | Find        | wf         | <Space>wf   | Ctrl+T, w, f    |
  | Projects    | wp         | <Space>wp   | Ctrl+T, w, p    |
  | People      | we         | <Space>we   | Ctrl+T, w, e    |
  | Meetings    | wm         | <Space>wm   | Ctrl+T, w, m    |
  | Recent      | wl         | <Space>wl   | Ctrl+T, w, l    |
  | New meeting | wnm        | <Space>wnm  | Ctrl+T, w, n, m |
  | New project | wnp        | <Space>wnp  | Ctrl+T, w, n, p |
  | New person  | wne        | <Space>wne  | Ctrl+T, w, n, e |

]]
