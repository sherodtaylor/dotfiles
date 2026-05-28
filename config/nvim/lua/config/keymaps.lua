-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local M = {}

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("n", "dd", [[_dd]])

-- Logging and debugging functions
function M.yank_last_errors(count)
  count = count or 5
  local errors = {}
  
  -- Get errors from nvim-notify if available
  local notify_ok, notify = pcall(require, "notify")
  if notify_ok and notify.history then
    local history = notify.history()
    for i = #history, math.max(1, #history - count * 2), -1 do -- Get more to filter
      local notif = history[i]
      if notif.level == vim.log.levels.ERROR then
        local timestamp = os.date("%H:%M:%S", notif.time / 1000)
        table.insert(errors, string.format("[%s] ERROR: %s", timestamp, notif.message))
        if #errors >= count then break end
      end
    end
  end
  
  -- Get errors from vim messages
  local messages = vim.split(vim.fn.execute("messages"), "\n")
  for i = #messages, 1, -1 do
    if #errors >= count then break end
    local msg = vim.trim(messages[i])
    if msg:match("Error:") or msg:match("E%d+:") or msg:match("Error") then
      table.insert(errors, "VIM-MSG: " .. msg)
    end
  end
  
  -- Get LSP diagnostics errors
  local diagnostics = vim.diagnostic.get(0, {severity = vim.diagnostic.severity.ERROR})
  for _, diag in ipairs(diagnostics) do
    if #errors >= count then break end
    local line_info = string.format("Line %d", diag.lnum + 1)
    table.insert(errors, string.format("LSP-ERROR [%s]: %s", line_info, diag.message))
  end
  
  if #errors == 0 then
    vim.notify("No recent errors found", vim.log.levels.INFO)
    return
  end
  
  local error_text = table.concat(errors, "\n")
  vim.fn.setreg("+", error_text)
  vim.notify(string.format("Copied %d error messages to clipboard", #errors), vim.log.levels.INFO)
end

function M.show_error_logs()
  -- Open a new buffer with error information
  vim.cmd("tabnew")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, "ErrorLogs")
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  
  local lines = {"=== ERROR LOGS ===", ""}
  
  -- Add vim messages
  table.insert(lines, "=== VIM MESSAGES ===")
  local messages = vim.split(vim.fn.execute("messages"), "\n")
  for _, msg in ipairs(messages) do
    if msg:match("Error:") or msg:match("E%d+:") or msg:match("Error") then
      table.insert(lines, msg)
    end
  end
  
  table.insert(lines, "")
  table.insert(lines, "=== LSP DIAGNOSTICS ===")
  local diagnostics = vim.diagnostic.get(0, {severity = vim.diagnostic.severity.ERROR})
  for _, diag in ipairs(diagnostics) do
    local line_info = string.format("Line %d, Col %d", diag.lnum + 1, diag.col + 1)
    table.insert(lines, string.format("[%s]: %s", line_info, diag.message))
  end
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

function M.show_debug_logs()
  -- Show comprehensive debug information
  vim.cmd("tabnew")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, "DebugLogs")
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  
  local lines = {"=== NVIM DEBUG INFORMATION ===", ""}
  
  -- Add version info
  table.insert(lines, "=== VERSION INFO ===")
  table.insert(lines, "Neovim version: " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch)
  table.insert(lines, "")
  
  -- Add loaded plugins
  table.insert(lines, "=== LOADED PLUGINS ===")
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    for name, plugin in pairs(lazy.plugins()) do
      if plugin.loaded then
        table.insert(lines, "✓ " .. name)
      end
    end
  end
  
  table.insert(lines, "")
  table.insert(lines, "=== LSP CLIENTS ===")
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    table.insert(lines, string.format("• %s (id: %d)", client.name, client.id))
  end
  
  table.insert(lines, "")
  table.insert(lines, "=== ALL MESSAGES ===")
  local messages = vim.split(vim.fn.execute("messages"), "\n")
  for _, msg in ipairs(messages) do
    table.insert(lines, msg)
  end
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

