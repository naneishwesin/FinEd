#!/usr/bin/env python3
"""
Simple file sharing server for APK
"""
import http.server
import socketserver
import os
import sys
from pathlib import Path

def main():
    PORT = 8001
    
    # Get the APK file path
    apk_path = Path("build/app/outputs/flutter-apk/app-release.apk")
    if not apk_path.exists():
        print(f"APK file not found at {apk_path}")
        sys.exit(1)
    
    # Change to the project directory
    os.chdir(Path(__file__).parent)
    
    # Start simple HTTP server
    with socketserver.TCPServer(("", PORT), http.server.SimpleHTTPRequestHandler) as httpd:
        print(f"🚀 Simple APK Server started!")
        print(f"📁 Serving files from: {os.getcwd()}")
        print(f"🔗 APK URL: http://localhost:{PORT}/build/app/outputs/flutter-apk/app-release.apk")
        print(f"🌐 Server running on port {PORT}")
        print("Press Ctrl+C to stop the server")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n🛑 Server stopped")

if __name__ == "__main__":
    main()
