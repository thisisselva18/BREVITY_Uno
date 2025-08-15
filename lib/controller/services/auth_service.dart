import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:brevity/models/user_model.dart';
import 'package:brevity/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final String _baseUrl = 'https://brevitybackend.onrender.com/api/auth';

  // HTTP timeout duration
  static const Duration _httpTimeout = Duration(seconds: 30);

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
          // If refresh fails (e.g., token expired), clear local state without calling logout API
          await _clearLocalAuthState();
        }
      } else {
        _authStateController.add(null);
      }
    } catch (e) {
      // Handle any errors during initialization, e.g., SharedPreferences error
      _authStateController.add(null);
      Log.e('Error initializing auth: $e'); // For debugging
    }
  }

  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String userName,
    BuildContext? context,
    File? profileImage, // Add this parameter
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/register');
      final request = http.MultipartRequest('POST', uri);

      // Add form fields
      request.fields['displayName'] = userName;
      request.fields['email'] = email.trim();
      request.fields['password'] = password.trim();

      // Add profile image if provided
      if (profileImage != null) {
        // Get file extension and determine content type
        final extension = profileImage.path.split('.').last.toLowerCase();
        String contentType;

        switch (extension) {
          case 'jpg':
          case 'jpeg':
            contentType = 'image/jpeg';
            break;
          case 'png':
            contentType = 'image/png';
            break;
          case 'gif':
            contentType = 'image/gif';
            break;
          case 'webp':
            contentType = 'image/webp';
            break;
          default:
            contentType = 'image/jpeg'; // Default fallback
        }

        final multipartFile = http.MultipartFile(
          'profileImage',
          profileImage.readAsBytes().asStream(),
          profileImage.lengthSync(),
          filename: 'profile_image.$extension',
          contentType: MediaType.parse(contentType),
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send().timeout(_httpTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        // Rest of your existing success handling code remains the same
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
          createdAt:
          userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'])
              : null,
          updatedAt:
          userData['updatedAt'] != null
              ? DateTime.parse(userData['updatedAt'])
              : null,
          profileImageUrl: userData['profileImage']?['url'],
        );

        if (context != null && context.mounted) {
          // Redirect to email verification - no success snackbar as user needs to verify email
          context.go(
            '/email-verification?email=${Uri.encodeComponent(email)}&isFromLogin=false',
          );
        }

        // Notify listeners of auth state change
        _authStateController.add(_currentUser);
        return _currentUser;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create account');
      }
    } catch (e) {
      Log.e('Sign up error: $e'); // For debugging
      // Let the calling screen handle error display for better UX control
      rethrow;
    }
  }

  Future<void> forgotPassword({
    required String email,
    BuildContext? context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email.trim()}),
      );

      if (response.statusCode == 200) {
        if (context != null && context.mounted) {
          _showSuccessSnackBar(context, 'Reset OTP sent to your email');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send reset OTP');
      }
    } catch (e) {
      Log.e('Forgot password error: $e'); // For debugging
      // Let the calling screen handle error display for better UX control
      rethrow;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    BuildContext? context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'token': otp.trim(),
          'newPassword': newPassword.trim(),
        }),
      );

      if (response.statusCode == 200) {
        if (context != null && context.mounted) {
          _showSuccessSnackBar(context, 'Password reset successfully');
          return true;
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      Log.e('Reset password error: $e'); // For debugging
      // Let the calling screen handle error display for better UX control
      rethrow;
    }
    return false; // Return false if reset failed
  }

  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email.trim(),
              'password': password.trim(),
            }),
          )
          .timeout(_httpTimeout);

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
          createdAt:
          userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'])
              : null,
          updatedAt:
          userData['updatedAt'] != null
              ? DateTime.parse(userData['updatedAt'])
              : null,
          profileImageUrl: userData['profileImage']?['url'],
        );

        if (context != null && context.mounted) {
          // Check if email is verified before redirecting
          if (_currentUser!.emailVerified) {
            _showSuccessSnackBar(context, 'Welcome back!');
            context.go('/home/0');
          } else {
            // Don't show success snackbar when redirecting to email verification
            context.go(
              '/email-verification?email=${Uri.encodeComponent(email)}&isFromLogin=true',
            );
          }
        }

        // Notify listeners of auth state change
        _authStateController.add(_currentUser);
        return _currentUser;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Email not verified or access denied - check if it's email verification issue
        final errorData = json.decode(response.body);
        if (errorData['message']?.contains('verify your email') == true ||
            errorData['message']?.contains('Email not verified') == true) {
          if (context != null && context.mounted) {
            context.go(
              '/email-verification?email=${Uri.encodeComponent(email)}&isFromLogin=true',
            );
          }
          // Don't show snackbar here as we're redirecting to verification screen
          throw Exception('Please verify your email to continue');
        } else {
          throw Exception(errorData['message'] ?? 'Login failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      Log.e('Login error: $e'); // For debugging
      // Let the calling screen handle error display for better UX control
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
      Log.e('Logout error: $e'); // For debugging
      // Even if logout fails on server, clear local state
      _accessToken = null;
      _currentUser = null;
      _authStateController.add(null);

      // Ensure token is cleared from local storage even on server error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');

      if (context != null) {
        if (!context.mounted) return;
        context.go('/login');
      }
      throw Exception('Error signing out: ${e.toString()}');
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  // Refresh user data
  Future<void> refreshUser() async {
    if (_accessToken == null) {
      throw Exception('No access token available');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/me'),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['data']['user'];

        _currentUser = UserModel(
          uid: userData['_id'],
          displayName: userData['displayName'] ?? '',
          email: userData['email'] ?? '',
          emailVerified: userData['emailVerified'] ?? false,
          createdAt:
          userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'])
              : null,
          updatedAt:
          userData['updatedAt'] != null
              ? DateTime.parse(userData['updatedAt'])
              : null,
          profileImageUrl: userData['profileImage']?['url'],
        );

        _authStateController.add(_currentUser);
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await _clearLocalAuthState();
        throw Exception('Token expired');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to refresh user data');
      }
    } on TimeoutException {
      throw Exception('Network timeout. Please check your connection.');
    } catch (e) {
      // Only clear state if it's an auth error, not network error
      if (e.toString().contains('Token expired') ||
          e.toString().contains('401')) {
        await _clearLocalAuthState();
      }
      Log.e('Error refreshing user: $e');
      rethrow; // Re-throw to let caller handle the error
    }
  }

  // Clear local auth state without calling logout API
  Future<void> _clearLocalAuthState() async {
    _accessToken = null;
    _currentUser = null;

    // Clear token from local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');

    // Notify listeners of auth state change
    _authStateController.add(null);
  }

  // Email verification methods
  Future<void> resendVerificationEmail(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/resend-verification'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email.trim()}),
          )
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        // Success - verification email sent
        return;
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        if (errorData['message']?.contains('already verified') == true) {
          throw Exception('Email is already verified');
        } else {
          throw Exception(
            errorData['message'] ?? 'Failed to resend verification email',
          );
        }
      } else if (response.statusCode == 404) {
        throw Exception('User not found with this email');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to resend verification email',
        );
      }
    } on TimeoutException {
      throw Exception(
        'Network timeout. Please check your connection and try again.',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow; // Re-throw our custom exceptions
      }
      // Handle network errors
      throw Exception(
        'Network error. Please check your connection and try again.',
      );
    }
  }

  // Check if current user's email is verified
  bool get isEmailVerified => _currentUser?.emailVerified ?? false;

  // Debug method to get current auth state
  Map<String, dynamic> get debugAuthState => {
    'hasToken': _accessToken != null,
    'hasUser': _currentUser != null,
    'userEmail': _currentUser?.email,
    'emailVerified': _currentUser?.emailVerified,
    'isAuthenticated': isAuthenticated,
  };

  // Dispose of resources
  void dispose() {
    _authStateController.close();
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
}
