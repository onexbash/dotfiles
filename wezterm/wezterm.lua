-- Pull wezterm API & create config object
local wezterm = require "wezterm"
local config = wezterm.config_builder()

-- | -- | Config Options | -- | --

-- | Appearance & Font | --
config.initial_cols = 120
config.initial_rows = 28
config.font_size = 10

-- | Colorscheme | --
-- Customize Catppuccin Colorscheme
local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"] -- see: https://github.com/catppuccin/wezterm
custom.background = "#11111b"
custom.tab_bar.background = "#11111b"
custom.tab_bar.inactive_tab.bg_color = "#1e1e2e"
custom.tab_bar.new_tab.bg_color = "#1e1e2e"
-- Apply Colorscheme
config.color_schemes = {
    ["onexbash-catppuccin"] = custom,
}
config.color_scheme = "onexbash-catppuccin"

-- Return the config object to wezterm
return config
