local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Key bindings
config.keys = {}
for i = 1, 9 do
    -- ALT + number to activate that tab
    table.insert(config.keys, {
        key = tostring(i),
        mods = "ALT",
        action = act.ActivateTab(i - 1),
    })
end

-- Appearance
config.color_scheme = "Dracula+"
config.font_size = 9.0
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

return config
