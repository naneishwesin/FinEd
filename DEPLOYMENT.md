# Build Configuration for Production

## Android Build Configuration

### 1. Generate Signed APK
```bash
# Generate keystore (first time only)
keytool -genkey -v -keystore ~/keystores/expense_tracker.jks -keyalg RSA -keysize 2048 -validity 10000 -alias expense_tracker

# Build release APK
flutter build apk --release --target-platform android-arm64

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### 2. Android Configuration Files

#### android/app/build.gradle.kts
```kotlin
android {
    compileSdkVersion 34
    buildToolsVersion "34.0.0"
    
    defaultConfig {
        applicationId "com.expense_tracker.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        
        multiDexEnabled true
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### android/key.properties
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=expense_tracker
storeFile=../keystores/expense_tracker.jks
```

### 3. Firebase Crashlytics Configuration

#### android/app/src/main/AndroidManifest.xml
```xml
<application
    android:name="io.flutter.app.FlutterApplication"
    android:label="Expense Tracker"
    android:icon="@mipmap/ic_launcher">
    
    <!-- Firebase Crashlytics -->
    <meta-data
        android:name="firebase_crashlytics_collection_enabled"
        android:value="true" />
</application>
```

## iOS Build Configuration

### 1. iOS Configuration
```bash
# Build iOS app
flutter build ios --release

# Archive for App Store
flutter build ipa --release
```

### 2. iOS Info.plist
```xml
<key>CFBundleDisplayName</key>
<string>Expense Tracker</string>
<key>CFBundleIdentifier</key>
<string>com.expense_tracker.app</string>
<key>CFBundleVersion</key>
<string>1.0.0</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

## Play Store Checklist

### ✅ App Information
- [ ] App name: "Expense Tracker"
- [ ] App description (short and detailed)
- [ ] App category: Finance
- [ ] Content rating: Everyone
- [ ] Privacy policy URL

### ✅ App Assets
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Screenshots (at least 2, up to 8)
- [ ] Promo video (optional)

### ✅ Technical Requirements
- [ ] Target SDK 34+
- [ ] 64-bit architecture support
- [ ] App bundle (.aab) format
- [ ] Signed with release keystore
- [ ] ProGuard/R8 enabled
- [ ] Firebase Crashlytics integrated

### ✅ Content Policy
- [ ] No misleading content
- [ ] Appropriate content rating
- [ ] Privacy policy compliance
- [ ] Data handling transparency

## Build Scripts

### build_release.sh
```bash
#!/bin/bash

echo "Building Expense Tracker for Production..."

# Clean previous builds
flutter clean
flutter pub get

# Run tests
flutter test

# Build Android App Bundle
flutter build appbundle --release

# Build iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    flutter build ios --release
fi

echo "Build completed successfully!"
```

### deploy.sh
```bash
#!/bin/bash

echo "Deploying Expense Tracker..."

# Run build script
./build_release.sh

# Upload to Firebase App Distribution (optional)
# firebase appdistribution:distribute build/app/outputs/bundle/release/app-release.aab --app YOUR_APP_ID --groups "testers"

echo "Deployment completed!"
```

## Environment Configuration

### .env.production
```env
FIREBASE_PROJECT_ID=your_production_project_id
FIREBASE_API_KEY=your_production_api_key
ENVIRONMENT=production
DEBUG_MODE=false
```

### .env.development
```env
FIREBASE_PROJECT_ID=your_dev_project_id
FIREBASE_API_KEY=your_dev_api_key
ENVIRONMENT=development
DEBUG_MODE=true
```

## Performance Optimization

### 1. ProGuard Rules (android/app/proguard-rules.pro)
```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep your app's classes
-keep class com.expense_tracker.app.** { *; }
```

### 2. Build Optimization
```bash
# Enable tree shaking
flutter build appbundle --release --tree-shake-icons

# Enable split-per-abi
flutter build apk --release --split-per-abi
```

## Monitoring & Analytics

### 1. Firebase Analytics Events
```dart
// Track user actions
FirebaseAnalytics.instance.logEvent(
  name: 'transaction_added',
  parameters: {
    'amount': amount,
    'category': category,
    'type': type,
  },
);
```

### 2. Crashlytics Custom Logging
```dart
// Log custom events
FirebaseCrashlytics.instance.log('User added transaction: $amount');
```

## Security Checklist

### ✅ Data Protection
- [ ] Sensitive data encrypted
- [ ] API keys secured
- [ ] User data anonymized
- [ ] GDPR compliance

### ✅ Authentication
- [ ] Secure authentication flow
- [ ] Token management
- [ ] Session handling
- [ ] Biometric authentication (optional)

### ✅ Network Security
- [ ] HTTPS only
- [ ] Certificate pinning (if needed)
- [ ] API rate limiting
- [ ] Input validation

