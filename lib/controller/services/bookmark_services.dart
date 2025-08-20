import 'package:brevity/models/article_model.dart';
import 'package:brevity/utils/api_config.dart';
import 'package:brevity/controller/services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'notification_service.dart';

class BookmarkServices {
  static const Duration _httpTimeout = Duration(seconds: 30);
  final AuthService _authService = AuthService();

  /// Get user's bookmarks from backend
  Future<List<Article>> getBookmarks() async {
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
        return data.map((json) => Article.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to fetch bookmarks: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  /// Toggle bookmark status on backend
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

      final NotificationService notificationService = NotificationService();
      await notificationService.updateBookmarkReminder();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isBookmarked(String url) async {
    try {
      final bookmarks = await getBookmarks();
      return bookmarks.any((a) => a.url == url);
    } catch (e) {
      return false;
    }
  }
}
