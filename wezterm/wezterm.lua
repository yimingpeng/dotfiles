local wezterm = require("wezterm")

-- Create config builder
local config = wezterm.config_builder()

-- Set your configuration options
config.automatically_reload_config = true
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE" -- disable the title bar but enable the resisable border
config.default_cursor_style = "BlinkingBar"
config.color_scheme = "Catppuccin Mocha (Gogh)"
config.font = wezterm.font("JetBrains Mono", { weight = "Bold" })
config.font_size = 18
config.background = {
	{
		source = {
			File = "$HOME/Pictures/bg-monterey.jpg",
		},
		hsb = {
			hue = 1.0,
			saturation = 1.02,
			brightness = 0.25,
		},
		width = "100%",
		height = "100%",
	},
	{
		source = {
			Color = "#282c35",
		},
		width = "100%",
		height = "100%",
		opacity = 0.88,
	},
}
config.window_padding = {
	left = 1,
	right = 1,
	top = 0,
	bottom = 0,
}

-- Add key bindings
config.keys = {
	-- Alt+Enter to toggle fullscreen
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.ToggleFullScreen,
	},
}

-- Control the screen size
local mux = wezterm.mux
wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

return config
