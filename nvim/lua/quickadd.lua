-- Neovim version of your QuickAdd "Capture" choices (Quick Worklog / Meetlog / Literaturelog).
-- Same behaviour: write into the CURRENT note, at the end of a named section, creating the
-- heading at the bottom if missing, using the same line format your Dataview/Tasks queries expect:
--     - [n] 09:15  #log/work on
--         -
-- Then it puts you in insert mode on the sub-bullet.
-- ponytail: a "section" ends at the next heading of any level (QuickAdd's considerSubsections=false)
-- and headings inside code fences are not skipped. Upgrade path: track fences if it ever bites.
local M = {}

local function rtrim(s)
  return (s:gsub("%s+$", ""))
end

---@param o { find: string, create: string, tag: string }
---  find   plain-text fragment that identifies the section heading line
---  create heading line to append at the bottom when the heading is not found
---  tag    the log tag without '#log/' (work, meeting, literature)
function M.capture(o)
  local buf = 0
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local h
  for i, l in ipairs(lines) do
    if l:match("^#+%s") and l:find(o.find, 1, true) then
      h = i
      break
    end
  end
  if not h then
    vim.api.nvim_buf_set_lines(buf, #lines, #lines, false, { "", rtrim(o.create) })
    lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    h = #lines
  end

  local e = #lines -- last line of the section
  for i = h + 1, #lines do
    if lines[i]:match("^#+%s") then
      e = i - 1
      break
    end
  end
  while e > h and lines[e]:match("^%s*$") do -- do not insert after trailing blank lines
    e = e - 1
  end

  local entry = { ("- [n] %s  #log/%s on  "):format(os.date("%H:%M"), o.tag), "    - " }
  vim.api.nvim_buf_set_lines(buf, e, e, false, entry)
  vim.api.nvim_win_set_cursor(0, { e + 2, #entry[2] })
  vim.cmd("startinsert!")
end

M.worklog = function()
  M.capture({ find = "Quick Notes & Dev Insights", create = "## 📝 Quick Notes & Dev Insights", tag = "work" })
end
M.meetlog = function()
  M.capture({ find = "Quick Notes & Dev Insights", create = "## 📝 Quick Notes & Dev Insights", tag = "meeting" })
end
M.literaturelog = function()
  M.capture({ find = "Highlights & Scratch Notes", create = "# 〰️ Highlights & Scratch Notes:", tag = "literature" })
end

return M
