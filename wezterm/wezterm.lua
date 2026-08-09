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
config.font = wezterm.font("Hack Nerd Font", { weight = "Bold" })
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

-- control dim
-- Dim unfocused windows so the focused one is obvious at a glance.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.62

-- get_config_overrides() hands back a copy, so the current value is never the
-- same table we last stored; compare the fields instead of the identity.
local function same_text_hsb(actual, expected)
	if actual == nil or expected == nil then
		return actual == expected
	end
	return actual.hue == expected.hue
		and actual.saturation == expected.saturation
		and actual.brightness == expected.brightness
end

wezterm.on("window-focus-changed", function(window)
	local overrides = window:get_config_overrides() or {}
	local text_hsb, opacity
	if not window:is_focused() then
		text_hsb = UNFOCUSED_FOREGROUND_TEXT_HSB
		opacity = UNFOCUSED_WINDOW_BACKGROUND_OPACITY
	end

	-- Only write when one of the two values we own actually changes; a redundant
	-- set_config_overrides() call would trigger another config reload.
	if same_text_hsb(overrides.foreground_text_hsb, text_hsb) and overrides.window_background_opacity == opacity then
		return
	end

	overrides.foreground_text_hsb = text_hsb
	overrides.window_background_opacity = opacity
	window:set_config_overrides(overrides)
end)

return config
