#!/bin/bash
# start_local_server.sh - Start a local file server for APK sharing

echo "🚀 Starting local file server for APK sharing..."
echo ""

# Get your local IP address
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
PORT=8080

echo "📱 Your APK file: build/app/outputs/flutter-apk/app-release.apk"
echo "🌐 Local server will start at: http://$LOCAL_IP:$PORT"
echo ""
echo "📋 Instructions:"
echo "1. Make sure your phone is on the same WiFi network"
echo "2. Scan QR code with phone camera"
echo "3. Download APK directly to your phone"
echo "4. Enable 'Install from Unknown Sources'"
echo "5. Install the app"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start Python HTTP server
cd build/app/outputs/flutter-apk
python3 -m http.server $PORT
