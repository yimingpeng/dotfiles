-- obsidian.nvim (community fork) for the PERSONAL vault on this Mac.
-- Test bench for the work-laptop config in the course folder (same keys, different vault path).
-- Previous version (epwalsh/obsidian.nvim) is in git history: `git checkout -- nvim/lua/plugins/obsidian.lua`
local vault = vim.fn.expand("~/My Drive (yimingpengjojo@gmail.com)/My_Notes")
-- Scripts live in this config (nvim/scripts/), so they travel with the dotfiles repo.
local bin = vim.fn.stdpath("config") .. "/scripts"

-- Run one of my scripts and load its `file:line:col:text` output into quickfix.
local function qf(script, ...)
  local res = vim.system({ bin .. "/" .. script, ... }, { env = { VAULT = vault }, text = true }):wait()
  local lines = vim.split(vim.trim(res.stdout or ""), "\n", { trimempty = true })
  if #lines == 0 then
    vim.notify(script .. ": nothing found", vim.log.levels.INFO)
    return
  end
  vim.fn.setqflist({}, " ", { title = script, lines = lines, efm = "%f:%l:%c:%m" })
  vim.cmd("copen")
end

-- Run a script and show its plain output in a notification (for timeblocks).
local function show(script, ...)
  local res = vim.system({ bin .. "/" .. script, ... }, { env = { VAULT = vault }, text = true }):wait()
  vim.notify(res.stdout ~= "" and res.stdout or res.stderr, vim.log.levels.INFO, { title = script })
end

local function obs(cmd)
  return "<cmd>Obsidian " .. cmd .. "<cr>"
end

local obsidian = {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = "markdown",
  cmd = "Obsidian",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ot", obs("today"), desc = "Today's daily note" },
    { "<leader>oy", obs("yesterday"), desc = "Yesterday's daily note" },
    { "<leader>oT", obs("tomorrow"), desc = "Tomorrow's daily note" },
    { "<leader>od", obs("dailies -7 0"), desc = "Last 7 daily notes (picker)" },
    { "<leader>on", obs("new_from_template"), desc = "New note from template" },
    { "<leader>oi", obs("template"), desc = "Insert template here" },
    { "<leader>oq", obs("quick_switch"), desc = "Quick switch note" },
    { "<leader>os", obs("search"), desc = "Search vault (ripgrep)" },
    { "<leader>ob", obs("backlinks"), desc = "Backlinks to this note" },
    { "<leader>ol", obs("links"), desc = "Links in this note" },
    { "<leader>of", obs("follow_link"), desc = "Follow link under cursor" },
    -- Two-state tasks matching your Tasks plugin: done = [x] + date, cross = [-]  (see lua/checkbox.lua)
    { "<leader>ok", function() require("checkbox").done() end, mode = { "n", "x" }, desc = "Task: done (tick + date) / undo" },
    { "<leader>oK", function() require("checkbox").cross() end, mode = { "n", "x" }, desc = "Task: cross [-] / undo" },
    { "<leader>oa", obs("tags"), desc = "Find by tag" },
    { "<leader>oR", obs("rename"), desc = "Rename note (updates backlinks)" },
    -- my scripts (replace Dataview / Tasks queries)
    {
      "<leader>ox",
      function()
        qf("tasks-due")
      end,
      desc = "Tasks due/overdue -> quickfix",
    },
    {
      "<leader>oF",
      function()
        qf("frogs")
      end,
      desc = "Yesterday's frogs -> quickfix",
    },
    {
      "<leader>om",
      function()
        qf("meetings")
      end,
      desc = "Today's meeting notes -> quickfix",
    },
    {
      "<leader>oh",
      function()
        show("timeblocks")
      end,
      desc = "Time per project today",
    },
    {
      "<leader>op",
      function()
        vim.system({ bin .. "/clip-path", vim.fn.expand("%:p") }):wait()
      end,
      desc = "Copy note path (Outlook)",
    },
    -- Index notes: replaces the Dataview TASK query inside notes like "I - Index - General Logs"
    {
      "<leader>oI",
      function()
        qf("index-tasks", vim.fn.expand("%:p"))
      end,
      desc = "Index: tasks that link here -> quickfix",
    },
    -- QuickAdd replacements: log into the current note's section (see lua/quickadd.lua)
    { "<leader>ocw", function() require("quickadd").worklog() end, desc = "Capture: work log" },
    { "<leader>ocm", function() require("quickadd").meetlog() end, desc = "Capture: meeting log" },
    { "<leader>ocl", function() require("quickadd").literaturelog() end, desc = "Capture: literature log" },
  },
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- use the new `:Obsidian <sub>` form
    workspaces = { { name = "personal", path = vault } },

    -- New notes land in the inbox, like your F - ... fleeting notes.
    notes_subdir = "010 - Inbox (Fleeting Notes)",
    new_notes_location = "notes_subdir",

    -- Keep filenames exactly as typed ("F - Work - Title"), not zettel ids or slugs.
    note_id_func = function(title)
      if title ~= nil and title ~= "" then
        return (title:gsub('[/\\:*?"<>|]', "-"))
      end
      return tostring(os.time())
    end,

    -- Daily notes use the same folder and filename as Obsidian.
    -- No template on purpose: your real daily template is Templater syntax (<% %>) which
    -- obsidian.nvim cannot run, and the Obsidian app keeps creating your real daily notes.
    -- To test the nvim-style templates, copy the course `templates/*.md` into `_templates/`
    -- in the vault and add:  daily_notes.template = "Daily.md"  and  templates.folder = "_templates".
    daily_notes = { folder = "000 - Daily Notes", date_format = "%Y-%m-%d" },

    -- IMPORTANT: never rewrite frontmatter (created / tags / up / related) on save.
    frontmatter = { enabled = false },

    -- Disable obsidian.nvim's own conceal rendering so render-markdown.nvim
    -- (from the lang.markdown extra) is the single renderer, avoiding double styling.
    ui = { enable = false },

    -- The plugin's built-in toggle (what Enter on a checkbox uses) cycles " ", "~", "!", ">", "x".
    -- Limit it to two states so Enter cannot park a task in a status you do not use.
    checkbox = { order = { " ", "x" } },

    link = { style = "wiki" },
  },
}

return {
  obsidian,
  -- which-key label so <leader>o shows as "obsidian"
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>o", group = "obsidian" }, { "<leader>oc", group = "capture" } } },
  },
}
