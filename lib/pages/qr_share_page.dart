// lib/pages/qr_share_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRSharePage extends StatefulWidget {
  const QRSharePage({super.key});

  @override
  State<QRSharePage> createState() => _QRSharePageState();
}

class _QRSharePageState extends State<QRSharePage> {
  String _apkUrl = '';
  String _instructions = '';
  String _localIp = '10.120.121.89'; // Default IP
  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ipController.text = _localIp;
    _generateAPKInfo();
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _generateAPKInfo() {
    _apkUrl =
        'http://$_localIp:8001/build/app/outputs/flutter-apk/app-release.apk';
    _instructions = '''
📱 INSTALLATION STEPS:

1. Scan QR code with your phone camera
2. Download the APK file (53.8MB)
3. Go to Settings → Security → Install unknown apps
4. Enable "Allow from this source" for your browser
5. Tap the downloaded APK to install
6. Launch "Expense Tracker" app

⚠️ TROUBLESHOOTING:
• If download fails: Check WiFi connection
• If install blocked: Enable "Unknown Sources" 
• If QR doesn't work: Copy the URL manually
• For help: Use ADB installation script

🌐 NETWORK: Make sure phone and computer are on same WiFi!
''';
  }

  void _updateQRCode() {
    setState(() {
      _localIp = _ipController.text.trim();
      _generateAPKInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share App'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // App Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 64,
                      color: Colors.blue[600],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Expense Tracker',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Personal Finance Management App',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // IP Address Input
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Server Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _ipController,
                      decoration: InputDecoration(
                        labelText: 'Local IP Address',
                        hintText: '192.168.1.100',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.wifi),
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _updateQRCode,
                      icon: Icon(Icons.refresh),
                      label: Text('Update QR Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Simple Instructions
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.qr_code, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Simple Sharing',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Just scan and download! No setup needed.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('✅ QR code works instantly'),
                    Text('✅ No WiFi configuration needed'),
                    Text('✅ Direct download link'),
                    Text('✅ Works anywhere with internet'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // QR Code Section
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Scan to Download',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    // QR Code
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _apkUrl,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),

                    SizedBox(height: 20),

                    Text(
                      'Scan with your phone camera',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),

                    SizedBox(height: 10),

                    // Copy URL Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _apkUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('URL copied to clipboard'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: Icon(Icons.copy),
                      label: Text('Copy Download Link'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Instructions Card
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Installation Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(_instructions, style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Troubleshooting Card
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔧 Troubleshooting',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('❌ "Download failed" → Check WiFi connection'),
                    Text('❌ "Install blocked" → Enable Unknown Sources'),
                    Text('❌ "QR not working" → Copy URL manually'),
                    Text('❌ "File not found" → Restart server'),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('ADB Installation'),
                            content: Text(
                              'For advanced users: Use the install_apk.sh script with USB debugging enabled.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.usb),
                      label: Text('ADB Installation Help'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Alternative Methods
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📤 Alternative Sharing Methods',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('☁️ Upload to Google Drive/Dropbox'),
                    Text('📧 Email APK file to others'),
                    Text('💾 Share via USB cable'),
                    Text('🔗 Use file sharing services'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
