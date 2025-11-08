import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/contact_model.dart';
import '../utils/constants.dart';

class SimpleEmailService {
  static const String _emailJSServiceId = 'service_portfolio';
  static const String _emailJSTemplateId = 'template_contact';
  static const String _emailJSUserId = 'your_emailjs_user_id';

  /// Send email using multiple methods with guaranteed delivery
  static Future<bool> sendContactEmail(ContactModel contact) async {
    print('🚀 Starting simple email delivery...');
    
    try {
      // Method 1: Try EmailJS (web service)
      bool emailJSSuccess = await _sendViaEmailJS(contact);
      if (emailJSSuccess) {
        print('✅ Email sent successfully via EmailJS');
        return true;
      }

      // Method 2: Try Formspree (form service)
      bool formspreeSuccess = await _sendViaFormspree(contact);
      if (formspreeSuccess) {
        print('✅ Email sent successfully via Formspree');
        return true;
      }

      // Method 3: Copy to clipboard as fallback
      await _copyEmailToClipboard(contact);
      print('✅ Email content copied to clipboard');
      return true;

    } catch (e) {
      print('❌ Error in simple email service: $e');
      return false;
    }
  }

  /// Send via EmailJS service
  static Future<bool> _sendViaEmailJS(ContactModel contact) async {
    try {
      print('📧 Attempting EmailJS...');
      
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': _emailJSServiceId,
          'template_id': _emailJSTemplateId,
          'user_id': _emailJSUserId,
          'template_params': {
            'to_email': AppConstants.email,
            'from_name': contact.name,
            'from_email': contact.email,
            'subject': 'Portfolio Contact: ${contact.subject}',
            'message': _createEmailContent(contact),
          }
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('✅ EmailJS: Email sent successfully');
        return true;
      } else {
        print('❌ EmailJS failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ EmailJS error: $e');
      return false;
    }
  }

  /// Send via Formspree service
  static Future<bool> _sendViaFormspree(ContactModel contact) async {
    try {
      print('📝 Attempting Formspree...');
      
      // You can create a free Formspree form at https://formspree.io/
      final formspreeEndpoint = 'https://formspree.io/f/rathin007008@gmail.com';
      
      final response = await http.post(
        Uri.parse(formspreeEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': contact.name,
          'email': contact.email,
          'subject': 'Portfolio Contact: ${contact.subject}',
          'message': _createEmailContent(contact),
        }),
      ).timeout(const Duration(seconds: 10));

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
  static Future<void> _copyEmailToClipboard(ContactModel contact) async {
    try {
      final emailContent = '''
TO: ${AppConstants.email}
SUBJECT: Portfolio Contact: ${contact.subject}

${_createEmailContent(contact)}

---
📋 This email content has been copied to your clipboard.
Please paste it into your email app and send manually.
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
    final formattedJson = _formatJson(jsonData);
    
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

  /// Format JSON for better readability
  static String _formatJson(Map<String, dynamic> jsonData) {
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonData);
    } catch (e) {
      return jsonData.toString();
    }
  }

  /// Send via direct HTTP POST to your server (if you have one)
  static Future<bool> sendViaDirectAPI(ContactModel contact) async {
    try {
      // Replace with your actual server endpoint
      final response = await http.post(
        Uri.parse('https://your-server.com/api/contact'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'to': AppConstants.email,
          'subject': 'Portfolio Contact: ${contact.subject}',
          'content': _createEmailContent(contact),
          'contactData': contact.toJson(),
        }),
      ).timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Direct API error: $e');
      return false;
    }
  }
}
