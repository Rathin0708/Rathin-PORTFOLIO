class ContactModel {
  final String name;
  final String email;
  final String subject;
  final String message;
  final DateTime timestamp;
  final String? platform;
  final String? userAgent;
  final String? ipAddress;
  final Map<String, dynamic>? deviceInfo;

  ContactModel({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.timestamp,
    this.platform,
    this.userAgent,
    this.ipAddress,
    this.deviceInfo,
  });

  // Getter for messageId
  String get messageId => timestamp.millisecondsSinceEpoch.toString();

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      platform: json['platform'],
      userAgent: json['userAgent'],
      ipAddress: json['ipAddress'],
      deviceInfo: json['deviceInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'platform': platform ?? 'Unknown',
      'userAgent': userAgent ?? 'Unknown',
      'ipAddress': ipAddress ?? 'Unknown',
      'deviceInfo': deviceInfo ?? {},
      'messageId': timestamp.millisecondsSinceEpoch.toString(),
      'formattedTime': timestamp.toString(),
      'utcTime': timestamp.toUtc().toIso8601String(),
    };
  }
}

class SocialLink {
  final String platform;
  final String url;
  final String iconData;

  SocialLink({
    required this.platform,
    required this.url,
    required this.iconData,
  });
}
