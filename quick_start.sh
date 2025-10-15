#!/bin/bash

# 🚀 Quick Start Script for Expense Tracker
# This script helps you get the complete tech stack running quickly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Expense Tracker Quick Start${NC}"
echo -e "${BLUE}==============================${NC}"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Please run this script from the expense_tracker directory${NC}"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"

if ! command_exists flutter; then
    echo -e "${RED}❌ Flutter is not installed. Please install Flutter first.${NC}"
    exit 1
fi

if ! command_exists node; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js first.${NC}"
    exit 1
fi

if ! command_exists npm; then
    echo -e "${RED}❌ npm is not installed. Please install npm first.${NC}"
    exit 1
fi

if ! command_exists firebase; then
    echo -e "${YELLOW}⚠️  Firebase CLI is not installed. Installing...${NC}"
    npm install -g firebase-tools
fi

echo -e "${GREEN}✅ All prerequisites are installed${NC}"

# Step 1: Install Flutter dependencies
echo -e "${YELLOW}📱 Installing Flutter dependencies...${NC}"
flutter pub get

# Step 2: Install backend dependencies
echo -e "${YELLOW}🔧 Installing backend dependencies...${NC}"
if [ -d "backend" ]; then
    cd backend
    npm install
    cd ..
else
    echo -e "${RED}❌ Backend directory not found. Please run the implementation guide first.${NC}"
    exit 1
fi

# Step 3: Install Firebase Functions dependencies
echo -e "${YELLOW}☁️ Installing Firebase Functions dependencies...${NC}"
if [ -d "backend/functions" ]; then
    cd backend/functions
    npm install
    cd ../..
else
    echo -e "${RED}❌ Firebase Functions directory not found. Please run the implementation guide first.${NC}"
    exit 1
fi

# Step 4: Check Firebase configuration
echo -e "${YELLOW}🔥 Checking Firebase configuration...${NC}"
if [ ! -f "android/app/google-services.json" ]; then
    echo -e "${YELLOW}⚠️  google-services.json not found. Please add it to android/app/${NC}"
fi

if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo -e "${YELLOW}⚠️  GoogleService-Info.plist not found. Please add it to ios/Runner/${NC}"
fi

# Step 5: Check backend configuration
echo -e "${YELLOW}🔧 Checking backend configuration...${NC}"
if [ ! -f "backend/serviceAccountKey.json" ]; then
    echo -e "${YELLOW}⚠️  serviceAccountKey.json not found. Please add it to backend/${NC}"
fi

if [ ! -f "backend/.env" ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating template...${NC}"
    cat > backend/.env << 'EOF'
NODE_ENV=development
PORT=3000
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email
EOF
    echo -e "${YELLOW}📝 Please update backend/.env with your Firebase credentials${NC}"
fi

# Step 6: Run Flutter doctor
echo -e "${YELLOW}🏥 Running Flutter doctor...${NC}"
flutter doctor

# Step 7: Build the app
echo -e "${YELLOW}🔨 Building Flutter app...${NC}"
flutter build apk --debug

# Step 8: Start services
echo -e "${GREEN}🚀 Starting services...${NC}"

# Function to start backend server
start_backend() {
    echo -e "${BLUE}🔧 Starting backend server...${NC}"
    cd backend
    npm run dev &
    BACKEND_PID=$!
    cd ..
    echo -e "${GREEN}✅ Backend server started (PID: $BACKEND_PID)${NC}"
}

# Function to start Firebase emulators
start_emulators() {
    echo -e "${BLUE}🔥 Starting Firebase emulators...${NC}"
    cd backend
    firebase emulators:start &
    EMULATORS_PID=$!
    cd ..
    echo -e "${GREEN}✅ Firebase emulators started (PID: $EMULATORS_PID)${NC}"
}

# Function to start Flutter app
start_flutter() {
    echo -e "${BLUE}📱 Starting Flutter app...${NC}"
    flutter run &
    FLUTTER_PID=$!
    echo -e "${GREEN}✅ Flutter app started (PID: $FLUTTER_PID)${NC}"
}

# Ask user what to start
echo -e "${YELLOW}What would you like to start?${NC}"
echo -e "1) Backend server only"
echo -e "2) Firebase emulators only"
echo -e "3) Flutter app only"
echo -e "4) All services"
echo -e "5) Just show status"

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        start_backend
        ;;
    2)
        start_emulators
        ;;
    3)
        start_flutter
        ;;
    4)
        start_backend
        sleep 2
        start_emulators
        sleep 2
        start_flutter
        ;;
    5)
        echo -e "${BLUE}📊 Service Status:${NC}"
        echo -e "Backend server: $(pgrep -f 'npm run dev' > /dev/null && echo 'Running' || echo 'Stopped')"
        echo -e "Firebase emulators: $(pgrep -f 'firebase emulators' > /dev/null && echo 'Running' || echo 'Stopped')"
        echo -e "Flutter app: $(pgrep -f 'flutter run' > /dev/null && echo 'Running' || echo 'Stopped')"
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

# Show useful information
echo -e "${BLUE}📋 Useful Information:${NC}"
echo -e "Backend API: http://localhost:3000"
echo -e "Firebase Emulators: http://localhost:4000"
echo -e "Flutter app: Check your device/emulator"
echo -e ""
echo -e "${BLUE}🔗 API Endpoints:${NC}"
echo -e "Health Check: GET http://localhost:3000/health"
echo -e "Transactions: GET http://localhost:3000/api/transactions"
echo -e "Balances: GET http://localhost:3000/api/balances"
echo -e ""
echo -e "${BLUE}🛠️ Commands:${NC}"
echo -e "Stop all services: pkill -f 'npm run dev' && pkill -f 'firebase emulators' && pkill -f 'flutter run'"
echo -e "View logs: tail -f backend/logs/app.log"
echo -e "Test API: curl http://localhost:3000/health"

# Create a stop script
cat > stop_services.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping all services..."
pkill -f 'npm run dev' 2>/dev/null || true
pkill -f 'firebase emulators' 2>/dev/null || true
pkill -f 'flutter run' 2>/dev/null || true
echo "✅ All services stopped"
EOF

chmod +x stop_services.sh

echo -e "${GREEN}✅ Quick start completed!${NC}"
echo -e "${YELLOW}💡 Tip: Run ./stop_services.sh to stop all services${NC}"
echo -e "${YELLOW}📚 For detailed setup, see IMPLEMENTATION_GUIDE.md${NC}"
