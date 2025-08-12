-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.opt.relativenumber = false
-- In case you don't want to use `:LazyExtras`,
-- then you need to set the option below.
vim.g.lazyvim_picker = "fzf"

-- Terminal border styling - softer appearance
vim.opt.fillchars = {
  horiz = '─',
  horizup = '┴',
  horizdown = '┬',
  vert = '│',
  vertleft  = '┤',
  vertright = '├',
  verthoriz = '┼',
}

-- Enhanced Adventure Time color scheme - improved readability
local adventure_time = {
  background = '#1A1836',
  background_light = '#252043',
  foreground = '#FFF4E6',
  cursor = '#FFE66D',
  -- Enhanced ANSI colors for better contrast
  black = '#0D0C15',
  red = '#E63946',
  green = '#52C754',
  yellow = '#FFB627',
  blue = '#2563EB',
  magenta = '#8B5FA6',
  cyan = '#06D6A0',
  white = '#FFF4E6',
  -- Enhanced bright colors
  bright_black = '#6366F1',
  bright_red = '#FF6B77',
  bright_green = '#7CE383',
  bright_yellow = '#FFD23F',
  bright_blue = '#60A5FA',
  bright_magenta = '#C084FC',
  bright_cyan = '#34D399',
  bright_white = '#FFFFFF',
  -- UI colors
  comment = '#A78BFA',
  selection = '#3B347A',
  border = '#7C3AED',
}

-- Terminal window highlighting with Adventure Time colors
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("terminal_setup", { clear = true }),
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_option(0, 'winhighlight', 'Normal:TerminalNormal,NormalFloat:TerminalNormalFloat')
    
    -- Set terminal colors to match Adventure Time scheme
    vim.g.terminal_color_0 = adventure_time.black
    vim.g.terminal_color_1 = adventure_time.red
    vim.g.terminal_color_2 = adventure_time.green
    vim.g.terminal_color_3 = adventure_time.yellow
    vim.g.terminal_color_4 = adventure_time.blue
    vim.g.terminal_color_5 = adventure_time.magenta
    vim.g.terminal_color_6 = adventure_time.cyan
    vim.g.terminal_color_7 = adventure_time.white
    vim.g.terminal_color_8 = adventure_time.bright_black
    vim.g.terminal_color_9 = adventure_time.bright_red
    vim.g.terminal_color_10 = adventure_time.bright_green
    vim.g.terminal_color_11 = adventure_time.bright_yellow
    vim.g.terminal_color_12 = adventure_time.bright_blue
    vim.g.terminal_color_13 = adventure_time.bright_magenta
    vim.g.terminal_color_14 = adventure_time.bright_cyan
    vim.g.terminal_color_15 = adventure_time.bright_white
  end,
})

-- Apply enhanced Adventure Time theme globally
local function apply_adventure_time_theme()
  -- Terminal highlights
  vim.api.nvim_set_hl(0, 'TerminalNormal', { 
    bg = adventure_time.background, 
    fg = adventure_time.foreground 
  })
  
  -- Window and UI elements
  vim.api.nvim_set_hl(0, 'WinSeparator', { 
    fg = adventure_time.border, bold = true 
  })
  vim.api.nvim_set_hl(0, 'Normal', { 
    bg = adventure_time.background, 
    fg = adventure_time.foreground 
  })
  vim.api.nvim_set_hl(0, 'NormalNC', { 
    bg = adventure_time.background, 
    fg = adventure_time.foreground 
  })
  
  -- Cursor and selection
  vim.api.nvim_set_hl(0, 'Cursor', { 
    bg = adventure_time.cursor, 
    fg = adventure_time.background 
  })
  vim.api.nvim_set_hl(0, 'Visual', { 
    bg = adventure_time.selection 
  })
  
  -- Line numbers and UI
  vim.api.nvim_set_hl(0, 'LineNr', { 
    fg = adventure_time.comment 
  })
  vim.api.nvim_set_hl(0, 'CursorLineNr', { 
    fg = adventure_time.yellow, bold = true 
  })
  vim.api.nvim_set_hl(0, 'StatusLine', { 
    bg = adventure_time.background_light, 
    fg = adventure_time.foreground 
  })
  vim.api.nvim_set_hl(0, 'StatusLineNC', { 
    bg = adventure_time.background, 
    fg = adventure_time.comment 
  })
  
  -- Syntax highlighting
  vim.api.nvim_set_hl(0, 'Comment', { 
    fg = adventure_time.comment, italic = true 
  })
  vim.api.nvim_set_hl(0, 'String', { 
    fg = adventure_time.green 
  })
  vim.api.nvim_set_hl(0, 'Number', { 
    fg = adventure_time.bright_magenta 
  })
  vim.api.nvim_set_hl(0, 'Boolean', { 
    fg = adventure_time.bright_magenta 
  })
  vim.api.nvim_set_hl(0, 'Function', { 
    fg = adventure_time.blue, bold = true 
  })
  vim.api.nvim_set_hl(0, 'Keyword', { 
    fg = adventure_time.magenta, bold = true 
  })
  vim.api.nvim_set_hl(0, 'Operator', { 
    fg = adventure_time.cyan 
  })
  vim.api.nvim_set_hl(0, 'Type', { 
    fg = adventure_time.yellow 
  })
  vim.api.nvim_set_hl(0, 'Variable', { 
    fg = adventure_time.foreground 
  })
  
  -- Floating windows
  vim.api.nvim_set_hl(0, 'NormalFloat', { 
    bg = adventure_time.background_light, 
    fg = adventure_time.foreground 
  })
  vim.api.nvim_set_hl(0, 'FloatBorder', { 
    fg = adventure_time.border 
  })
  
  -- Search and matches
  vim.api.nvim_set_hl(0, 'Search', { 
    bg = adventure_time.yellow, 
    fg = adventure_time.background 
  })
  vim.api.nvim_set_hl(0, 'IncSearch', { 
    bg = adventure_time.bright_yellow, 
    fg = adventure_time.background 
  })
end

-- Apply theme on startup
apply_adventure_time_theme()

-- Reapply theme when colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("adventure_time_override", { clear = true }),
  callback = apply_adventure_time_theme,
})

