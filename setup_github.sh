#!/bin/bash

# 🚀 GitHub Repository Setup Script for Expense Tracker
# This script sets up a new GitHub repository and initializes it with proper structure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_NAME="expense-tracker"
REPO_DESCRIPTION="A comprehensive Flutter expense tracking app with Firebase backend"
REPO_VISIBILITY="private" # Change to "public" if you want it public

echo -e "${BLUE}🚀 Setting up GitHub repository for Expense Tracker...${NC}"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed. Please install Git first.${NC}"
    exit 1
fi

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠️  GitHub CLI is not installed. Installing...${NC}"
    
    # Install GitHub CLI based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install gh
        else
            echo -e "${RED}❌ Homebrew is not installed. Please install GitHub CLI manually.${NC}"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh
    else
        echo -e "${RED}❌ Unsupported OS. Please install GitHub CLI manually.${NC}"
        exit 1
    fi
fi

# Authenticate with GitHub
echo -e "${YELLOW}🔐 Authenticating with GitHub...${NC}"
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}Please authenticate with GitHub CLI...${NC}"
    gh auth login
fi

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    echo -e "${YELLOW}📝 Creating .gitignore file...${NC}"
    cat > .gitignore << 'EOF'
# Flutter/Dart
.dart_tool/
.packages
.pub-cache/
.pub/
build/
flutter_*.png
linked_*.ds
unlinked.ds
unlinked_spec.ds

# Android
android/app/debug
android/app/profile
android/app/release
android/key.properties
android/app/google-services.json
android/app/google-services.json.bak

# iOS
ios/Flutter/App.framework
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
ios/Flutter/Generated.xcconfig
ios/Flutter/ephemeral/
ios/Flutter/app.flx
ios/Flutter/app.zip
ios/Flutter/flutter_assets/
ios/Flutter/flutter_export_environment.sh
ios/ServiceDefinitions.json
ios/Runner/GeneratedPluginRegistrant.*

# Web
web/

# Windows
windows/flutter/generated_plugin_registrant.cc
windows/flutter/generated_plugin_registrant.h
windows/flutter/generated_plugins.cmake

# Linux
linux/flutter/generated_plugin_registrant.cc
linux/flutter/generated_plugin_registrant.h
linux/flutter/generated_plugins.cmake

# macOS
macos/Flutter/GeneratedPluginRegistrant.swift
macos/Flutter/ephemeral/

# Firebase
firebase-debug.log
firebase-debug.*.log
.firebase/
firebase.json.bak
.firebaserc.bak

# Backend
backend/node_modules/
backend/.env
backend/.env.local
backend/.env.production
backend/serviceAccountKey.json
backend/functions/node_modules/
backend/functions/.env
backend/functions/.env.local
backend/functions/.env.production

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# nyc test coverage
.nyc_output

# Dependency directories
node_modules/
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env
.env.test
.env.production

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# next.js build output
.next

# nuxt.js build output
.nuxt

# vuepress build output
.vuepress/dist

# Serverless directories
.serverless

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

# Stores VSCode versions used for testing VSCode extensions
.vscode-test

# Temporary folders
tmp/
temp/
EOF
fi

# Create README.md if it doesn't exist
if [ ! -f README.md ]; then
    echo -e "${YELLOW}📝 Creating README.md file...${NC}"
    cat > README.md << 'EOF'
# 💰 Expense Tracker

A comprehensive Flutter expense tracking application with Firebase backend, designed to help users manage their finances effectively.

## 🚀 Features

- **📱 Cross-Platform**: Built with Flutter for iOS and Android
- **🔥 Firebase Integration**: Real-time data synchronization
- **📊 Analytics**: Detailed spending and income analytics
- **🎯 Budget Management**: Set and track weekly, monthly, and yearly budgets
- **💼 Investment Tracking**: Monitor investments and portfolio performance
- **🚨 Smart Alerts**: Budget alerts and financial goal reminders
- **📈 Reports**: Comprehensive financial reports and insights
- **🔒 Secure**: Firebase Authentication and Firestore security rules

