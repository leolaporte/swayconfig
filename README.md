# Sway + Waybar Configuration for CachyOS

A complete Sway window manager configuration with Waybar status bar, designed for CachyOS Linux. Features vim-style navigation, automatic wallpaper updates, and a polished dark theme.

## Features

- **Sway Window Manager**: Tiling Wayland compositor with i3-compatible configuration
- **Waybar Status Bar**: Customized with weather widget, media player controls, system monitors
- **Vim-Style Navigation**: hjkl keybindings for window and workspace management
- **Daily Wallpaper Updates**: Automatic Bing Photo of the Day downloads via systemd timer
- **Kitty Terminal**: Fast, GPU-accelerated terminal with Iosevka font
- **Fuzzel Launcher**: Lightweight Wayland-native application launcher
- **Keybinding Cheatsheet**: Press `Super+/` for searchable keybindings reference
- **One-Command Installation**: Automated setup script for fresh installations

## Quick Start

### Installation

```bash
git clone git@github.com:leolaporte/swayconfig.git
cd swayconfig
./install.sh
```

The installation script will:
- Create necessary directories in `~/.config/`
- Symlink configuration files
- Install the Bing wallpaper updater
- Set up systemd timers for automatic wallpaper updates
- Check for required dependencies

### Required Packages

Critical dependencies (install via pacman):
```bash
sudo pacman -S sway waybar kitty fuzzel grim swaylock swayidle \
               pulseaudio brightnessctl playerctl curl python3
```

For complete system setup, install all packages from `pkglist.txt`:
```bash
sudo pacman -S --needed - < pkglist.txt
```

## Key Bindings

### Essential Shortcuts

| Shortcut | Action |
|----------|--------|
| `Super+Return` | Launch terminal (Kitty) |
| `Super+d` | Application launcher (Fuzzel) |
| `Super+Shift+q` | Close focused window |
| `Super+Shift+c` | Reload Sway configuration |
| `Super+Shift+e` | Exit Sway |
| `Super+/` | Show keybindings cheatsheet |

### Window Navigation (Vim-style)

| Shortcut | Action |
|----------|--------|
| `Super+h/j/k/l` | Move focus left/down/up/right |
| `Super+Shift+h/j/k/l` | Move window left/down/up/right |
| `Super+Arrow Keys` | Alternative navigation |

### Workspaces

| Shortcut | Action |
|----------|--------|
| `Super+1-0` | Switch to workspace 1-10 |
| `Super+Shift+1-0` | Move window to workspace 1-10 |

### Layouts

| Shortcut | Action |
|----------|--------|
| `Super+b` | Split horizontally |
| `Super+v` | Split vertically |
| `Super+s` | Stacking layout |
| `Super+w` | Tabbed layout |
| `Super+e` | Toggle split layout |
| `Super+f` | Toggle fullscreen |
| `Super+Shift+Space` | Toggle floating |

### Applications

| Shortcut | Action |
|----------|--------|
| `Super+Shift+b` | Firefox |
| `Super+Ctrl+e` | Emacs |
| `Print` | Screenshot (grim) |

### Media Controls

| Shortcut | Action |
|----------|--------|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Mute toggle |
| `XF86MonBrightnessUp/Down` | Screen brightness |

## Configuration Overview

### Sway (`config`)

Main window manager configuration:
- **Mod Key**: Super (Windows key)
- **Terminal**: Kitty
- **Launcher**: Fuzzel
- **Input**: Caps Lock remapped to Ctrl, touchpad tap-to-click enabled
- **Wallpaper**: `~/.local/share/backgrounds/bing-daily.jpg`
- **Idle Management**: Screen lock with swaylock after 300 seconds

### Waybar (`waybar/config`)

Status bar with three sections:
- **Left**: Workspaces, mode indicator, scratchpad count, weather, media player
- **Center**: Window title
- **Right**: Idle inhibitor, CPU usage, battery, volume, system tray, clock, power menu

