-- work.lua
-- Neovim configuration for work notes system
-- Add to your init.lua: require('work').setup()

local M = {}

-- Configuration
M.work_root = vim.fn.expand("$HOME/work")

-- Helper: ensure directory exists
local function ensure_dir(path)
    if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, "p")
    end
end

-- Helper: get today's date
local function today()
    return os.date("%Y-%m-%d")
end

-- ============================================
-- BROWSE COMMANDS
-- ============================================

-- wt - Open today's daily note (with rollover via PowerShell)
function M.open_today()
    local script = vim.fn.expand("$HOME/work-system/scripts/Open-Today.ps1")
    if vim.fn.filereadable(script) == 1 then
        vim.fn.system("pwsh -NoProfile -File " .. script .. " -NoEdit")
    end

    local today_dir = M.work_root .. "/01_today"
    ensure_dir(today_dir)
    local today_file = today_dir .. "/" .. today() .. ".md"
    vim.cmd("edit " .. today_file)
end

-- wi - Open inbox
function M.open_inbox()
    local inbox = M.work_root .. "/00_inbox"
    ensure_dir(inbox)
    vim.cmd("edit " .. inbox)
end

-- ws - Search work notes with Telescope
function M.search_notes()
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
        telescope.live_grep({
            cwd = M.work_root,
            prompt_title = "Search Work Notes",
        })
    else
        vim.ui.input({ prompt = "Search: " }, function(pattern)
            if pattern then
                vim.cmd("silent grep! " .. pattern .. " " .. M.work_root .. "/**/*.md")
                vim.cmd("copen")
            end
        end)
    end
end

-- wf - Find work files with Telescope
function M.find_files()
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
        telescope.find_files({
            cwd = M.work_root,
            prompt_title = "Work Files",
        })
    else
        vim.cmd("edit " .. M.work_root)
    end
end

-- wp - Browse projects
function M.browse_projects()
    local projects = M.work_root .. "/02_projects"
    ensure_dir(projects)
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
        telescope.find_files({
            cwd = projects,
            prompt_title = "Projects",
        })
    else
        vim.cmd("edit " .. projects)
    end
end

-- we - Browse people
function M.browse_people()
    local people = M.work_root .. "/03_people"
    ensure_dir(people)
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
        telescope.find_files({
            cwd = people,
            prompt_title = "People",
        })
    else
        vim.cmd("edit " .. people)
    end
end

-- wm - Browse meetings
function M.browse_meetings()
    local meetings = M.work_root .. "/04_meetings"
    ensure_dir(meetings)
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
        telescope.find_files({
            cwd = meetings,
            prompt_title = "Meetings",
            sorting_strategy = "descending",
        })
    else
        vim.cmd("edit " .. meetings)
    end
end

-- wl - List recent daily notes
function M.list_recent()
    local today_dir = M.work_root .. "/01_today"
    ensure_dir(today_dir)
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
        telescope.find_files({
            cwd = today_dir,
            prompt_title = "Recent Daily Notes",
            sorting_strategy = "descending",
        })
    else
        vim.cmd("edit " .. today_dir)
    end
end

-- ============================================
-- CREATE COMMANDS (wn*)
-- ============================================

-- wnm - Create new meeting
function M.new_meeting()
    vim.ui.input({ prompt = "Meeting title: " }, function(title)
        if title and title ~= "" then
            local slug = title:lower():gsub("[^a-z0-9]+", "-"):gsub("^-", ""):gsub("-$", "")
            local meetings = M.work_root .. "/04_meetings"
            ensure_dir(meetings)
            local filename = today() .. "-" .. slug .. ".md"
            local filepath = meetings .. "/" .. filename

            local template = string.format([[
# %s

**Date:** %s
**Attendees:**

## Agenda
-

## Notes
-

## Action Items
- [ ]

## Follow-ups
- [ ]
]], title, today())

            local file = io.open(filepath, "w")
            if file then
                file:write(template)
                file:close()
            end

            vim.cmd("edit " .. filepath)
        end
    end)
end

