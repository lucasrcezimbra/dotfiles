-- Personal keybindings migrated from bindings.conf for Omarchy Quattro.

-- Replace conflicting Omarchy defaults.
hl.unbind("SUPER + SHIFT + G") -- Signal
hl.unbind("SUPER + SHIFT + S") -- Google Maps
hl.unbind("SUPER + SHIFT + SLASH") -- 1Password
hl.unbind("SUPER + SHIFT + A") -- ChatGPT without the explicit browser profile
hl.unbind("SUPER + SHIFT + Y") -- YouTube without the explicit browser profile
hl.unbind("SUPER + SHIFT + CTRL + G") -- Google Messages

-- Personal application bindings.
o.bind(
    "SUPER + SHIFT + G",
    "WhatsApp",
    [[omarchy-launch-or-focus-webapp WhatsApp "https://web.whatsapp.com/" --profile-directory=Default]]
)
o.bind("SUPER + SHIFT + S", "Quick note", [[xdg-open 'obsidian://open?vault=personal&file=tmp']])
o.bind("SUPER + SHIFT + SLASH", "Passwords", "uwsm-app -- bitwarden-desktop")
o.bind(
    "SUPER + SHIFT + A",
    "ChatGPT",
    [[omarchy-launch-or-focus-webapp ChatGPT "https://chatgpt.com" --profile-directory=Default]]
)
o.bind(
    "SUPER + SHIFT + Y",
    "YouTube",
    [[omarchy-launch-or-focus-webapp YouTube "https://youtube.com/" --profile-directory=Default]]
)
o.bind(
    "SUPER + SHIFT + CTRL + G",
    "Telegram",
    [[omarchy-launch-or-focus-webapp Telegram "https://web.telegram.org/" --profile-directory=Default]]
)
o.bind(
    "SUPER + SHIFT + T",
    "Todoist",
    [[omarchy-launch-or-focus-webapp Todoist "https://app.todoist.com/app/" --profile-directory=Default]]
)

-- Herdr sessions.
o.bind(
    "SUPER + SHIFT + R",
    "Robot session",
    [[omarchy-launch-or-focus org.omarchy.herdr-robot "uwsm-app -- xdg-terminal-exec --app-id=org.omarchy.herdr-robot -e herdr session attach robot"]]
)
o.bind(
    "SUPER + SHIFT + H",
    "Focus session",
    [[omarchy-launch-or-focus org.omarchy.herdr-focus "uwsm-app -- xdg-terminal-exec --app-id=org.omarchy.herdr-focus -e herdr session attach focus"]]
)
