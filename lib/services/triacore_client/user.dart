import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triacore_mobile/models/user.dart';

class UserService {
  final String backendUrl;

  UserService({required this.backendUrl});

  Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('hashed_descriptor');
    return userId;
  }

  // Get headers for HTTP requests
  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      // Add other headers if needed
    };
  }

  // Get FCM token from shared preferences
  Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  // Register a new user
  Future<bool> registerUser(String hashedDescriptor, String? fcmToken) async {
    try {
      final url = Uri.https(backendUrl, '/api/register');
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          'hashed_descriptor': hashedDescriptor,
          'fcm_token': fcmToken,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Get user details
  Future<User?> getUserDetails() async {
    final userId = await getUserId();
    
    if (userId == null) {
      return null;
    }
    
    try {
      final url = Uri.https(backendUrl, '/user/$userId');
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body)['data']);
      } else if (response.statusCode == 404) {
        // If user not found, try to register
        final prefs = await SharedPreferences.getInstance();
        final hashedDescriptor = prefs.getString('hashed_descriptor');
        
        if (hashedDescriptor == null) {
          return null;
        }
        
        final registrationResult = await registerUser(
          hashedDescriptor,
          await getFcmToken(),
        );
        
        // Retry getting user details after registration
        if (registrationResult) {
          return await getUserDetails();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
