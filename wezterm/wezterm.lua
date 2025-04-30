local wezterm = require("wezterm")

config = wezterm.config_builder() --this will work as a table that we can add configs to it

config = {
	automatically_reload_config = true,
	enable_tab_bar = true,
	use_fancy_tab_bar = false,
	show_tabs_in_tab_bar = true,
	show_new_tab_button_in_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE", -- disable the title bar but enable the resisable border
	default_cursor_style = "BlinkingBar",
	color_scheme = "Catppuccin Mocha (Gogh)",
	font = wezterm.font("JetBrains Mono", { weight = "Bold" }),
	font_size = 18,
	background = {
		{
			source = {
				File = "~/Pictures/bg-monterey.jpg",
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
	},
	window_padding = {
		left = 3,
		right = 3,
		top = 0,
		bottom = 0,
	},
}

return config
