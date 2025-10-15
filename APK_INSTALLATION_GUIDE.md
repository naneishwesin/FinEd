# 📱 APK Installation Guide

## 🔗 Current QR Code Link
```
http://10.120.121.89:8001/build/app/outputs/flutter-apk/app-release.apk
```

## ✅ Server Status
- ✅ Server is running on port 8001
- ✅ APK file exists (53.8MB)
- ✅ HTTP 200 responses confirmed
- ✅ Content-Type: application/vnd.android.package-archive

## 🔧 Common Installation Issues & Solutions

### 1. "Download Failed" or "Network Error"
**Problem**: Phone can't reach the server
**Solutions**:
- Ensure phone and computer are on the same WiFi network
- Check if firewall is blocking port 8001
- Try using mobile data instead of WiFi
- Restart the Python server: `python3 simple_share.py`

### 2. "Install Blocked" or "Unknown Sources"
**Problem**: Android security prevents installation
**Solutions**:
- Go to **Settings** → **Security** → **Install unknown apps**
- Enable "Allow from this source" for your browser (Chrome, Firefox, etc.)
- Alternative: **Settings** → **Apps** → **Special access** → **Install unknown apps**

### 3. "QR Code Not Working"
**Problem**: QR scanner can't read the code
**Solutions**:
- Copy the URL manually: `http://10.120.121.89:8001/build/app/outputs/flutter-apk/app-release.apk`
- Use a different QR scanner app
- Ensure good lighting and steady hands
- Try scanning from different distances

### 4. "File Not Found" Error
**Problem**: Server can't find the APK file
**Solutions**:
- Check if APK exists: `ls -la build/app/outputs/flutter-apk/app-release.apk`
- Rebuild APK: `flutter build apk --release`
- Restart server: `python3 simple_share.py`

## 🛠️ Alternative Installation Methods

### Method 1: ADB Installation (Recommended for Developers)
```bash
# Enable USB Debugging on phone first
./install_apk.sh
```

### Method 2: Cloud Storage
1. Upload APK to Google Drive/Dropbox
2. Share the link
3. Download and install from phone

### Method 3: Email Transfer
1. Email the APK file to yourself
2. Download attachment on phone
3. Install from Downloads folder

### Method 4: USB Cable
1. Connect phone to computer via USB
2. Copy APK to phone's Downloads folder
3. Install using file manager

## 🔍 Troubleshooting Steps

### Step 1: Verify Server
```bash
curl -I http://10.120.121.89:8001/build/app/outputs/flutter-apk/app-release.apk
```
Should return: `HTTP/1.0 200 OK`

### Step 2: Check Network
- Ensure both devices are on same WiFi
- Test with `ping 10.120.121.89` from phone
- Try different network if needed

### Step 3: Test Download
- Open URL directly in phone browser
- Check if download starts
- Verify file size (53.8MB)

### Step 4: Check Permissions
- Enable "Unknown Sources" in Android settings
- Allow browser to install apps
- Check storage space on phone

## 📞 Support

If all else fails:
1. Use ADB installation method
2. Try cloud storage sharing
3. Check Android version compatibility
4. Ensure sufficient storage space (100MB+)

## 🎯 Quick Fix Commands

```bash
# Restart server
cd /Users/naneishwesinhlaing/Desktop/Flatter/expense_tracker
python3 simple_share.py

# Check server status
curl -I http://10.120.121.89:8001/build/app/outputs/flutter-apk/app-release.apk

# ADB install (if USB connected)
./install_apk.sh
```
