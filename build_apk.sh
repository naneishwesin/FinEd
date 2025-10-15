#!/bin/bash
# build_apk.sh - Script to build APK for sharing

echo "🔨 Building Expense Tracker APK..."

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build APK
flutter build apk --release

echo "✅ APK built successfully!"
echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "📋 Next steps:"
echo "1. Upload APK to a file hosting service (Google Drive, Dropbox, etc.)"
echo "2. Get the public download link"
echo "3. Update the URL in QRSharePage"
echo "4. Users can scan QR code to download and install"
echo ""
echo "🔗 Example hosting services:"
echo "   - Google Drive: Upload file → Share → Copy link"
echo "   - Dropbox: Upload file → Share → Copy link"
echo "   - GitHub Releases: Create release → Upload APK"
echo ""
echo "📱 To test QR code:"
echo "1. Run the app: flutter run"
echo "2. Go to Settings → Share App"
echo "3. Scan QR code with phone camera"