**Custom Widgets**:
- Weather: Fetches current conditions from wttr.in
- Media Player: Shows currently playing track (requires playerctl)
- Power Menu: Logout/reboot/shutdown via GTK menu

**Styling** (`waybar/style.css`):
- Dark theme with 85% opacity (#333333)
- Blue active workspace (#285577)
- FontAwesome icons throughout
- Red battery warning with blink animation

### Kitty Terminal (`kitty/kitty.conf`)

Terminal emulator configuration:
- **Font**: Iosevka 16pt
- Extensive theming and behavior customization
- GPU-accelerated rendering

### Fuzzel Launcher (`fuzzel/fuzzel.ini`)

Wayland-native application launcher configuration.

## Automatic Wallpaper Updates

The configuration includes an automated Bing Photo of the Day wallpaper system:

**How it works**:
- Downloads daily wallpaper from Bing API
- Saves to `~/.local/share/backgrounds/bing-daily.jpg`
- Automatically reloads Sway to apply new wallpaper
- Runs daily at midnight and 5 minutes after boot

**Manual control**:
```bash
# Trigger update manually
~/.local/bin/update-bing-wallpaper.sh

# Check timer status
systemctl --user status bing-wallpaper.timer

# View recent logs
journalctl --user -u bing-wallpaper.service -n 20

# Disable automatic updates
systemctl --user disable bing-wallpaper.timer
```

## File Structure

```
.
├── README.md                          # This file
├── CLAUDE.md                          # Claude Code instructions
├── install.sh                         # Installation script
├── pkglist.txt                        # CachyOS package list (241 packages)
├── config                             # Sway window manager config
├── show-keybindings.sh                # Keybindings cheatsheet script
├── fuzzel/
│   └── fuzzel.ini                    # Fuzzel launcher config
├── kitty/
│   └── kitty.conf                    # Kitty terminal config
├── scripts/
│   └── update-bing-wallpaper.sh      # Wallpaper updater script
├── systemd/
│   ├── bing-wallpaper.service        # Systemd service
│   └── bing-wallpaper.timer          # Systemd timer
└── waybar/
    ├── config                         # Waybar configuration
    ├── style.css                      # Waybar styling
    ├── power_menu.xml                 # Power menu definition
    └── weather.sh                     # Weather widget script
```

## Customization

### Change Wallpaper Location

Edit `config` line 27:
```bash
output * bg /path/to/your/wallpaper.jpg fill
```

To disable automatic Bing wallpaper updates:
```bash
systemctl --user disable bing-wallpaper.timer
```

### Modify Weather Location

Edit `waybar/weather.sh` and change the coordinates:
```bash
curl -s 'https://wttr.in/YOUR_LAT,YOUR_LON?format=%t+%C&u'
```

### Change Terminal or Launcher

Edit `config` variables section:
```bash
set $term your-terminal
set $menu your-launcher
```

### Add Custom Keybindings

Edit `config` and add your keybindings. Remember to update `show-keybindings.sh` to keep the cheatsheet current.

## Testing Configuration

### Validate Sway Config

```bash
sway -C
```

### Reload Sway

```bash
swaymsg reload
# or press Super+Shift+c
```

### Restart Waybar

```bash
pkill waybar && waybar &
```

## Troubleshooting

### Waybar icons not showing

Install FontAwesome fonts:
```bash
sudo pacman -S ttf-font-awesome
```

### Weather widget shows "Weather unavailable"

Check network connection and wttr.in availability:
```bash
curl 'https://wttr.in/?format=%t+%C'
```

### Wallpaper not updating

Check systemd timer status:
```bash
systemctl --user status bing-wallpaper.timer
journalctl --user -u bing-wallpaper.service
```

## System Information

- **OS**: CachyOS Linux (Arch-based)
- **Display Server**: Wayland
- **Window Manager**: Sway
- **Status Bar**: Waybar
- **Terminal**: Kitty
- **Launcher**: Fuzzel

## Credits

Configuration created for CachyOS Linux using Sway and Waybar.

## License

Feel free to use and modify this configuration for your own setup.
