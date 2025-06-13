import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/contact_model.dart';
import '../utils/constants.dart';

class WebEmailService {
  /// Send email using Netlify Forms (free and reliable)
  static Future<bool> sendViaNetlify(ContactModel contact) async {
    try {
      print('🌐 Attempting Netlify Forms...');
      
      // Create form data
      final formData = {
        'form-name': 'portfolio-contact',
        'name': contact.name,
        'email': contact.email,
        'subject': contact.subject,
        'message': contact.message,
        'json-data': json.encode(contact.toJson()),
        'device-info': json.encode(contact.deviceInfo ?? {}),
        'timestamp': contact.timestamp.toIso8601String(),
        'message-id': contact.messageId,
      };

      // Convert to URL encoded format
      final body = formData.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await http.post(
        Uri.parse('https://rathin-portfolio.netlify.app/'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        print('✅ Netlify Forms: Email sent successfully');
        return true;
      } else {
        print('❌ Netlify Forms failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Netlify Forms error: $e');
      return false;
    }
  }

  /// Send email using Formsubmit.co (free email service)
  static Future<bool> sendViaFormsubmit(ContactModel contact) async {
    try {
      print('📮 Attempting Formsubmit...');
      
      final response = await http.post(
        Uri.parse('https://formsubmit.co/${AppConstants.email}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          '_subject': 'Portfolio Contact: ${contact.subject}',
          '_template': 'table',
          '_captcha': 'false',
          'name': contact.name,
          'email': contact.email,
          'subject': contact.subject,
          'message': contact.message,
          'json_data': json.encode(contact.toJson()),
          'device_info': json.encode(contact.deviceInfo ?? {}),
          'timestamp': contact.timestamp.toIso8601String(),
          'message_id': contact.messageId,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        print('✅ Formsubmit: Email sent successfully');
        return true;
      } else {
        print('❌ Formsubmit failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Formsubmit error: $e');
      return false;
    }
  }

  /// Send email using EmailJS (requires setup)
  static Future<bool> sendViaEmailJS(ContactModel contact) async {
    try {
      print('✉️ Attempting EmailJS...');
      
      // You need to set up EmailJS account and get these IDs
      const serviceId = 'service_portfolio';
      const templateId = 'template_contact';
      const userId = 'your_emailjs_user_id';
      
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'to_email': AppConstants.email,
            'from_name': contact.name,
            'from_email': contact.email,
            'subject': 'Portfolio Contact: ${contact.subject}',
            'message': contact.message,
            'json_data': json.encode(contact.toJson()),
            'device_info': json.encode(contact.deviceInfo ?? {}),
            'timestamp': contact.timestamp.toIso8601String(),
            'message_id': contact.messageId,
          }
        }),
      ).timeout(const Duration(seconds: 15));

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

  /// Send email using GetForm.io (free form service)
  static Future<bool> sendViaGetForm(ContactModel contact) async {
    try {
      print('📝 Attempting GetForm...');
      
      // Create a form at https://getform.io and get your endpoint
      const getformEndpoint = 'https://getform.io/f/your-form-id';
      
      final response = await http.post(
        Uri.parse(getformEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': contact.name,
          'email': contact.email,
          'subject': 'Portfolio Contact: ${contact.subject}',
          'message': contact.message,
          'json_data': json.encode(contact.toJson()),
          'device_info': json.encode(contact.deviceInfo ?? {}),
          'timestamp': contact.timestamp.toIso8601String(),
          'message_id': contact.messageId,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        print('✅ GetForm: Email sent successfully');
        return true;
      } else {
        print('❌ GetForm failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ GetForm error: $e');
      return false;
    }
  }

  /// Try multiple web email services
  static Future<bool> sendEmail(ContactModel contact) async {
    print('🌐 Starting web email services...');
    
    // Try Formsubmit first (most reliable)
    if (await sendViaFormsubmit(contact)) return true;
    
    // Try Netlify Forms
    if (await sendViaNetlify(contact)) return true;
    
    // Try GetForm
    if (await sendViaGetForm(contact)) return true;
    
    // Try EmailJS
    if (await sendViaEmailJS(contact)) return true;
    
    print('❌ All web email services failed');
    return false;
  }
}
