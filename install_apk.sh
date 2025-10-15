#!/bin/bash

# Install APK via ADB
echo "Installing APK via ADB..."

# Set ADB path
ADB_PATH="/Users/naneishwesinhlaing/Library/Android/sdk/platform-tools/adb"

# Check if ADB is available
if [ ! -f "$ADB_PATH" ]; then
    echo "ADB not found at $ADB_PATH"
    echo "Please install Android SDK platform-tools"
    exit 1
fi

# Check if device is connected
if ! "$ADB_PATH" devices | grep -q "device$"; then
    echo "No Android device connected. Please:"
    echo "1. Enable Developer Options on your phone"
    echo "2. Enable USB Debugging"
    echo "3. Connect via USB"
    echo "4. Accept the debugging prompt on your phone"
    exit 1
fi

# Install the APK
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
    echo "Installing $APK_PATH..."
    "$ADB_PATH" install -r "$APK_PATH"
    echo "Installation complete!"
else
    echo "APK file not found at $APK_PATH"
    echo "Please build the APK first: flutter build apk --release"
    exit 1
fi
