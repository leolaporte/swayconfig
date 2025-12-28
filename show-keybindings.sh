#!/usr/bin/env bash
# Sway Keybindings Cheatsheet
# Displays keybindings in fuzzel for quick reference

# Format: "KEYBINDING | DESCRIPTION"
cat <<EOF | fuzzel --dmenu --prompt "Sway Keybindings: " --width 60
=== BASICS ===
Super+Return | Open terminal (kitty)
Super+D | Application launcher (fuzzel)
Super+Shift+Q | Kill focused window
Super+Shift+C | Reload Sway configuration
Super+Shift+E | Exit Sway (logout)

=== WINDOW NAVIGATION ===
Super+H/J/K/L | Focus left/down/up/right (Vim keys)
Super+Arrows | Focus left/down/up/right
Super+Shift+H/J/K/L | Move window left/down/up/right
Super+Shift+Arrows | Move window left/down/up/right

=== WORKSPACES ===
Super+1-0 | Switch to workspace 1-10
Super+Shift+1-0 | Move window to workspace 1-10

=== LAYOUTS ===
Super+B | Split horizontal
Super+V | Split vertical
Super+S | Stacking layout
Super+W | Tabbed layout
Super+E | Toggle split layout
Super+F | Toggle fullscreen
Super+R | Enter resize mode

=== FLOATING WINDOWS ===
Super+Shift+Space | Toggle floating mode
Super+Space | Toggle focus (tiling/floating)
Super+Left Click | Drag floating window
Super+Right Click | Resize floating window

=== SCRATCHPAD ===
Super+Shift+Minus | Send to scratchpad
Super+Minus | Show/hide scratchpad

=== PARENT/CHILD ===
Super+A | Focus parent container

=== RESIZE MODE ===
H/J/K/L or Arrows | Resize in resize mode
Return or Escape | Exit resize mode

=== MEDIA & UTILITIES ===
Volume Up/Down | Adjust volume
Mute | Toggle mute
Mic Mute | Toggle microphone mute
Brightness Up/Down | Adjust screen brightness
Print Screen | Take screenshot (grim)
EOF
