-- Debug script to trace window switching events
-- Usage: In nvim, run :luafile debug_window_switch.lua
-- Then press <C-h> to move to neo-tree and watch the console output

local augroup = vim.api.nvim_create_augroup("DebugWindowSwitch", { clear = true })

-- Track fold state
local fold_states = {}

local function get_fold_info()
  local info = {
    foldlevel = vim.fn.foldlevel('.'),
    foldclosed = vim.fn.foldclosed('.'),
    buf_foldlevel = vim.wo.foldlevel,
    all_folds = {}
  }

  -- Get all fold levels in current buffer
  local line_count = vim.api.nvim_buf_line_count(0)
  for i = 1, math.min(line_count, 50) do  -- Check first 50 lines
    local fold = vim.fn.foldclosed(i)
    if fold ~= -1 then
      table.insert(info.all_folds, string.format("Line %d: closed", i))
    end
  end

  return info
end

local events = {
  "WinEnter", "WinLeave", "BufEnter", "BufLeave",
  "BufWinEnter", "BufWinLeave", "WinNew", "WinClosed"
}

print("============================================")
print("Window Switch Debug Tracing ENABLED")
print("Press <C-h> to move to neo-tree")
print("Watch for events and fold state changes")
print("============================================\n")

for _, event in ipairs(events) do
  vim.api.nvim_create_autocmd(event, {
    group = augroup,
    pattern = "*",
    callback = function()
      local ft = vim.bo.filetype
      local bufnr = vim.api.nvim_get_current_buf()
      local winnr = vim.api.nvim_get_current_win()
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local short_name = vim.fn.fnamemodify(bufname, ":t")

      if short_name == "" then
        short_name = "[No Name]"
      end

      local fold_info = get_fold_info()

      print(string.format(
        "[%s] %s | ft=%s | buf=%d win=%d | foldlevel=%d closed=%d | folds=%s",
        event,
        short_name,
        ft ~= "" and ft or "none",
        bufnr,
        winnr,
        fold_info.foldlevel,
        fold_info.foldclosed,
        #fold_info.all_folds > 0 and table.concat(fold_info.all_folds, ", ") or "none"
      ))

      -- Store fold state for comparison
      if event == "WinLeave" or event == "BufLeave" then
        fold_states[bufnr] = fold_info
      end

      if event == "WinEnter" or event == "BufEnter" then
        local prev_state = fold_states[bufnr]
        if prev_state then
          if #prev_state.all_folds ~= #fold_info.all_folds then
            print("  ⚠️  FOLD STATE CHANGED! Previous had " .. #prev_state.all_folds .. " folds, now has " .. #fold_info.all_folds)
          end
        end
      end
    end
  })
end

-- Also track fold-specific autocmds if any plugins add them
local fold_events = { "FoldChanged", "OptionSet" }
for _, event in ipairs(fold_events) do
  vim.api.nvim_create_autocmd(event, {
    group = augroup,
    pattern = "*",
    callback = function(args)
      if event == "OptionSet" and args.match ~= "foldlevel" and args.match ~= "foldenable" then
        return  -- Only track fold-related option changes
      end
      print(string.format("[%s] %s", event, args.match or ""))
    end
  })
end

print("\nDebug tracing is active. To disable, run:")
print(":lua vim.api.nvim_del_augroup_by_name('DebugWindowSwitch')")
print("")
