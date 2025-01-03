-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "AdventureTime"

config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 12

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }


local function is_vim(pane)

  -- this is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == 'true'
end

local direction_keys = {
  Left = 'h',
  Down = 'j',
  Up = 'k',
  Right = 'l',
  -- reverse lookup
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and 'META' or 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
        }, pane)
        wezterm.log_info("move", key, resize_or_move)
      else
        if resize_or_move == 'resize' then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
          wezterm.log_info("resize")
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
          wezterm.log_info("move")
        end
      end
    end),
  }
end

config.keys = {
  -- move between split panes
  split_nav('move', 'h'),
  split_nav('move', 'j'),
  split_nav('move', 'k'),
  split_nav('move', 'l'),
  -- resize panes
  split_nav('resize', 'h'),
  split_nav('resize', 'j'),
  split_nav('resize', 'k'),
  split_nav('resize', 'l'),
  -- Leader is the same as my old tmux prefix
  -- splitting
  {
    mods   = "LEADER",
    key    = "-",
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
  },
  {
    mods   = "LEADER",
    key    = "=",
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
  },
  {
    mods = 'LEADER',
    key = 'm',
    action = wezterm.action.TogglePaneZoomState
  },
    {
    mods = "LEADER",
    key = "Space",
    action = wezterm.action.RotatePanes "Clockwise"
  },
  -- show the pane selection mode, but have it swap the active and selected panes
  {
    mods = 'LEADER',
    key = '0',
    action = wezterm.action.PaneSelect {
      mode = 'SwapWithActive',
    },
  },
  {
    mods   = "LEADER",
    key    = "x",
    action = wezterm.action.CloseCurrentPane { confirm = true }
  },
}



wezterm.log_info(config)


-- and finally, return the configuration to wezterm
return config
