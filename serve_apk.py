#!/usr/bin/env python3
"""
Simple HTTP server to serve APK files for QR code sharing
"""
import http.server
import socketserver
import os
import sys
from pathlib import Path

def get_local_ip():
    """Get the local IP address"""
    import socket
    try:
        # Connect to a remote server to get local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except:
        return "127.0.0.1"

def main():
    # Set up the server
    PORT = 8081
    
    # Get the APK file path
    apk_path = Path("build/app/outputs/flutter-apk/app-release.apk")
    if not apk_path.exists():
        print(f"APK file not found at {apk_path}")
        print("Please build the APK first with: flutter build apk --release")
        sys.exit(1)
    
    # Change to the project directory
    os.chdir(Path(__file__).parent)
    
    # Create a custom handler that serves the APK
    class APKHandler(http.server.SimpleHTTPRequestHandler):
        def do_GET(self):
            if self.path == '/app-release.apk':
                self.path = '/build/app/outputs/flutter-apk/app-release.apk'
                # Set proper headers for APK download
                self.send_response(200)
                self.send_header('Content-Type', 'application/vnd.android.package-archive')
                self.send_header('Content-Disposition', 'attachment; filename="app-release.apk"')
                self.end_headers()
                # Serve the file
                with open(apk_path, 'rb') as f:
                    self.wfile.write(f.read())
                return
            return super().do_GET()
    
    # Start the server
    local_ip = get_local_ip()
    
    with socketserver.TCPServer(("", PORT), APKHandler) as httpd:
        print(f"🚀 APK Server started!")
        print(f"📱 Local IP: {local_ip}")
        print(f"🔗 APK URL: http://{local_ip}:{PORT}/app-release.apk")
        print(f"📋 QR Code Data: http://{local_ip}:{PORT}/app-release.apk")
        print(f"🌐 Server running on port {PORT}")
        print("Press Ctrl+C to stop the server")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n🛑 Server stopped")

if __name__ == "__main__":
    main()
