# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository for Sway (Wayland compositor) and Waybar (status bar) configuration on CachyOS Linux. The repository contains window manager configuration, status bar setup, and a package list for system installation.

## Repository Structure

```
.
├── install.sh            # Installation script for fresh systems
├── pkglist.txt           # CachyOS package list (251 packages)
├── CLAUDE.md             # This file - instructions for Claude Code
├── config                # Main Sway configuration
├── show-keybindings.sh   # Keybindings cheatsheet (fuzzel popup)
├── fuzzel/
│   └── fuzzel.ini       # Fuzzel launcher configuration
├── kitty/
│   └── kitty.conf       # Kitty terminal configuration
├── scripts/
│   └── update-bing-wallpaper.sh  # Daily Bing wallpaper updater
├── systemd/
│   ├── bing-wallpaper.service    # Systemd service for wallpaper updates
│   └── bing-wallpaper.timer      # Daily timer for wallpaper updates
└── waybar/
    ├── config           # Waybar configuration (JSON with comments)
    ├── style.css        # Waybar styling
    ├── power_menu.xml   # GTK power menu definition
    ├── weather.sh       # Weather widget script
    └── waybar/          # Nested directory with additional configs/backups
```

## Configuration Architecture

### Sway Configuration (`config`)

The Sway config uses a hierarchical variable-based setup:
- **Variables section**: Defines key bindings, terminal, launcher
  - `$mod` = Mod4 (Super/Windows key)
  - `$term` = kitty
  - `$menu` = fuzzel
  - Vim-style directional keys: `$left/$down/$up/$right` = `h/j/k/l`

- **Input configuration**:
  - Touchpad: tap-to-click, natural scroll, dwt enabled
  - Keyboard: US layout with caps lock remapped to ctrl (`ctrl:nocaps`)

- **Key bindings**:
  - Applications: `$mod+Return` (terminal), `$mod+Shift+b` (Firefox), `$mod+Ctrl+e` (Emacs)
  - Utilities: `$mod+/` (show keybindings cheatsheet)
  - Media keys: Volume control via PulseAudio, brightness via brightnessctl
  - Screenshot: Print key uses grim

- **Status bar**: Uses waybar (line 231: `swaybar_command waybar`)
- **Idle management**: swayidle configured with screen lock (swaylock) and display power management
- **Wallpaper**: Daily Bing Photo of the Day downloaded to `~/.local/share/backgrounds/bing-daily.jpg`

### Waybar Configuration (`waybar/config`)

Waybar uses a three-section layout:
- **Left**: Workspaces, mode indicator, scratchpad, weather, media player
- **Center**: Window title
- **Right**: Idle inhibitor, CPU, battery, audio, tray, clock, power menu

Key modules:
- **Clock**: Displays day, date, and time in format "Fri, 27 Dec 2025 09:57"
- **CPU**: Shows usage percentage with microchip icon (\uf3fd)
- **Battery**: BAT0 with battery icon (\uf240) and warning thresholds (95%/30%/5%)
- **Audio**: PulseAudio integration with click actions (mute/pavucontrol)
- **Weather**: Custom widget using `weather.sh` that fetches weather from wttr.in (location: 38.2356,-122.6556)
- **Media Player**: Uses playerctl to show currently playing media with play/pause control
- **Scratchpad**: Shows count of windows in scratchpad
- **Power Menu**: Custom GTK menu for logout/reboot/shutdown actions

### Styling (`waybar/style.css`)

