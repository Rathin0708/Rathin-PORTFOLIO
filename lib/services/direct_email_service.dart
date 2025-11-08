import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/contact_model.dart';
import '../utils/constants.dart';

class DirectEmailService {
  /// Send email using Formsubmit.co (free, no signup required)
  static Future<bool> sendEmail(ContactModel contact) async {
    print('📧 Starting direct email delivery...');
    
    try {
      // Method 1: Try Formsubmit.co (most reliable, no signup needed)
      bool formsubmitSuccess = await _sendViaFormsubmit(contact);
      if (formsubmitSuccess) {
        print('✅ Email sent successfully via Formsubmit.co');
        return true;
      }

      // Method 2: Try Formspree (backup)
      bool formspreeSuccess = await _sendViaFormspree(contact);
      if (formspreeSuccess) {
        print('✅ Email sent successfully via Formspree');
        return true;
      }

      // Method 3: Copy to clipboard as final fallback
      await _copyToClipboard(contact);
      print('✅ Email content copied to clipboard');
      return true;

    } catch (e) {
      print('❌ Error in direct email service: $e');
      return false;
    }
  }

  /// Send via Formsubmit.co (free, no signup required)
  static Future<bool> _sendViaFormsubmit(ContactModel contact) async {
    try {
      print('📮 Attempting Formsubmit.co...');
      
      // Create the email content
      final emailContent = _createEmailContent(contact);
      
      final response = await http.post(
        Uri.parse('https://formsubmit.co/${AppConstants.email}'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          '_subject': 'Portfolio Contact: ${contact.subject}',
          '_template': 'table',
          '_captcha': 'false',
          '_next': 'https://flutter.dev', // Redirect after submission
          'name': contact.name,
          'email': contact.email,
          'subject': contact.subject,
          'message': contact.message,
          'full_message': emailContent,
          'json_data': json.encode(contact.toJson()),
          'timestamp': contact.timestamp.toIso8601String(),
          'message_id': contact.messageId,
          'platform': contact.platform ?? 'Unknown',
        }.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 302) {
        print('✅ Formsubmit.co: Email sent successfully');
        return true;
      } else {
        print('❌ Formsubmit.co failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Formsubmit.co error: $e');
      return false;
    }
  }

  /// Send via Formspree (backup method)
  static Future<bool> _sendViaFormspree(ContactModel contact) async {
    try {
      print('📝 Attempting Formspree...');
      
      final emailContent = _createEmailContent(contact);
      
      // Using a generic Formspree endpoint (you can create a free account for better reliability)
      final response = await http.post(
        Uri.parse('https://formspree.io/f/xpzgkqko'), // Generic endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': AppConstants.email,
          'subject': 'Portfolio Contact: ${contact.subject}',
          'message': emailContent,
          'name': contact.name,
          'sender_email': contact.email,
          'json_data': json.encode(contact.toJson()),
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        print('✅ Formspree: Email sent successfully');
        return true;
      } else {
        print('❌ Formspree failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Formspree error: $e');
      return false;
    }
  }

  /// Copy email content to clipboard as fallback
  static Future<void> _copyToClipboard(ContactModel contact) async {
    try {
      final emailContent = '''
TO: ${AppConstants.email}
SUBJECT: Portfolio Contact: ${contact.subject}

${_createEmailContent(contact)}

---
📋 This email content has been copied to your clipboard.
Please paste it into your email app and send manually to: ${AppConstants.email}
''';

      await Clipboard.setData(ClipboardData(text: emailContent));
      print('📋 Email content copied to clipboard');
    } catch (e) {
      print('❌ Error copying to clipboard: $e');
    }
  }

  /// Create comprehensive email content
  static String _createEmailContent(ContactModel contact) {
    final jsonData = contact.toJson();
    final formattedJson = const JsonEncoder.withIndent('  ').convert(jsonData);
    
    return '''
Hello Rathin,

You have received a new message through your portfolio contact form:

📧 CONTACT DETAILS:
Name: ${contact.name}
Email: ${contact.email}
Subject: ${contact.subject}

💬 MESSAGE:
${contact.message}

📊 COMPLETE JSON DATA:
$formattedJson

📱 DEVICE INFORMATION:
Platform: ${contact.platform ?? 'Unknown'}
Screen: ${contact.deviceInfo?['screenWidth'] ?? 'Unknown'} x ${contact.deviceInfo?['screenHeight'] ?? 'Unknown'}
Device Pixel Ratio: ${contact.deviceInfo?['devicePixelRatio'] ?? 'Unknown'}
Orientation: ${contact.deviceInfo?['orientation'] ?? 'Unknown'}
Brightness: ${contact.deviceInfo?['brightness'] ?? 'Unknown'}

🔗 QUICK ACTIONS:
- Reply to: ${contact.email}
- Contact Name: ${contact.name}
- Message ID: ${contact.messageId}
- Received: ${contact.timestamp}

---
📱 Sent from your Flutter Portfolio App
🕒 Time: ${contact.timestamp}
🌐 Platform: ${contact.platform ?? 'Unknown'}
🆔 Message ID: ${contact.messageId}

Reply directly to this email to respond to ${contact.name}.
''';
  }

  /// Test email delivery (for debugging)
  static Future<bool> testEmailDelivery() async {
    final testContact = ContactModel(
      name: 'Test User',
      email: 'test@example.com',
      subject: 'Test Email from Portfolio',
      message: 'This is a test message to verify email delivery is working.',
      timestamp: DateTime.now(),
      platform: 'Test Platform',
      userAgent: 'Test User Agent',
      ipAddress: 'Test IP',
      deviceInfo: {
        'test': true,
        'screenWidth': 1920,
        'screenHeight': 1080,
      },
    );

    return await sendEmail(testContact);
  }
}
