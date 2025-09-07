# ShinigamiNix Logo Setup

To complete the bootup logo setup, you need to:

1. Save the ShinigamiNix logo image as `logo.png` in the `assets/plymouth/` directory
2. The image should be approximately 300x300 pixels for best results
3. PNG format with transparent background works best

The logo will be displayed centered on the screen during boot with:
- Black background
- Golden/brown progress bar (#D4B896)
- Centered ShinigamiNix logo

## Converting the logo:
If you need to convert the image format or resize it, you can use:
```bash
# Resize to optimal size
convert your-logo.png -resize 300x300 assets/plymouth/logo.png

# Or if you want to maintain aspect ratio
convert your-logo.png -resize 300x300\> assets/plymouth/logo.png
```