- Dark theme: Background #333333 with 85% opacity, text #ffffff
- Active workspace: #285577 (blue)
- FontAwesome icons required for CPU, battery, audio, and idle inhibitor modules
- Battery critical state: Red background (#f53c3c) with blink animation

### Kitty Configuration (`kitty/kitty.conf`)

Terminal emulator configuration:
- **Font**: Iosevka at 16pt
- **Auto bold/italic**: Configured to use font variants automatically
- Configuration includes extensive theming and behavior customization
- Config file is 111KB with detailed comments and options

### Bing Wallpaper System (`scripts/update-bing-wallpaper.sh`)

Automated daily wallpaper updates from Bing Photo of the Day:
- **Script location**: `~/.local/bin/update-bing-wallpaper.sh` (deployed by install.sh)
- **Download target**: `~/.local/share/backgrounds/bing-daily.jpg`
- **API source**: Bing HPImageArchive API (en-US market)
- **Update schedule**: Runs at 00:00, 06:00, 12:00, 18:00 daily + 5 minutes after boot
- **Network resilience**: Waits for network connectivity before running; retries on failure
- **Error handling**: Validates API response, download integrity, and file size
- **Auto-reload**: Calls `swaymsg reload` to apply new wallpaper if Sway is running

Systemd timer configuration:
- **Service**: `bing-wallpaper.service` - One-shot service with network dependency and retry logic
  - Waits for network-online.target before running
  - Automatically retries on failure (up to 3 attempts per trigger)
  - 10-minute delay between retry attempts
- **Timer**: `bing-wallpaper.timer` - Multiple daily triggers to handle sleep/wake scenarios
  - Runs 4 times daily: midnight, 6 AM, noon, and 6 PM
  - Also runs 5 minutes after boot
  - Persistent mode ensures missed timers run after wake from sleep
- **Management**: Enable with `systemctl --user enable --now bing-wallpaper.timer`
- **Status check**: `systemctl --user status bing-wallpaper.timer`

### Fuzzel Configuration (`fuzzel/fuzzel.ini`)

Fuzzel launcher configuration with custom styling:
- **Prompt**: `> ` (simple prompt)
- **Font**: Adwaita Sans at 12pt
- **DPI-aware**: Enabled for proper scaling
- **Theme**: Dark theme with pink highlights
  - Background: #161616ff (dark gray)
  - Text: #ffffffff (white)
  - Match/Selection: #ee5396ff (pink)
  - Border: #525252ff (gray), 4px width, 4px radius

**Configuration syntax**: Fuzzel uses INI format with specific section names:
- `[main]` - General options (prompt, font, dpi-aware)
- `[colors]` - Color customization
- `[border]` - Border styling (width, radius)
- `[dmenu]` - Dmenu mode options
- `[key-bindings]` - Custom keybindings

**Validation**: Test configuration with `fuzzel --check-config`

**Common mistake**: Do NOT use separate sections for each option (e.g., `[prompt]`, `[font]`). All general options go in `[main]` section with `key=value` format.

### SSH Agent (`~/.config/systemd/user/ssh-agent.service`)

SSH agent is configured as a systemd user service for persistent SSH key management:
- **Service file**: `~/.config/systemd/user/ssh-agent.service`
- **Socket location**: `$XDG_RUNTIME_DIR/ssh-agent.socket` (typically `/run/user/1000/ssh-agent.socket`)
- **Environment**: Set via `~/.config/environment.d/ssh-agent.conf`
- **Fish shell integration**: `~/.config/fish/config.fish` exports `SSH_AUTH_SOCK`

**Management**:
```bash
# Check status
systemctl --user status ssh-agent.service

# Restart if needed
systemctl --user restart ssh-agent.service

# Add SSH keys
ssh-add ~/.ssh/id_ed25519
```

The SSH agent starts automatically on login and persists across shell sessions.

## Common Tasks

### Installing Configuration on Fresh System

Use the `install.sh` script to deploy configuration on a new installation:
```bash
cd /path/to/dotfiles/cachyos/sway
./install.sh
```

The script will:
- Optionally install packages from `pkglist.txt`
- Create necessary directories (`~/.config/sway`, `~/.config/waybar`, `~/.config/fuzzel`, `~/.config/kitty`)
- Symlink configuration files to `~/.config/` (Sway, Waybar, Fuzzel, Kitty)
- Install Bing wallpaper updater script to `~/.local/bin/`
- Deploy and enable systemd timer for daily wallpaper updates
- Check for required dependencies

**IMPORTANT**: When adding new configuration files or dependencies, update `install.sh`:
- Add new files to the symlinking section
- Add new critical packages to the `critical_packages` array
- Test the script on a fresh installation or VM

### Editing Configuration Files

When modifying Sway or Waybar configs:
1. Edit the config files (`config` for Sway, or `waybar/config`, `waybar/style.css` for Waybar)
2. The nested `waybar/waybar/` directory appears to contain backups/alternatives
3. After editing Sway config: Reload with `$mod+Shift+c` or `swaymsg reload`
4. After editing Waybar: Restart waybar with `pkill waybar && waybar &`
5. **Remember**: If you add new config files, update `install.sh` to include them

### Testing Configuration Changes

**Sway**:
```bash
# Validate config syntax
sway -C

# Reload configuration (or use $mod+Shift+c keybind)
swaymsg reload
```

**Waybar**:
```bash
# Kill and restart waybar
pkill waybar && waybar &

# Or restart from sway
swaymsg reload
```

### Querying System State

```bash
# List outputs (monitors)
swaymsg -t get_outputs

# List inputs (keyboard/mouse/touchpad)
swaymsg -t get_inputs

# List workspaces
swaymsg -t get_workspaces

# Get current window tree
swaymsg -t get_tree
```

### Package Management

The `pkglist.txt` contains 251 packages for CachyOS system setup:
```bash
# Install packages from list
sudo pacman -S --needed - < pkglist.txt

# Generate new package list
pacman -Qqe > pkglist.txt
```

### Managing Bing Wallpaper Updates

The wallpaper system runs automatically via systemd timer:

```bash
# Check timer status and next run time
systemctl --user status bing-wallpaper.timer

# View recent wallpaper update logs
journalctl --user -u bing-wallpaper.service -n 20

# Manually trigger wallpaper update
~/.local/bin/update-bing-wallpaper.sh

# Stop/disable automatic updates
systemctl --user stop bing-wallpaper.timer
systemctl --user disable bing-wallpaper.timer

# Re-enable automatic updates
systemctl --user enable --now bing-wallpaper.timer
```

The wallpaper updates daily at midnight and 5 minutes after boot. After downloading, Sway automatically reloads to display the new wallpaper.

### Firmware Updates

Lenovo ThinkPad X1 Carbon 13th generation supports firmware updates on Linux via **fwupd** (Firmware Update Daemon):

```bash
# Install fwupd
sudo pacman -S fwupd

# Refresh metadata
fwupdmgr refresh

# Check for updates
fwupdmgr get-updates

# Install all available updates
fwupdmgr update

# Check update history
fwupdmgr get-history
```

**What can be updated**:
- System firmware (BIOS/UEFI)
- Embedded Controller (EC)
- Thunderbolt controller
- NVMe SSD firmware
- UEFI Secure Boot database (dbx)
- Other device firmware

**Important**:
- System must be plugged into AC power for firmware updates
- Updates require a reboot to apply
- Do not disconnect power during firmware update process
- Update process happens during boot before OS loads

## Configuration Integration Points

- **Sway includes system configs**: Line 245 of sway/config: `include /etc/sway/config.d/*`
- **Sway wallpaper**: Line 27 of sway/config: `output * bg ~/.local/share/backgrounds/bing-daily.jpg fill`
- **Waybar power menu**: References `$HOME/.config/waybar/power_menu.xml` (must be deployed to home directory)
- **Waybar weather**: References `$HOME/.config/waybar/weather.sh` (requires curl and wttr.in API access)
- **Waybar media player**: Requires `playerctl` package for media controls
- **Waybar font dependency**: Requires FontAwesome for icon rendering
- **Kitty terminal**: Referenced in sway/config as `$term` variable
- **Wallpaper system**: Requires systemd user service and curl/python3 for Bing API access

**Config deployment**: These files are symlinked or copied by `install.sh`:
  - `~/.config/sway/config` (symlink)
  - `~/.config/waybar/config` (symlink)
  - `~/.config/waybar/style.css` (symlink)
  - `~/.config/waybar/power_menu.xml` (symlink)
  - `~/.config/waybar/weather.sh` (symlink)
  - `~/.config/fuzzel/fuzzel.ini` (symlink)
  - `~/.config/kitty/kitty.conf` (symlink)
  - `~/.local/bin/update-bing-wallpaper.sh` (copy, executable)
  - `~/.config/systemd/user/bing-wallpaper.service` (copy)
  - `~/.config/systemd/user/bing-wallpaper.timer` (copy)

**Additional system configuration** (not managed by install.sh):
  - `~/.config/systemd/user/ssh-agent.service` - SSH agent systemd service
  - `~/.config/environment.d/ssh-agent.conf` - SSH agent environment variable
  - `~/.config/fish/config.fish` - Fish shell configuration with SSH agent and editor settings

## Key Behaviors and Conventions

- **Keybindings help**: Press `$mod+/` to show searchable keybindings cheatsheet in fuzzel
- **Vim keybindings**: Window navigation uses hjkl (with arrow key alternatives)
- **Mod key**: All shortcuts use Super/Windows key (Mod4), not Alt
- **Workspace management**: 10 workspaces (1-0) with Shift modifier for moving containers
- **Floating windows**: `$mod+drag` for move, `$mod+right-click` for resize
- **Layout modes**: Stacking (`$mod+s`), tabbed (`$mod+w`), split toggle (`$mod+e`)
- **Scratchpad**: Hidden window storage (`$mod+Shift+minus` to send, `$mod+minus` to retrieve)

## Keybindings Cheatsheet

The `show-keybindings.sh` script displays all Sway keybindings in a searchable fuzzel popup:
- Trigger with `$mod+/` (Super+Slash)
- Type to filter/search keybindings
- Organized by category (Basics, Navigation, Workspaces, Layouts, etc.)
- **Updating**: When adding new keybindings to `sway/config`, update `show-keybindings.sh` to keep the cheatsheet current
