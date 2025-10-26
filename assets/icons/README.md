# App Icons

This directory contains the app icon for Audio Bookshelf UI.

## Files

- `app_icon.svg` - Source SVG file for the app icon
- `app_icon.png` - Generated PNG file (1024x1024) for icon generation

## Icon Design

The current icon features:
- **Open book** with visible pages
- **Headphones** positioned on top
- **Sound waves** emanating from the headphones
- **Indigo background** (#6366F1) for a modern, professional look

## Generating Icons

### Automatic (Recommended)

1. Convert SVG to PNG:
   - Upload `app_icon.svg` to https://icon.kitchen/
   - Download as 1024x1024 PNG
   - Save as `app_icon.png`

2. Generate all sizes:
```bash
flutter pub get
dart run flutter_launcher_icons
```

### Manual

See `ICON_DESIGN_GUIDE.md` and `QUICK_ICON_SETUP.md` in the project root for detailed instructions.

## Design Variations

You can customize the icon by editing `app_icon.svg`. The SVG uses:
- Simple shapes for scalability
- High contrast colors for visibility
- Minimal detail for clarity at small sizes

## Color Scheme

- Background: #6366F1 (Indigo)
- Book/Headphones: #FFFFFF (White)
- Borders: #4F46E5 (Dark Indigo)
- Text Lines: #E5E7EB (Light Gray)

## Platform Support

Icons are automatically generated for:
- ✅ iOS (iPhone & iPad)
- ✅ Android (Adaptive Icons)
- ✅ Android
- ✅ iOS
