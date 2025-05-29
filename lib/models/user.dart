import 'package:flutter/foundation.dart';

class User {
  String id;
  int dailySpending;
  int allowedSpending;
  int verificationLevel;
  String? referredBy;

  User({
    required this.id,
    required this.dailySpending,
    required this.allowedSpending,
    required this.verificationLevel,
    this.referredBy,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('Parsing User from JSON: $json');
    }
    
    try {
      final id = json['descriptor_hash'] ?? json['user_id'] ?? '';
      final dailySpending = json['daily_spending'] is int ? json['daily_spending'] : 0;
      final allowedSpending = json['allowed_spending'] is int ? json['allowed_spending'] : 0;
      final verificationLevel = json['verification_level'] is int ? json['verification_level'] : 0;
      final referredBy = json['referred_by'] as String?;
      
      return User(
        id: id,
        dailySpending: dailySpending,
        allowedSpending: allowedSpending,
        verificationLevel: verificationLevel,
        referredBy: referredBy,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error parsing User from JSON: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }
}
