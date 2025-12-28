#!/bin/bash
# Download Bing Photo of the Day and update Sway wallpaper

set -e

# Get Bing API response
API_RESPONSE=$(curl -sf 'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US')

if [ -z "$API_RESPONSE" ]; then
    echo "Error: Failed to fetch Bing API data" >&2
    exit 1
fi

# Extract image URL
BING_URL=$(echo "$API_RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print('https://www.bing.com' + data['images'][0]['url'])")

if [ -z "$BING_URL" ] || [ "$BING_URL" = "https://www.bing.com" ]; then
    echo "Error: Failed to parse image URL" >&2
    exit 1
fi

# Download to temporary file
TEMP_FILE="/tmp/bing-wallpaper-$$.jpg"
if ! curl -sf "$BING_URL" -o "$TEMP_FILE"; then
    echo "Error: Failed to download wallpaper from $BING_URL" >&2
    exit 1
fi

# Verify file was downloaded and has content
if [ ! -s "$TEMP_FILE" ]; then
    echo "Error: Downloaded file is empty" >&2
    rm -f "$TEMP_FILE"
    exit 1
fi

# Create directory if it doesn't exist
mkdir -p ~/.local/share/backgrounds

# Move to permanent location
mv "$TEMP_FILE" ~/.local/share/backgrounds/bing-daily.jpg

# Reload sway to apply new wallpaper (only if running)
if pgrep -x sway > /dev/null; then
    swaymsg reload
fi

echo "Wallpaper updated: $(date)"
