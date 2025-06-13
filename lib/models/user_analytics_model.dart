class UserAnalytics {
  final int totalUsers;
  final int totalContacts;
  final int emailUsers;
  final int googleUsers;
  final int recentUsers;
  final int recentContacts;

  UserAnalytics({
    required this.totalUsers,
    required this.totalContacts,
    required this.emailUsers,
    required this.googleUsers,
    required this.recentUsers,
    required this.recentContacts,
  });

  factory UserAnalytics.fromJson(Map<String, dynamic> json) {
    return UserAnalytics(
      totalUsers: json['totalUsers'] ?? 0,
      totalContacts: json['totalContacts'] ?? 0,
      emailUsers: json['emailUsers'] ?? 0,
      googleUsers: json['googleUsers'] ?? 0,
      recentUsers: json['recentUsers'] ?? 0,
      recentContacts: json['recentContacts'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalContacts': totalContacts,
      'emailUsers': emailUsers,
      'googleUsers': googleUsers,
      'recentUsers': recentUsers,
      'recentContacts': recentContacts,
    };
  }

  double get googleUserPercentage => 
      totalUsers > 0 ? (googleUsers / totalUsers) * 100 : 0;

  double get emailUserPercentage => 
      totalUsers > 0 ? (emailUsers / totalUsers) * 100 : 0;

  double get recentUserGrowth => 
      totalUsers > 0 ? (recentUsers / totalUsers) * 100 : 0;

  double get recentContactGrowth => 
      totalContacts > 0 ? (recentContacts / totalContacts) * 100 : 0;
}
