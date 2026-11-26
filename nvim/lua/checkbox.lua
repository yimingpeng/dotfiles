-- Two-state task keys that match YOUR Tasks-plugin conventions (checked against the vault):
--   done    : "- [x] text ✅ 2026-11-25"   (1588 such lines; date is appended at the end of the line)
--   cross   : "- [-] text"                 (166 such lines; your cancelled tasks carry no date)
-- Pressing the same key again undoes it back to "- [ ]" and removes the date.
-- Works on the cursor line or a visual selection. Lines with another status (e.g. your log lines
-- "- [n] 09:15 #log/work ...") are left alone.
-- ponytail: recurring tasks (🔁) are ticked but the NEXT occurrence is not created like the Tasks
-- plugin does; a warning is shown. Upgrade path: parse the 🔁 rule and insert the next task.
local M = {}

local CANCEL_DATE = false -- set true to also stamp "❌ YYYY-MM-DD" on crossed tasks
local PLAIN_OK = { [" "] = true, ["x"] = true, ["-"] = true, [">"] = true, ["/"] = true }

local function strip_dates(body)
  body = body:gsub("%s*✅ %d%d%d%d%-%d%d%-%d%d", "")
  body = body:gsub("%s*❌ %d%d%d%d%-%d%d%-%d%d", "")
  return body
end

-- Pure line transform, easy to test. kind = "done" | "cross". Returns new_line, warning|nil.
function M.transform(line, kind, today)
  local head, state, body = line:match("^(%s*[-*+] %[)(.)%] ?(.*)$")
  if not head then
    return line, nil
  end
  if not PLAIN_OK[state] then
    return line, "status [" .. state .. "] is not a task, left alone"
  end
  local warn = body:find("🔁", 1, true) and "recurring task: next occurrence not created" or nil

  local target = kind == "done" and "x" or "-"
  if state == target then -- toggle off
    return head .. " ] " .. strip_dates(body), nil
  end
  body = strip_dates(body)
  if kind == "done" then
    body = body .. " ✅ " .. today
  elseif CANCEL_DATE then
    body = body .. " ❌ " .. today
  end
  return head .. target .. "] " .. body, warn
end

local function apply(kind)
  local a, b = vim.fn.line("."), vim.fn.line(".")
  if vim.fn.mode():match("^[vV\22]") then
    a, b = vim.fn.line("v"), vim.fn.line(".")
    if a > b then
      a, b = b, a
    end
    vim.cmd("normal! \27")
  end
  local today = os.date("%Y-%m-%d")
  for l = a, b do
    local line = vim.api.nvim_buf_get_lines(0, l - 1, l, false)[1]
    local new, warn = M.transform(line, kind, today)
    if new ~= line then
      vim.api.nvim_buf_set_lines(0, l - 1, l, false, { new })
    end
    if warn then
      vim.notify(("line %d: %s"):format(l, warn), vim.log.levels.WARN)
    end
  end
end

M.done = function() apply("done") end
M.cross = function() apply("cross") end

return M