-- wnp - Create new project
function M.new_project()
    vim.ui.input({ prompt = "Project name: " }, function(name)
        if name and name ~= "" then
            local slug = name:lower():gsub("[^a-z0-9]+", "-"):gsub("^-", ""):gsub("-$", "")
            local project_path = M.work_root .. "/02_projects/" .. slug
            ensure_dir(project_path)

            local display_name = name:gsub("^%l", string.upper)
            local files = {
                ["overview.md"] = string.format([[
# %s

**Created:** %s
**Status:** Active
**Owner:**

## Summary


## Goals
-

## Scope


## Timeline


## Links
-
]], display_name, today()),
                ["tasks.md"] = string.format([[
# %s — Tasks

## Active
- [ ]

## Backlog
- [ ]

## Completed
- [x]
]], display_name),
                ["decisions.md"] = string.format([[
# %s — Decisions

## %s
**Decision:**
**Context:**
**Outcome:**
]], display_name, today()),
                ["notes.md"] = string.format([[
# %s — Notes

## %s
-
]], display_name, today()),
                ["risks.md"] = string.format([[
# %s — Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
|      |            |        |            |
]], display_name),
            }

            for filename, content in pairs(files) do
                local file = io.open(project_path .. "/" .. filename, "w")
                if file then
                    file:write(content)
                    file:close()
                end
            end

            vim.cmd("edit " .. project_path .. "/overview.md")
        end
    end)
end

-- wne - Create new person file
function M.new_person()
    vim.ui.input({ prompt = "Person name: " }, function(name)
        if name and name ~= "" then
            local slug = name:lower():gsub("[^a-z0-9]+", "-"):gsub("^-", ""):gsub("-$", "")
            local people = M.work_root .. "/03_people"
            ensure_dir(people)
            local filepath = people .. "/" .. slug .. ".md"

            local display_name = name:gsub("(%a)([%w_']*)", function(a, b) return a:upper() .. b end)
            local template = string.format([[
# %s

**Role:**
**Started:** %s

## Context


## Strengths
-

## Areas to Support
-

## Goals
-

## 1:1 Notes

### %s
-

## Follow-ups
- [ ]

## Meeting History
<!-- Link: [Title](../04_meetings/YYYY-MM-DD-slug.md) -->
]], display_name, today(), today())

            local file = io.open(filepath, "w")
            if file then
                file:write(template)
                file:close()
            end

            vim.cmd("edit " .. filepath)
        end
    end)
end

-- ============================================
-- UTILITY
-- ============================================

-- Insert person link at cursor
function M.insert_person_link()
    local people_dir = M.work_root .. "/03_people"
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
        telescope.find_files({
            cwd = people_dir,
            prompt_title = "Link Person",
            attach_mappings = function(_, map)
                map("i", "<CR>", function(prompt_bufnr)
                    local selection = require("telescope.actions.state").get_selected_entry()
                    require("telescope.actions").close(prompt_bufnr)
                    if selection then
                        local pname = selection.value:gsub("%.md$", "")
                        local display = pname:gsub("^%l", string.upper)
                        local link = string.format("[%s](../03_people/%s.md)", display, pname)
                        vim.api.nvim_put({ link }, "c", true, true)
                    end
                end)
                return true
            end,
        })
    end
end

-- ============================================
-- SETUP KEYMAPS
-- ============================================

function M.setup()
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Browse commands: <leader>w + key
    keymap("n", "<leader>wt", M.open_today, vim.tbl_extend("force", opts, { desc = "Today's note" }))
    keymap("n", "<leader>wi", M.open_inbox, vim.tbl_extend("force", opts, { desc = "Inbox" }))
    keymap("n", "<leader>ws", M.search_notes, vim.tbl_extend("force", opts, { desc = "Search notes" }))
    keymap("n", "<leader>wf", M.find_files, vim.tbl_extend("force", opts, { desc = "Find files" }))
    keymap("n", "<leader>wp", M.browse_projects, vim.tbl_extend("force", opts, { desc = "Projects" }))
    keymap("n", "<leader>we", M.browse_people, vim.tbl_extend("force", opts, { desc = "People" }))
    keymap("n", "<leader>wm", M.browse_meetings, vim.tbl_extend("force", opts, { desc = "Meetings" }))
    keymap("n", "<leader>wl", M.list_recent, vim.tbl_extend("force", opts, { desc = "Recent notes" }))

    -- Create commands: <leader>wn + key
    keymap("n", "<leader>wnm", M.new_meeting, vim.tbl_extend("force", opts, { desc = "New meeting" }))
    keymap("n", "<leader>wnp", M.new_project, vim.tbl_extend("force", opts, { desc = "New project" }))
    keymap("n", "<leader>wne", M.new_person, vim.tbl_extend("force", opts, { desc = "New person" }))

    -- Utility
    keymap("n", "<leader>wil", M.insert_person_link, vim.tbl_extend("force", opts, { desc = "Insert person link" }))
end

return M
