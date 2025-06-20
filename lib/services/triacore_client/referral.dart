import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReferralService {
  final String backendUrl;

  ReferralService({required this.backendUrl});

  Future<bool> validateReferralCode(String referralCode) async {
    final upperReferralCode = referralCode.toUpperCase();
    final url = Uri.https(backendUrl, "/referrals/$upperReferralCode");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] == true) {
        await saveReferralCode(upperReferralCode);
        await registerReferral(upperReferralCode);
      }
      return data['data'] ?? false;
    } else {
      if (kDebugMode) {
        print("Error validating referral code: ${response.body}");
      }
      return false;
    }
  }

  Future<void> saveReferralCode(String referralCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('referralCode', referralCode);
  }

  Future<void> registerReferral(String referralCode) async {
    final prefs = await SharedPreferences.getInstance();
    final hashedDescriptor = prefs.getString('hashed_descriptor');

    if (hashedDescriptor == null) {
      if (kDebugMode) {
        print("Error: hashed_descriptor not found in SharedPreferences");
      }
      return;
    }

    final url = Uri.https(backendUrl, "/users/referrals");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': hashedDescriptor,
        'referral_code': referralCode.toUpperCase(),
      }),
    );

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print("Error registering referral: "+response.body);
      }
    }
  }
}
