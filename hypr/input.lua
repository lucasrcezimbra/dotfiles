-- Personal input overrides migrated from input.conf for Omarchy Quattro.

-- The old `br(thinkpad)` layout spelling is represented explicitly in Lua as
-- the Brazilian layout plus its ThinkPad variant.
hl.config({
    input = {
        kb_layout = "br",
        kb_variant = "thinkpad",
        kb_options = "compose:caps",
    },
})

-- Omarchy already provides the old repeat, numlock, touchpad scroll factor, and
-- terminal touchpad rules as defaults. Keep only the additional mouse rule.
o.window("com.mitchellh.ghostty", { scroll_mouse = 5.0 })

-- Per-device mouse sensitivity.
hl.device({
    name = "logitech-usb-receiver-mouse",
    sensitivity = -0.5,
})

hl.device({
    name = "lift-mouse",
    sensitivity = -0.5,
})
