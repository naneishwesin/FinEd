#!/bin/bash
# get_local_ip.sh - Get your local IP address for QR code sharing

echo "🌐 Getting your local IP address..."
echo ""

# Get local IP address
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

if [ -z "$LOCAL_IP" ]; then
    echo "❌ Could not find local IP address"
    echo "Please check your network connection"
    exit 1
fi

echo "📱 Your local IP address: $LOCAL_IP"
echo ""
echo "🔗 Your APK download URL will be:"
echo "   http://$LOCAL_IP:8080/app-release.apk"
echo ""
echo "📋 Next steps:"
echo "1. Build APK: flutter build apk --release"
echo "2. Start server: ./start_local_server.sh"
echo "3. Update QR code URL in the app"
echo "4. Share QR code with others on same WiFi"
echo ""
echo "💡 Tip: Make sure your phone is on the same WiFi network!"
