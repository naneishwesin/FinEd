# 📱 Android App QR Code Sharing Guide

## Overview
This guide explains how to share your Android Expense Tracker app using QR codes for easy installation on other devices.

## 🚀 Quick Start

### Step 1: Build the APK
```bash
flutter build apk --release
```

### Step 2: Get Your Local IP Address
```bash
./get_local_ip.sh
```
This will show your local IP address (e.g., `192.168.1.100`)

### Step 3: Start Local File Server
```bash
./start_local_server.sh
```
This starts a web server to serve the APK file.

### Step 4: Update QR Code URL
In the app, go to **Settings → Share App** and update the URL:
- Replace `YOUR_LOCAL_IP` with your actual IP
- Example: `http://192.168.1.100:8080/app-release.apk`

### Step 5: Share the QR Code
- Others can scan the QR code with their phone camera
- They'll be able to download and install the APK directly

## 📋 Detailed Instructions

### For the App Developer (You):
1. **Build APK**: Run `flutter build apk --release`
2. **Get IP**: Run `./get_local_ip.sh` to get your local IP
3. **Start Server**: Run `./start_local_server.sh` to start the file server
4. **Update App**: In the app, go to Settings → Share App and update the URL
5. **Share**: Show the QR code to others on the same WiFi network

### For App Users (Recipients):
1. **Same WiFi**: Make sure you're on the same WiFi network as the developer
2. **Scan QR Code**: Use your phone camera to scan the QR code
3. **Download APK**: The phone will open the download link
4. **Enable Unknown Sources**: Go to Settings → Security → Install from Unknown Sources
5. **Install**: Tap the downloaded APK file to install
6. **Launch**: Open the Expense Tracker app

## 🔧 Troubleshooting

### QR Code Not Working?
- Check if the local server is running (`./start_local_server.sh`)
- Verify the IP address is correct
- Make sure both devices are on the same WiFi network
- Try copying the URL manually using the "Copy Download Link" button

### APK Won't Install?
- Enable "Install from Unknown Sources" in Android Settings
- Check if the APK file downloaded completely
- Try downloading again if the file seems corrupted

### Server Not Starting?
- Make sure port 8080 is not being used by another application
- Check your firewall settings
- Try a different port by editing `start_local_server.sh`

## 📁 File Locations

- **APK File**: `build/app/outputs/flutter-apk/app-release.apk`
- **Build Script**: `build_apk.sh`
- **Server Script**: `start_local_server.sh`
- **IP Script**: `get_local_ip.sh`

## 🌐 Alternative Sharing Methods

### USB Connection
1. Enable USB Debugging on the phone
2. Connect via USB cable
3. Run `flutter run` on your computer
4. Select the connected device

### Direct APK Transfer
1. Build APK: `flutter build apk --release`
2. Transfer APK file to phone (email, cloud storage, etc.)
3. Install APK on phone

### Cloud Hosting
1. Upload APK to Google Drive, Dropbox, or GitHub Releases
2. Get the public download link
3. Update the QR code URL in the app
4. Share the QR code

## 💡 Tips

- **WiFi Required**: Both devices must be on the same WiFi network
- **Firewall**: Make sure your firewall allows connections on port 8080
- **Security**: Only share with trusted devices on your network
- **Testing**: Always test the QR code before sharing with others

## 🎯 Success Indicators

✅ QR code scans successfully  
✅ APK downloads to phone  
✅ APK installs without errors  
✅ App launches and works correctly  

---

**Note**: This method is perfect for sharing your app with friends, family, or colleagues on the same network without needing to publish to Google Play Store.