#!/usr/bin/env bash

# ShinigamiNix Logo Setup Script

echo "Setting up ShinigamiNix boot logo..."

LOGO_DIR="assets/plymouth"
LOGO_FILE="$LOGO_DIR/logo.png"

# Check if logo directory exists
if [ ! -d "$LOGO_DIR" ]; then
    echo "Error: Plymouth directory not found at $LOGO_DIR"
    exit 1
fi

# Check if logo file exists
if [ ! -f "$LOGO_FILE" ]; then
    echo "❌ Logo file not found at $LOGO_FILE"
    echo ""
    echo "Please save your ShinigamiNix logo as 'logo.png' in the $LOGO_DIR directory"
    echo ""
    echo "Recommended specifications:"
    echo "  - Format: PNG"
    echo "  - Size: 300x300 pixels (or similar square ratio)"
    echo "  - Background: Transparent or black"
    echo ""
    echo "The logo shows a cute grim reaper character which will look great on boot!"
    exit 1
else
    echo "✅ Logo found at $LOGO_FILE"
    
    # Get image dimensions
    if command -v identify >/dev/null 2>&1; then
        DIMENSIONS=$(identify -format "%wx%h" "$LOGO_FILE")
        echo "📏 Logo dimensions: $DIMENSIONS"
    fi
    
    echo ""
    echo "🎉 Boot logo setup complete!"
    echo "Your ShinigamiNix logo will now display during boot with:"
    echo "  - Centered positioning"
    echo "  - Black background"
    echo "  - Golden progress bar"
    echo "  - Clean, minimal design"
fi
