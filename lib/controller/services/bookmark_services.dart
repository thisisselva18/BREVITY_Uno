import 'package:brevity/models/article_model.dart';
import 'package:brevity/utils/api_config.dart';
import 'package:brevity/controller/services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

class BookmarkServices {
  static const Duration _httpTimeout = Duration(seconds: 30);
  static const String _bookmarksKey = 'user_bookmarks';
  final AuthService _authService = AuthService();

  /// Save bookmarks to local storage
  Future<void> _saveBookmarksToLocal(List<Article> bookmarks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = bookmarks.map((article) => {
        'title': article.title,
        'description': article.description,
        'url': article.url,
        'urlToImage': article.urlToImage,
        'publishedAt': article.publishedAt.toIso8601String(),
        'sourceName': article.sourceName,
        'author': article.author,
        'content': article.content,
      }).toList();
      await prefs.setString(_bookmarksKey, json.encode(bookmarksJson));
    } catch (e) {
      print('Error saving bookmarks to local storage: $e');
    }
  }

  /// Load bookmarks from local storage
  Future<List<Article>> _loadBookmarksFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksString = prefs.getString(_bookmarksKey);
      
      if (bookmarksString == null || bookmarksString.isEmpty) {
        return [];
      }

      final List<dynamic> bookmarksJson = json.decode(bookmarksString);
      return bookmarksJson.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      print('Error loading bookmarks from local storage: $e');
      return [];
    }
  }

  /// Get user's bookmarks from backend
  Future<List<Article>> _getBookmarksFromBackend() async {
    try {
      final token = _authService.accessToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.bookmarksUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_httpTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final bookmarks = data.map((json) => Article.fromJson(json)).toList();
        // Save to local storage for future use
        await _saveBookmarksToLocal(bookmarks);
        return bookmarks;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to fetch bookmarks: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  /// Get bookmarks from local storage immediately (for instant loading)
  Future<List<Article>> getBookmarksFromLocal() async {
    return await _loadBookmarksFromLocal();
  }

  /// Get bookmarks instantly from local and sync in background
  /// Returns local data immediately, then syncs with backend
  Future<List<Article>> getBookmarksWithBackgroundSync({
    Function(List<Article>)? onBackendDataLoaded,
  }) async {
    try {
      // Get local data immediately for instant loading
      final localBookmarks = await _loadBookmarksFromLocal();
      
      // Sync with backend in background
      _syncWithBackendInBackground(onBackendDataLoaded);
      
      return localBookmarks;
    } catch (e) {
      print('Error getting bookmarks from local: $e');
      return [];
    }
  }

  /// Sync with backend in background
  void _syncWithBackendInBackground(Function(List<Article>)? onComplete) async {
    try {
      final backendBookmarks = await _getBookmarksFromBackendSilent();
      if (backendBookmarks.isNotEmpty) {
        await _saveBookmarksToLocal(backendBookmarks);
        onComplete?.call(backendBookmarks);
      }
    } catch (e) {
      print('Background sync failed: $e');
    }
  }

  /// Get user's bookmarks (fetch from backend and merge with local)
  Future<List<Article>> getBookmarks() async {
    try {
      // Always fetch from backend first to get latest data
      final backendBookmarks = await _getBookmarksFromBackendSilent();
      
      if (backendBookmarks.isNotEmpty) {
        // Save the latest backend data to local storage
        await _saveBookmarksToLocal(backendBookmarks);
        return backendBookmarks;
      }
      
      // If backend fails or returns empty, fallback to local storage
      final localBookmarks = await _loadBookmarksFromLocal();
      return localBookmarks;
    } catch (e) {
      print('Error getting bookmarks: $e');
      // Fallback to local storage if backend fails
      return await _loadBookmarksFromLocal();
    }
  }

  /// Get bookmarks from backend without throwing errors (silent)
  Future<List<Article>> _getBookmarksFromBackendSilent() async {
    try {
      final token = _authService.accessToken;
      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse(ApiConfig.bookmarksUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_httpTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => Article.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Clear local bookmarks cache (useful for logout)
  Future<void> clearLocalBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bookmarksKey);
    } catch (e) {
      print('Error clearing local bookmarks: $e');
    }
  }

  /// Force refresh bookmarks from backend (useful for sync)
  Future<List<Article>> refreshBookmarksFromBackend() async {
    try {
      // Clear local cache first
      await clearLocalBookmarks();
      // Fetch fresh data from backend
      return await _getBookmarksFromBackend();
    } catch (e) {
      print('Error refreshing bookmarks from backend: $e');
      return [];
    }
  }

  /// Toggle bookmark status on backend and update local storage
  Future<void> toggleBookmark(Article article) async {
    try {
      final token = _authService.accessToken;
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(ApiConfig.bookmarksUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': article.title,
          'description': article.description,
          'url': article.url,
          'urlToImage': article.urlToImage,
          'publishedAt': article.publishedAt.toIso8601String(),
          'sourceName': article.sourceName,
          'author': article.author,
          'content': article.content,
        }),
      ).timeout(_httpTimeout);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to toggle bookmark: ${response.statusCode}');
      }

      // Update local storage after successful backend operation
      await _updateLocalBookmarks(article);

      final NotificationService notificationService = NotificationService();
      await notificationService.updateBookmarkReminder();
    } catch (e) {
      rethrow;
    }
  }

  /// Update local bookmarks after toggle
  Future<void> _updateLocalBookmarks(Article article) async {
    try {
      final localBookmarks = await _loadBookmarksFromLocal();
      final existingIndex = localBookmarks.indexWhere((a) => a.url == article.url);
      
      if (existingIndex >= 0) {
        // Remove if already bookmarked
        localBookmarks.removeAt(existingIndex);
      } else {
        // Add if not bookmarked
        localBookmarks.add(article);
      }
      
      await _saveBookmarksToLocal(localBookmarks);
    } catch (e) {
      print('Error updating local bookmarks: $e');
    }
  }

  /// Check if article is bookmarked (check latest data)
  Future<bool> isBookmarked(String url) async {
    try {
      // Get the latest bookmarks (which fetches from backend first)
      final bookmarks = await getBookmarks();
      return bookmarks.any((a) => a.url == url);
    } catch (e) {
      // Fallback to local storage if backend fails
      final localBookmarks = await _loadBookmarksFromLocal();
      return localBookmarks.any((a) => a.url == url);
    }
  }
}
