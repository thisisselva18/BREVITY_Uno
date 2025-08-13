import 'package:shared_preferences/shared_preferences.dart';
import 'package:brevity/models/article_model.dart';
import 'dart:convert';

import 'notification_service.dart';

class BookmarkServices {
  static const _bookmarkKey = 'user_bookmarks';
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      if (!_prefs.containsKey(_bookmarkKey)) {
        await _prefs.setStringList(_bookmarkKey, []);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> getBookmarks() async {
    try {
      final bookmarksJson = _prefs.getStringList(_bookmarkKey) ?? [];
      return bookmarksJson.map((json) {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        return Article.fromJson(decoded);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> toggleBookmark(Article article) async {
    try {
      final bookmarks = await getBookmarks();
      final index = bookmarks.indexWhere((a) => a.url == article.url);

      if (index != -1) {
        bookmarks.removeAt(index);
      } else {
        bookmarks.add(article);
      }
      await _prefs.setStringList(
        _bookmarkKey,
        bookmarks.map((a) => jsonEncode(a.toJson())).toList(),
      );

      // Update notification reminder after bookmark change
      final NotificationService notificationService = NotificationService();
      await notificationService.updateBookmarkReminder();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isBookmarked(String url) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((a) => a.url == url);
  }
}