## 🛠️ Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language
- **BLoC**: State management
- **Material Design**: UI/UX framework

### Backend
- **Firebase**: Backend-as-a-Service
- **Firestore**: NoSQL database
- **Firebase Auth**: Authentication
- **Cloud Functions**: Serverless functions
- **Express.js**: REST API server
- **Node.js**: Runtime environment

### Analytics & Monitoring
- **Firebase Analytics**: User behavior tracking
- **Firebase Crashlytics**: Error monitoring
- **Firebase Performance**: Performance monitoring

## 📱 Screenshots

*Screenshots will be added here*

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Node.js (18+)
- Firebase CLI
- Android Studio / Xcode
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/expense-tracker.git
   cd expense-tracker
   ```

2. **Install Flutter dependencies**
   ```bash
   cd expense_tracker
   flutter pub get
   ```

3. **Install backend dependencies**
   ```bash
   cd backend
   npm install
   cd functions
   npm install
   ```

4. **Firebase Setup**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase project
   firebase init
   ```

5. **Run the application**
   ```bash
   # Start the app
   flutter run
   
   # Start backend server
   cd backend
   npm run dev
   
   # Start Firebase emulators
   firebase emulators:start
   ```

## 📁 Project Structure

```
expense_tracker/
├── lib/
│   ├── bloc/                 # State management
│   ├── pages/               # UI pages
│   ├── services/            # Business logic
│   ├── utils/               # Utilities
│   └── widgets/             # Reusable widgets
├── backend/
│   ├── functions/           # Firebase Cloud Functions
│   ├── server.js            # Express.js server
│   └── package.json         # Backend dependencies
├── android/                 # Android-specific code
├── ios/                     # iOS-specific code
└── test/                    # Test files
```

## 🔧 Configuration

### Firebase Configuration

1. Create a new Firebase project
2. Enable Authentication, Firestore, and Cloud Functions
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the appropriate directories

### Environment Variables

Create `.env` files in the backend directory:

```bash
# backend/.env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email
```

## 🧪 Testing

```bash
# Run Flutter tests
flutter test

# Run backend tests
cd backend
npm test

# Run integration tests
flutter test integration_test/
```

## 📦 Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS

```bash
# Build iOS app
flutter build ios --release
```

## 🚀 Deployment

### Firebase Hosting

```bash
# Deploy to Firebase
firebase deploy
```

### Google Play Store

1. Build release APK/AAB
2. Create Play Console account
3. Upload and configure app
4. Submit for review

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Developer**: Your Name
- **Designer**: Your Name
- **Project Manager**: Your Name

## 📞 Support

If you have any questions or need help, please:

