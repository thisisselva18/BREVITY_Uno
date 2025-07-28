import 'package:brevity/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserRepository {
  final String _baseUrl = 'https://brevitybackend.onrender.com/api/users';
  String? _accessToken;

  // Singleton pattern
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  // Set access token from auth service
  void setAccessToken(String token) {
    _accessToken = token;
  }

  // Get user profile
  Future<UserModel> getUserProfile(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['data']['user'];
        
        return UserModel(
          uid: userData['_id'], // Node.js uses _id
          displayName: userData['displayName'] ?? '',
          email: userData['email'] ?? '',
          emailVerified: userData['emailVerified'] ?? false,
          createdAt: userData['createdAt'] != null 
              ? DateTime.parse(userData['createdAt']) 
              : null,
          updatedAt: userData['updatedAt'] != null 
              ? DateTime.parse(userData['updatedAt']) 
              : null,
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'displayName': user.displayName,
          // Add other fields you want to update
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['data']['user'];
        
        return UserModel(
          uid: userData['_id'],
          displayName: userData['displayName'] ?? '',
          email: userData['email'] ?? '',
          emailVerified: userData['emailVerified'] ?? false,
          createdAt: userData['createdAt'] != null 
              ? DateTime.parse(userData['createdAt']) 
              : null,
          updatedAt: userData['updatedAt'] != null 
              ? DateTime.parse(userData['updatedAt']) 
              : null,
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get user by ID (if needed for admin purposes)
  Future<UserModel> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$userId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['data']['user'];
        
        return UserModel(
          uid: userData['_id'],
          displayName: userData['displayName'] ?? '',
          email: userData['email'] ?? '',
          emailVerified: userData['emailVerified'] ?? false,
          createdAt: userData['createdAt'] != null 
              ? DateTime.parse(userData['createdAt']) 
              : null,
          updatedAt: userData['updatedAt'] != null 
              ? DateTime.parse(userData['updatedAt']) 
              : null,
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load user');
      }
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }
}