#!/usr/bin/env bash
# Installation script for Sway and Waybar dotfiles
# This script deploys configuration files to ~/.config/

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================"
echo "Sway/Waybar Configuration Installer"
echo "======================================"
echo ""
echo "Script directory: $SCRIPT_DIR"
echo ""

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Validate required files exist in the repository
echo "Validating repository structure..."
required_files=(
    "$SCRIPT_DIR/config"
    "$SCRIPT_DIR/waybar/config"
    "$SCRIPT_DIR/waybar/style.css"
    "$SCRIPT_DIR/waybar/power_menu.xml"
    "$SCRIPT_DIR/waybar/weather.sh"
    "$SCRIPT_DIR/fuzzel/fuzzel.ini"
    "$SCRIPT_DIR/kitty/kitty.conf"
    "$SCRIPT_DIR/scripts/update-bing-wallpaper.sh"
    "$SCRIPT_DIR/systemd/bing-wallpaper.service"
    "$SCRIPT_DIR/systemd/bing-wallpaper.timer"
    "$SCRIPT_DIR/show-keybindings.sh"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [ ! -e "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
    print_error "Missing required files in repository:"
    printf '%s\n' "${missing_files[@]}"
    echo ""
    print_error "Please ensure you're running this script from the correct directory"
    exit 1
fi
print_success "All required files found"
echo ""

# Function to create symlink safely
create_symlink() {
    local source="$1"
    local target="$2"

    # Validate source exists
    if [ ! -e "$source" ]; then
        print_error "Source file does not exist: $source"
        return 1
    fi

    if [ -L "$target" ]; then
        print_warning "Symlink already exists: $target (removing old symlink)"
        rm "$target"
    elif [ -e "$target" ]; then
        print_warning "File exists: $target (backing up to ${target}.backup)"
        mv "$target" "${target}.backup"
    fi

    ln -s "$source" "$target"
    print_success "Linked: $target -> $source"
}

# Check if running on CachyOS/Arch
if ! command -v pacman &> /dev/null; then
    print_error "This script is designed for Arch-based systems with pacman"
    exit 1
fi

# Ask about package installation
echo "Would you like to install packages from pkglist.txt? (y/n)"
read -r install_packages

if [[ "$install_packages" =~ ^[Yy]$ ]]; then
    if [ -f "$SCRIPT_DIR/pkglist.txt" ]; then
        print_warning "Installing packages from pkglist.txt (this requires sudo)"
        sudo pacman -S --needed - < "$SCRIPT_DIR/pkglist.txt"
        print_success "Packages installed"
    else
        print_error "pkglist.txt not found"
    fi
else
    print_warning "Skipping package installation"
fi

# Create config directories
echo ""
echo "Creating configuration directories..."
mkdir -p ~/.config/sway
mkdir -p ~/.config/waybar
mkdir -p ~/.config/fuzzel
mkdir -p ~/.config/kitty
print_success "Directories created"

# Symlink Sway configuration
echo ""
echo "Setting up Sway configuration..."
create_symlink "$SCRIPT_DIR/config" "$HOME/.config/sway/config"
create_symlink "$SCRIPT_DIR/show-keybindings.sh" "$HOME/.config/sway/show-keybindings.sh"

# Symlink Waybar configuration files
echo ""
echo "Setting up Waybar configuration..."
create_symlink "$SCRIPT_DIR/waybar/config" "$HOME/.config/waybar/config"
create_symlink "$SCRIPT_DIR/waybar/style.css" "$HOME/.config/waybar/style.css"
create_symlink "$SCRIPT_DIR/waybar/power_menu.xml" "$HOME/.config/waybar/power_menu.xml"
create_symlink "$SCRIPT_DIR/waybar/weather.sh" "$HOME/.config/waybar/weather.sh"
chmod +x "$HOME/.config/waybar/weather.sh"

# Symlink Fuzzel configuration
echo ""
echo "Setting up Fuzzel configuration..."
create_symlink "$SCRIPT_DIR/fuzzel/fuzzel.ini" "$HOME/.config/fuzzel/fuzzel.ini"

# Symlink Kitty configuration
echo ""
echo "Setting up Kitty configuration..."
create_symlink "$SCRIPT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# Install wallpaper script and systemd timer
echo ""
echo "Setting up Bing wallpaper updater..."
mkdir -p ~/.local/bin
mkdir -p ~/.config/systemd/user
cp "$SCRIPT_DIR/scripts/update-bing-wallpaper.sh" "$HOME/.local/bin/update-bing-wallpaper.sh"
chmod +x "$HOME/.local/bin/update-bing-wallpaper.sh"
cp "$SCRIPT_DIR/systemd/bing-wallpaper.service" "$HOME/.config/systemd/user/bing-wallpaper.service"
cp "$SCRIPT_DIR/systemd/bing-wallpaper.timer" "$HOME/.config/systemd/user/bing-wallpaper.timer"
systemctl --user daemon-reload
systemctl --user enable --now bing-wallpaper.timer
print_success "Wallpaper updater installed and enabled"

# Check for required packages
echo ""
echo "Checking for critical dependencies..."

critical_packages=(
    "sway"
    "waybar"
    "kitty"
    "fuzzel"
    "firefox"
    "pulseaudio"
    "brightnessctl"
    "grim"
    "swaylock"
    "swayidle"
    "curl"
)

missing_packages=()

for package in "${critical_packages[@]}"; do
    if ! pacman -Qi "$package" &> /dev/null; then
        missing_packages+=("$package")
        print_warning "Missing: $package"
    else
        print_success "Found: $package"
    fi
done

if [ ${#missing_packages[@]} -gt 0 ]; then
    echo ""
    print_warning "The following critical packages are missing:"
    printf '%s\n' "${missing_packages[@]}"
    echo ""
    echo "Install them with:"
    echo "  sudo pacman -S ${missing_packages[*]}"
else
    echo ""
    print_success "All critical dependencies are installed"
fi

# Check for FontAwesome
echo ""
echo "Checking for FontAwesome fonts..."
if fc-list | grep -i "fontawesome" &> /dev/null; then
    print_success "FontAwesome fonts found"
else
    print_warning "FontAwesome fonts not found. Waybar icons may not display correctly."
    echo "  Install with: sudo pacman -S ttf-font-awesome"
fi

# Final message
echo ""
echo "======================================"
print_success "Installation complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "  1. Log out of your current session"
echo "  2. Select Sway from your display manager"
echo "  3. Log in to start Sway with your new configuration"
echo ""
echo "Or, if already in Sway:"
echo "  • Reload Sway: Super+Shift+C"
echo "  • Restart Waybar: pkill waybar && waybar &"
echo ""
echo "Configuration files are symlinked from:"
echo "  $SCRIPT_DIR"
echo ""
echo "Any changes to files in the repository will be reflected immediately."
echo ""