1. Check the [Issues](https://github.com/yourusername/expense-tracker/issues) page
2. Create a new issue if your problem isn't already reported
3. Contact us at your-email@example.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- Open source community for various packages

---

**Made with ❤️ using Flutter & Firebase**
EOF
fi

# Create LICENSE file
if [ ! -f LICENSE ]; then
    echo -e "${YELLOW}📝 Creating LICENSE file...${NC}"
    cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 Expense Tracker

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
fi

# Create CONTRIBUTING.md
if [ ! -f CONTRIBUTING.md ]; then
    echo -e "${YELLOW}📝 Creating CONTRIBUTING.md file...${NC}"
    cat > CONTRIBUTING.md << 'EOF'
# Contributing to Expense Tracker

Thank you for your interest in contributing to Expense Tracker! This document provides guidelines and information for contributors.

## 🚀 Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/yourusername/expense-tracker.git
   cd expense-tracker
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/originalowner/expense-tracker.git
   ```

## 🔧 Development Setup

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Node.js 18+
- Firebase CLI
- Git

### Setup Steps

1. **Install dependencies**:
   ```bash
   # Flutter dependencies
   flutter pub get
   
   # Backend dependencies
   cd backend
   npm install
   cd functions
   npm install
   ```

2. **Firebase setup**:
   ```bash
   firebase login
   firebase init
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## 📝 Code Style

### Flutter/Dart

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check for issues
- Format code with `dart format`

### JavaScript/Node.js

- Follow [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- Use ESLint for linting
- Use Prettier for formatting

## 🧪 Testing

### Flutter Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

### Backend Tests

```bash
cd backend
npm test
```

## 📋 Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** and commit:
   ```bash
   git add .
   git commit -m "Add: your feature description"
   ```

3. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create a Pull Request** on GitHub

### PR Guidelines

- **Title**: Use clear, descriptive titles
- **Description**: Explain what changes you made and why
- **Tests**: Ensure all tests pass
- **Screenshots**: Include screenshots for UI changes
- **Breaking Changes**: Document any breaking changes

## 🐛 Bug Reports

When reporting bugs, please include:

- **Description**: Clear description of the issue
- **Steps to Reproduce**: Detailed steps to reproduce the bug
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Screenshots**: If applicable
- **Environment**: OS, Flutter version, device info

## ✨ Feature Requests

When requesting features:

- **Description**: Clear description of the feature
- **Use Case**: Why this feature would be useful
- **Mockups**: If applicable, include mockups or wireframes
- **Alternatives**: Any alternative solutions you've considered

## 📚 Documentation

- Update README.md for significant changes
- Add comments to complex code
- Update API documentation for backend changes
- Include examples for new features

## 🏷️ Commit Message Format

Use the following format for commit messages:

```
type: description

Detailed description if needed

Closes #issue-number
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

## 🤝 Code Review

### For Contributors

- Respond to feedback promptly
- Make requested changes
- Ask questions if something is unclear
- Be respectful and constructive

### For Reviewers

- Be constructive and helpful
- Explain the reasoning behind suggestions
- Approve when ready
- Test the changes if possible

## 📞 Getting Help

- **Issues**: Use GitHub Issues for bugs and feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Email**: Contact maintainers directly for sensitive issues

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to Expense Tracker! 🎉
EOF
fi

# Initialize git repository if not already initialized
if [ ! -d .git ]; then
    echo -e "${YELLOW}🔧 Initializing Git repository...${NC}"
    git init
    git add .
    git commit -m "Initial commit: Expense Tracker Flutter app with Firebase backend"
fi

# Create GitHub repository
echo -e "${YELLOW}🌐 Creating GitHub repository...${NC}"
gh repo create $REPO_NAME --description "$REPO_DESCRIPTION" --$REPO_VISIBILITY

# Add remote origin
echo -e "${YELLOW}🔗 Adding remote origin...${NC}"
git remote add origin https://github.com/$(gh api user --jq .login)/$REPO_NAME.git

# Push to GitHub
echo -e "${YELLOW}📤 Pushing to GitHub...${NC}"
git branch -M main
git push -u origin main

# Create initial branches
echo -e "${YELLOW}🌿 Creating initial branches...${NC}"
git checkout -b develop
git push -u origin develop

git checkout -b feature/firebase-integration
git push -u origin feature/firebase-integration

git checkout -b feature/backend-api
git push -u origin feature/backend-api

git checkout main

# Set up branch protection rules
echo -e "${YELLOW}🛡️ Setting up branch protection rules...${NC}"
gh api repos/$(gh api user --jq .login)/$REPO_NAME/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["ci"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions='{"users":[],"teams":[]}'

# Create GitHub Actions workflow
echo -e "${YELLOW}⚙️ Creating GitHub Actions workflow...${NC}"
mkdir -p .github/workflows

cat > .github/workflows/ci.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  flutter-test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: |
        cd expense_tracker
        flutter pub get
    
    - name: Run tests
      run: |
        cd expense_tracker
        flutter test
    
    - name: Run integration tests
      run: |
        cd expense_tracker
        flutter test integration_test/
    
    - name: Build APK
      run: |
        cd expense_tracker
        flutter build apk --release

  backend-test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        cache-dependency-path: backend/package-lock.json
    
    - name: Install dependencies
      run: |
        cd backend
        npm ci
    
    - name: Run tests
      run: |
        cd backend
        npm test
    
    - name: Run linting
      run: |
        cd backend
        npm run lint

  firebase-deploy:
    runs-on: ubuntu-latest
    needs: [flutter-test, backend-test]
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    
    - name: Install Firebase CLI
      run: npm install -g firebase-tools
    
    - name: Deploy to Firebase
      run: |
        cd backend
        firebase deploy --token ${{ secrets.FIREBASE_TOKEN }}
      env:
        FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
EOF

# Create issue templates
echo -e "${YELLOW}📋 Creating issue templates...${NC}"
mkdir -p .github/ISSUE_TEMPLATE

cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
---
name: Bug report
about: Create a report to help us improve
title: ''
labels: bug
assignees: ''

---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment (please complete the following information):**
 - OS: [e.g. iOS, Android, Windows, macOS]
 - Flutter version: [e.g. 3.16.0]
 - Device: [e.g. iPhone 12, Samsung Galaxy S21]
 - App version: [e.g. 1.0.0]

**Additional context**
Add any other context about the problem here.
EOF

cat > .github/ISSUE_TEMPLATE/feature_request.md << 'EOF'
---
name: Feature request
about: Suggest an idea for this project
title: ''
labels: enhancement
assignees: ''

---

**Is your feature request related to a problem? Please describe.**
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.
EOF

# Create pull request template
cat > .github/pull_request_template.md << 'EOF'
## Description
Brief description of the changes made.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] I have tested these changes locally
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes

## Screenshots (if applicable)
Add screenshots to help explain your changes.

## Checklist
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes

## Additional Notes
Any additional information that reviewers should know.
EOF

# Commit and push all new files
echo -e "${YELLOW}📤 Committing and pushing new files...${NC}"
git add .
git commit -m "Add: GitHub repository setup with CI/CD, issue templates, and documentation"
git push origin main

# Create initial issues
echo -e "${YELLOW}📝 Creating initial issues...${NC}"
gh issue create --title "🚀 Implement Firebase-First Database Strategy" --body "Migrate from SQLite to Firestore for better scalability and real-time sync" --label "enhancement,high-priority"
gh issue create --title "🔧 Set up Express.js Backend API" --body "Implement REST API endpoints for transaction management and analytics" --label "enhancement,backend"
gh issue create --title "☁️ Deploy Firebase Cloud Functions" --body "Set up serverless functions for automated tasks and notifications" --label "enhancement,cloud"
gh issue create --title "🧪 Add Comprehensive Testing" --body "Implement unit tests, integration tests, and end-to-end tests" --label "enhancement,testing"
gh issue create --title "📱 Improve UI/UX Design" --body "Enhance user interface and user experience based on feedback" --label "enhancement,ui"

echo -e "${GREEN}✅ GitHub repository setup completed successfully!${NC}"
echo -e "${BLUE}🔗 Repository URL: https://github.com/$(gh api user --jq .login)/$REPO_NAME${NC}"
echo -e "${BLUE}📊 Issues: https://github.com/$(gh api user --jq .login)/$REPO_NAME/issues${NC}"
echo -e "${BLUE}⚙️ Actions: https://github.com/$(gh api user --jq .login)/$REPO_NAME/actions${NC}"

echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "1. Set up Firebase project and add service account key"
echo -e "2. Configure environment variables"
echo -e "3. Set up CI/CD secrets in GitHub"
echo -e "4. Start development on feature branches"
echo -e "5. Review and merge pull requests"

echo -e "${GREEN}🎉 Happy coding!${NC}"