local function copy_diagnostic_info()
  local info = {}
  table.insert(info, "=== DIAGNOSTIC INFO ===")
  table.insert(info, "Neovim: " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch)
  
  -- LSP info
  local clients = vim.lsp.get_active_clients()
  table.insert(info, "LSP Clients: " .. #clients)
  for _, client in ipairs(clients) do
    table.insert(info, "  • " .. client.name)
  end
  
  -- Plugin info
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    local loaded_count = 0
    for _, plugin in pairs(lazy.plugins()) do
      if plugin.loaded then loaded_count = loaded_count + 1 end
    end
    table.insert(info, "Plugins loaded: " .. loaded_count)
  end
  
  local info_text = table.concat(info, "\n")
  vim.fn.setreg("+", info_text)
  vim.notify("Diagnostic info copied to clipboard", vim.log.levels.INFO)
end

-- Debugging and logging keybindings
vim.keymap.set("n", "<leader>dy", function() M.yank_last_errors(5) end, { desc = "Yank Last 5 Error Messages" })
vim.keymap.set("n", "<leader>de", M.show_error_logs, { desc = "Show Error Logs" })
vim.keymap.set("n", "<leader>dd", M.show_debug_logs, { desc = "Show Debug Logs" })
vim.keymap.set("n", "<leader>dc", copy_diagnostic_info, { desc = "Copy Diagnostic Info" })
vim.keymap.set("n", "<leader>d3", function() M.yank_last_errors(3) end, { desc = "Yank Last 3 Error Messages" })
vim.keymap.set("n", "<leader>d1", function() M.yank_last_errors(1) end, { desc = "Yank Last Error Message" })

-- Terminal management keybindings
local function create_terminal()
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

local function create_horizontal_terminal()
  vim.cmd("split")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

local function create_vertical_terminal()
  vim.cmd("vsplit")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

local function toggle_terminal_mode()
  if vim.bo.buftype == "terminal" then
    if vim.api.nvim_get_mode().mode == "t" then
      vim.cmd("stopinsert")
    else
      vim.cmd("startinsert")
    end
  end
end

local function close_terminal()
  if vim.bo.buftype == "terminal" then
    vim.cmd("bdelete!")
  end
end

-- Terminal keybindings
vim.keymap.set("n", "<leader>tt", create_terminal, { desc = "Open Terminal" })
vim.keymap.set("n", "<leader>th", create_horizontal_terminal, { desc = "Open Horizontal Terminal" })
vim.keymap.set("n", "<leader>tv", create_vertical_terminal, { desc = "Open Vertical Terminal" })
vim.keymap.set("n", "<leader>tm", toggle_terminal_mode, { desc = "Toggle Terminal Mode" })
vim.keymap.set("n", "<leader>tc", close_terminal, { desc = "Close Terminal" })

-- Terminal mode keybindings
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Go to left window" })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Go to lower window" })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Go to upper window" })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Go to right window" })
vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Buffer navigation for terminals
local function next_terminal_buffer()
  local terminals = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "terminal" then
      table.insert(terminals, buf)
    end
  end
  
  if #terminals <= 1 then
    vim.notify("No other terminal buffers", vim.log.levels.INFO)
    return
  end
  
  local current = vim.api.nvim_get_current_buf()
  local current_idx = 1
  for i, buf in ipairs(terminals) do
    if buf == current then
      current_idx = i
      break
    end
  end
  
  local next_idx = current_idx % #terminals + 1
  vim.api.nvim_set_current_buf(terminals[next_idx])
end

local function prev_terminal_buffer()
  local terminals = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "terminal" then
      table.insert(terminals, buf)
    end
  end
  
  if #terminals <= 1 then
    vim.notify("No other terminal buffers", vim.log.levels.INFO)
    return
  end
  
  local current = vim.api.nvim_get_current_buf()
  local current_idx = 1
  for i, buf in ipairs(terminals) do
    if buf == current then
      current_idx = i
      break
    end
  end
  
  local prev_idx = current_idx == 1 and #terminals or current_idx - 1
  vim.api.nvim_set_current_buf(terminals[prev_idx])
end

vim.keymap.set("n", "<leader>tn", next_terminal_buffer, { desc = "Next Terminal Buffer" })
vim.keymap.set("n", "<leader>tp", prev_terminal_buffer, { desc = "Previous Terminal Buffer" })
vim.keymap.set("t", "<leader>tn", next_terminal_buffer, { desc = "Next Terminal Buffer" })
vim.keymap.set("t", "<leader>tp", prev_terminal_buffer, { desc = "Previous Terminal Buffer" })


-- Enable leader keys in special buffers like neo-tree
vim.api.nvim_create_autocmd("FileType", {
  pattern = "neo-tree",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    -- Map leader keys that should work in neo-tree
    vim.keymap.set("n", "<leader>tt", function()
      vim.cmd("terminal")
      vim.cmd("startinsert")
    end, { buffer = buf, desc = "Open Terminal" })
    
    vim.keymap.set("n", "<leader>th", function()
      vim.cmd("split")
      vim.cmd("terminal")
      vim.cmd("startinsert")
    end, { buffer = buf, desc = "Open Horizontal Terminal" })
    
    vim.keymap.set("n", "<leader>tv", function()
      vim.cmd("vsplit")
      vim.cmd("terminal")
      vim.cmd("startinsert")
    end, { buffer = buf, desc = "Open Vertical Terminal" })
    
    vim.keymap.set("n", "<leader>dy", function()
      M.yank_last_errors(5)
    end, { buffer = buf, desc = "Yank Last 5 Error Messages" })
    
    vim.keymap.set("n", "<leader>de", M.show_error_logs, { buffer = buf, desc = "Show Error Logs" })
    vim.keymap.set("n", "<leader>dd", M.show_debug_logs, { buffer = buf, desc = "Show Debug Logs" })
    
    vim.keymap.set("n", "<leader>?", function()
      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.show()
      else
        vim.cmd("help")
      end
    end, { buffer = buf, desc = "Show Help/Which-Key" })
  end,
})

-- Help command (which-key)
vim.keymap.set("n", "<leader>?", function()
  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.show()
  else
    vim.cmd("help")
  end
end, { desc = "Show Help/Which-Key" })

return M
