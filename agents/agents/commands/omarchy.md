---
name: omarchy
---

# Omarchy Skill

Manage [Omarchy](https://omarchy.org/) Linux systems - a beautiful, modern, opinionated Arch Linux distribution with Hyprland.

This skill is for end-user customization on installed systems.
It is not for contributing to Omarchy source code.

## When This Skill MUST Be Used

**ALWAYS invoke this skill for end-user requests involving ANY of these:**

- Editing ANY file in `~/.config/hypr/` (window rules, animations, keybindings, monitors, etc.)
- Editing ANY file in `~/.config/waybar/`, `~/.config/walker/`, `~/.config/mako/`
- Editing terminal configs (alacritty, kitty, ghostty)
- Editing ANY file in `~/.config/omarchy/`
- Window behavior, animations, opacity, blur, gaps, borders
- Layer rules, workspace settings, display/monitor configuration
- Themes, wallpapers, fonts, appearance changes
- User-facing `omarchy-*` commands (`omarchy-theme-*`, `omarchy-refresh-*`, `omarchy-restart-*`, etc.)
- Screenshots, screen recording, night light, idle behavior, lock screen

**If you're about to edit a config file in `~/.config/` on this system, STOP and use this skill first. Then edit only the corresponding file in `~/.dotfiles/`.**

**Do NOT use this skill for Omarchy development tasks** (editing files in `~/.local/share/omarchy/`, creating migrations, or running `omarchy-dev-*` workflows).

## Critical Safety Rules

### Dotfiles Source of Truth

**NEVER edit `~/.config/` directly.** Runtime config files are symlinks or generated targets. `~/.dotfiles/` is the source of truth.

Before changing any config file:

1. Resolve the intended runtime path to its dotfiles path (example: `~/.config/hypr/bindings.conf` -> `~/.dotfiles/hypr/bindings.conf`).
2. Verify the file or parent directory lives under `~/.dotfiles/`.
3. Edit or create only the path under `~/.dotfiles/`.

**If the file is not in `~/.dotfiles/`, STOP and ask the user for next steps.** Do not create, edit, or delete it in `~/.config/`.

### Omarchy Source Is Read-Only

**For end-user customization tasks, NEVER modify anything in `~/.local/share/omarchy/`** - but READING is safe and encouraged.

This directory contains Omarchy's source files managed by git. Any changes will be:
- Lost on next `omarchy-update`
- Cause conflicts with upstream
- Break the system's update mechanism

```
~/.local/share/omarchy/     # READ-ONLY - NEVER EDIT (reading is OK)
├── bin/                    # Source scripts (symlinked to PATH)
├── config/                 # Default config templates
├── themes/                 # Stock themes
├── default/                # System defaults
├── migrations/             # Update migrations
└── install/                # Installation scripts
```

**Reading `~/.local/share/omarchy/` is SAFE and useful** - do it freely to:
- Understand how omarchy commands work: `cat $(which omarchy-theme-set)`
- See default configs before customizing: `cat ~/.local/share/omarchy/config/waybar/config.jsonc`
- Check stock theme files to copy for customization
- Reference default hyprland settings: `cat ~/.local/share/omarchy/default/hypr/*`

**Always use these safe source locations instead:**
- `~/.dotfiles/` - User configuration source of truth (safe to edit)
- `~/.dotfiles/omarchy/themes/<custom-name>/` - Custom themes, only when this path is managed into `~/.config/omarchy/themes/`
- `~/.dotfiles/omarchy/hooks/` - Custom automation hooks, only when this path is managed into `~/.config/omarchy/hooks/`

If the matching source path does not exist under `~/.dotfiles/`, STOP and ask the user for next steps.

If the request is to develop Omarchy itself, this skill is out of scope. Follow repository development instructions instead of this skill.

## System Architecture

Omarchy is built on these runtime config paths. Treat them as targets only; edit corresponding sources under `~/.dotfiles/`.

| Component | Purpose | Runtime Config Location |
|-----------|---------|-------------------------|
| **Arch Linux** | Base OS | `/etc/`, `~/.config/` |
| **Hyprland** | Wayland compositor/WM | `~/.config/hypr/` |
| **Waybar** | Status bar | `~/.config/waybar/` |
| **Walker** | App launcher | `~/.config/walker/` |
| **Alacritty/Kitty/Ghostty** | Terminals | `~/.config/<terminal>/` |
| **Mako** | Notifications | `~/.config/mako/` |
| **SwayOSD** | On-screen display | `~/.config/swayosd/` |

## Command Discovery

Omarchy provides ~145 commands following `omarchy-<category>-<action>` pattern.

```bash
# List all omarchy commands
compgen -c | grep -E '^omarchy-' | sort -u

# Find commands by category
compgen -c | grep -E '^omarchy-theme'
compgen -c | grep -E '^omarchy-restart'

# Read a command's source to understand it
cat $(which omarchy-theme-set)
```

### Command Categories

| Prefix | Purpose | Example |
|--------|---------|---------|
| `omarchy-refresh-*` | Reset config to defaults (backs up first) | `omarchy-refresh-waybar` |
| `omarchy-restart-*` | Restart a service/app | `omarchy-restart-waybar` |
| `omarchy-toggle-*` | Toggle feature on/off | `omarchy-toggle-nightlight` |
| `omarchy-theme-*` | Theme management | `omarchy-theme-set <name>` |
| `omarchy-install-*` | Install optional software | `omarchy-install-docker-dbs` |
| `omarchy-launch-*` | Launch apps | `omarchy-launch-browser` |
| `omarchy-cmd-*` | System commands | `omarchy-cmd-screenshot` |
| `omarchy-pkg-*` | Package management | `omarchy-pkg-install <pkg>` |
| `omarchy-setup-*` | Initial setup tasks | `omarchy-setup-fingerprint` |
| `omarchy-update-*` | System updates | `omarchy-update` |

## Configuration Locations

Paths below show dotfiles source locations to edit. Runtime targets live under `~/.config/`; do not edit them directly.

### Hyprland (Window Manager)

```
~/.dotfiles/hypr/      # runtime target: ~/.config/hypr/
├── hyprland.conf      # Main config (sources others)
├── bindings.conf      # Keybindings
├── monitors.conf      # Display configuration
├── input.conf         # Keyboard/mouse settings
├── looknfeel.conf     # Appearance (gaps, borders, animations)
├── envs.conf          # Environment variables
├── autostart.conf     # Startup applications
├── hypridle.conf      # Idle behavior (screen off, lock, suspend)
├── hyprlock.conf      # Lock screen appearance
└── hyprsunset.conf    # Night light / blue light filter
```

**Key behaviors:**
- Hyprland auto-reloads on config save (no restart needed for most changes)
- Use `hyprctl reload` to force reload
- Use `omarchy-refresh-hyprland` to reset to defaults

### Waybar (Status Bar)

```
~/.dotfiles/waybar/    # runtime target: ~/.config/waybar/
├── config.jsonc       # Bar layout and modules (JSONC format)
└── style.css          # Styling
```

**Waybar does NOT auto-reload.** You MUST run `omarchy-restart-waybar` after any config changes.

**Commands:** `omarchy-restart-waybar`, `omarchy-refresh-waybar`, `omarchy-toggle-waybar`

### Terminals

Expected dotfiles source paths, if present:

```
~/.dotfiles/alacritty/alacritty.toml   # runtime target: ~/.config/alacritty/alacritty.toml
~/.dotfiles/kitty/kitty.conf           # runtime target: ~/.config/kitty/kitty.conf
~/.dotfiles/ghostty/config             # runtime target: ~/.config/ghostty/config
```

If the matching source path is not in `~/.dotfiles/`, STOP and ask the user for next steps.

**Command:** `omarchy-restart-terminal`

### Other Configs

| App | Runtime Location | Dotfiles Source Rule |
|-----|------------------|----------------------|
| btop | `~/.config/btop/btop.conf` | Edit only matching `~/.dotfiles/` path; otherwise STOP |
| fastfetch | `~/.config/fastfetch/config.jsonc` | Edit only matching `~/.dotfiles/` path; otherwise STOP |
| lazygit | `~/.config/lazygit/config.yml` | Edit only matching `~/.dotfiles/` path; otherwise STOP |
| starship | `~/.config/starship.toml` | Edit only matching `~/.dotfiles/` path; otherwise STOP |
| git | `~/.config/git/config` | Edit only matching `~/.dotfiles/` path; otherwise STOP |
| walker | `~/.config/walker/config.toml` | Edit only matching `~/.dotfiles/` path; otherwise STOP |

## Safe Customization Patterns

### Pattern 1: Edit Dotfiles Source Only

For simple changes, edit files in `~/.dotfiles/`, never `~/.config/`:

```bash
# 1. Map runtime config to dotfiles source
# ~/.config/hypr/bindings.conf -> ~/.dotfiles/hypr/bindings.conf

# 2. Verify source file or parent directory is under ~/.dotfiles/
realpath -e ~/.dotfiles/hypr/bindings.conf

# 3. Make changes with Edit tool to ~/.dotfiles/hypr/bindings.conf only

# 4. Apply changes
# - Hyprland: auto-reloads on save (no restart needed)
# - Waybar: MUST restart with omarchy-restart-waybar
# - Walker: MUST restart with omarchy-restart-walker
# - Terminals: MUST restart with omarchy-restart-terminal
```

If there is no source path under `~/.dotfiles/`, STOP and ask the user for next steps.

### Pattern 2: Make a new theme

1. Create a directory under `~/.dotfiles/omarchy/themes/` only if it is managed into `~/.config/omarchy/themes/`.
2. If that dotfiles-managed path does not exist, STOP and ask the user for next steps.
3. See how an existing theme is done via `~/.local/share/omarchy/themes/catppuccin`.
4. Download a matching background (or several) from the internet and put them in `~/.dotfiles/omarchy/themes/[name-of-new-theme]`.
5. When done with the theme, run `omarchy-theme-set "Name of new theme"`.

### Pattern 3: Use Hooks for Automation

Create scripts in `~/.dotfiles/omarchy/hooks/` only if it is managed into `~/.config/omarchy/hooks/`. If not, STOP and ask the user for next steps.

```bash
# Available runtime hooks (source must live in ~/.dotfiles/omarchy/hooks/):
~/.dotfiles/omarchy/hooks/
├── theme-set        # Runs after theme change (receives theme name as $1)
├── font-set         # Runs after font change
└── post-update      # Runs after omarchy-update
```

Example hook (`~/.dotfiles/omarchy/hooks/theme-set`):
```bash
#!/bin/bash
THEME_NAME=$1
echo "Theme changed to: $THEME_NAME"
# Add custom actions here
```

### Pattern 4: Reset to Defaults -- ALWAYS SEEK USER CONFIRMATION BEFORE RUNNING

When customizations go wrong, first confirm the affected runtime path resolves into `~/.dotfiles/`. If not, STOP and ask the user for next steps.

```bash
# Reset specific config (creates backup automatically)
omarchy-refresh-waybar
omarchy-refresh-hyprland

# The refresh command:
# 1. Backs up current config with timestamp
# 2. Copies default from ~/.local/share/omarchy/config/
# 3. Restarts the component
```

These commands may write runtime config targets. Never manually edit `~/.config/`; keep source changes in `~/.dotfiles/`.

## Common Tasks

### Themes

```bash
omarchy-theme-list              # Show available themes
omarchy-theme-current           # Show current theme
omarchy-theme-set <name>        # Apply theme (use "Tokyo Night" not "tokyo-night")
omarchy-theme-next              # Cycle to next theme
omarchy-theme-bg-next           # Cycle wallpaper
omarchy-theme-install <url>     # Install from git repo
```

### Keybindings

Edit `~/.dotfiles/hypr/bindings.conf` (runtime target: `~/.config/hypr/bindings.conf`). Format:
```
bind = SUPER, Return, exec, xdg-terminal-exec
bind = SUPER, Q, killactive
bind = SUPER SHIFT, E, exit
```

View current bindings: `omarchy-menu-keybindings --print`

**IMPORTANT: When re-binding an existing key:**

1. First check existing bindings: `omarchy-menu-keybindings --print`
2. If the key is already bound, you MUST add an `unbind` directive BEFORE your new `bind`
3. Inform the user what the key was previously bound to

Example - rebinding SUPER+F (which is bound to fullscreen by default):
```
# Unbind existing SUPER+F (was: fullscreen)
unbind = SUPER, F
# New binding for file manager
bind = SUPER, F, exec, nautilus
```

Always tell the user: "Note: SUPER+F was previously bound to fullscreen. I've added an unbind directive to override it."

### Display/Monitors

Edit `~/.dotfiles/hypr/monitors.conf` (runtime target: `~/.config/hypr/monitors.conf`). Format:
```
monitor = eDP-1, 1920x1080@60, 0x0, 1
monitor = HDMI-A-1, 2560x1440@144, 1920x0, 1
```

List monitors: `hyprctl monitors`

### Window Rules

**CRITICAL: Hyprland window rules syntax changes frequently between versions.**

Before writing ANY window rules, you MUST fetch the current documentation from the official Hyprland wiki:
- https://github.com/hyprwm/hyprland-wiki/blob/main/content/Configuring/Window-Rules.md

DO NOT rely on cached or memorized window rule syntax. The format has changed multiple times and using outdated syntax will cause errors or unexpected behavior.

Window rules go in `~/.dotfiles/hypr/hyprland.conf` or a sourced file under `~/.dotfiles/hypr/` (runtime target: `~/.config/hypr/`). Always verify the current syntax from the wiki first.

### Fonts

```bash
omarchy-font-list               # Available fonts
omarchy-font-current            # Current font
omarchy-font-set <name>         # Change font
```

### System

```bash
omarchy-update                  # Full system update
omarchy-version                 # Show Omarchy version
omarchy-debug --no-sudo --print # Debug info (ALWAYS use these flags)
omarchy-lock-screen             # Lock screen
omarchy-system-shutdown         # Shutdown
omarchy-system-reboot           # Reboot
```

**IMPORTANT:** Always run `omarchy-debug` with `--no-sudo --print` flags to avoid interactive sudo prompts that will hang the terminal.

## Troubleshooting

```bash
# Get debug information (ALWAYS use these flags to avoid interactive prompts)
omarchy-debug --no-sudo --print

# Upload logs for support
omarchy-upload-log

# Reset specific config to defaults
omarchy-refresh-<app>

# Refresh specific config file
# config-file path is relative to ~/.config/
# eg. omarchy-refresh-config hypr/hyprlock.conf will refresh ~/.config/hypr/hyprlock.conf
# Before running, confirm the target resolves into ~/.dotfiles/; otherwise STOP and ask.
omarchy-refresh-config <config-file>

# Full reinstall of configs (nuclear option)
omarchy-reinstall
```

## Decision Framework

When user requests system changes:

1. **Is it a stock omarchy command?** Use it directly
2. **Is it a config edit?** Edit the corresponding file in `~/.dotfiles/`, never `~/.config/` or `~/.local/share/omarchy/`. If it is not in `~/.dotfiles/`, STOP and ask the user for next steps.
3. **Is it a theme customization?** Create a NEW custom theme directory under `~/.dotfiles/` only when managed into the runtime theme path; otherwise STOP and ask.
4. **Is it automation?** Use hooks under `~/.dotfiles/` only when managed into the runtime hooks path; otherwise STOP and ask.
5. **Is it a package install?** Use `omarchy-pkg-add` (or `omarchy-pkg-aur-add` for AUR-only packages)
6. **Unsure if command exists?** Search with `compgen -c | grep omarchy`

## Out of Scope

This skill intentionally does not cover Omarchy source development. Do not use this skill for:
- Editing files in `~/.local/share/omarchy/` (`bin/`, `config/`, `default/`, `themes/`, `migrations/`, etc.)
- Creating or editing migrations
- Running `omarchy-dev-*` commands

## Example Requests

- "Change my theme to catppuccin" -> `omarchy-theme-set catppuccin`
- "Add a keybinding for Super+E to open file manager" -> Check existing bindings first, add `unbind` if needed, then add `bind` in `~/.dotfiles/hypr/bindings.conf`
- "Configure my external monitor" -> Edit `~/.dotfiles/hypr/monitors.conf`
- "Make the window gaps smaller" -> Edit `~/.dotfiles/hypr/looknfeel.conf`
- "Set up night light to turn on at sunset" -> `omarchy-toggle-nightlight` or edit `~/.dotfiles/hypr/hyprsunset.conf`
- "Customize the catppuccin theme colors" -> Create `~/.dotfiles/omarchy/themes/catppuccin-custom/` only if managed into runtime themes; otherwise STOP and ask
- "Run a script every time I change themes" -> Create `~/.dotfiles/omarchy/hooks/theme-set` only if managed into runtime hooks; otherwise STOP and ask
- "Reset waybar to defaults" -> `omarchy-refresh-waybar`

---

User input: $@
