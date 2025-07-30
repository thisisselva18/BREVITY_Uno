import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:brevity/models/user_model.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final String _baseUrl = 'https://brevitybackend.onrender.com/api/auth';
  String? _accessToken;
  UserModel? _currentUser;

  // Auth state management
  Stream<UserModel?> get authStateChanges => _authStateController.stream;
  final _authStateController = StreamController<UserModel?>.broadcast();

  String? get accessToken => _accessToken;
  UserModel? get currentUser => _currentUser;

  // Initialize auth state (call this when app starts)
  Future<void> initializeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('accessToken');

      if (storedToken != null && storedToken.isNotEmpty) {
        _accessToken = storedToken;
        // Attempt to refresh user data with the stored token
        await refreshUser();
        if (_currentUser != null) {
          _authStateController.add(_currentUser);
        } else {
          // If refresh fails (e.g., token expired), clear token and notify logged out
          await signOut();
        }
      } else {
        _authStateController.add(null);
      }
    } catch (e) {
      // Handle any errors during initialization, e.g., SharedPreferences error
      _authStateController.add(null);
      print('Error initializing auth: $e'); // For debugging
    }
  }

  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String userName,
    BuildContext? context,
  }) async {
    try {
      if (context != null) {
        _showLoadingSnackBar(context, 'Creating your account...');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'displayName': userName,
          'email': email.trim(),
          'password': password.trim(),
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _accessToken = data['data']['accessToken'];
        final userData = data['data']['user'];

        // Save access token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', _accessToken!);

        // Create UserModel from backend response
        _currentUser = UserModel(
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

        if (context != null && context.mounted) {
          _showSuccessSnackBar(context, 'Account created successfully!');
          context.go('/intro');
        }

        // Notify listeners of auth state change
        _authStateController.add(_currentUser);
        return _currentUser;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create account');
      }
    } catch (e) {
      if (context != null && context.mounted) {
        _showErrorSnackBar(context, e.toString());
      }
      rethrow;
    }
  }

  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      if (context != null) {
        _showLoadingSnackBar(context, 'Signing you in...');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'password': password.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['data']['accessToken'];
        final userData = data['data']['user'];

        // Save access token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', _accessToken!);

        // Create UserModel from backend response
        _currentUser = UserModel(
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

        if (context != null && context.mounted) {
          _showSuccessSnackBar(context, 'Welcome back!');
          context.go('/home/0');
        }

        // Notify listeners of auth state change
        _authStateController.add(_currentUser);
        return _currentUser;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (context != null && context.mounted) {
        _showErrorSnackBar(context, e.toString());
      }
      rethrow;
    }
  }

  Future<void> signOut({BuildContext? context}) async {
    try {
      // Call logout endpoint if token exists
      if (_accessToken != null) {
        await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
        );
      }

      // Clear local state
      _accessToken = null;
      _currentUser = null;

      // Clear token from local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');

      // Notify listeners of auth state change
      _authStateController.add(null);

      if (context != null && context.mounted) {
        _showSuccessSnackBar(context, 'Successfully signed out');
        context.go('/login'); // Redirect to login page
      }
    } catch (e) {
      // Even if logout fails on server, clear local state
      _accessToken = null;
      _currentUser = null;
      _authStateController.add(null);

      // Ensure token is cleared from local storage even on server error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');

      if (context != null) {
        if(!context.mounted) return;
        _showErrorSnackBar(context, 'Error signing out, but you have been logged out locally');
        context.go('/login');
      }
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  // Refresh user data
  Future<void> refreshUser() async {
    if (_accessToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://brevitybackend.onrender.com/api/auth/me'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['data']['user'];

        _currentUser = UserModel(
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

        _authStateController.add(_currentUser);
      } else {
        // If refresh fails (e.g., token expired on server), sign out locally
        await signOut();
      }
    } catch (e) {
      // If refresh fails due to network or other error, sign out locally
      await signOut();
      print('Error refreshing user: $e'); // For debugging
    }
  }

  // Dispose of resources
  void dispose() {
    _authStateController.close();
  }

  // Snackbar helpers
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLoadingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text(message),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
