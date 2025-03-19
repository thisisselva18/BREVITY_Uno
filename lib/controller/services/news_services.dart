import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:newsai/models/article_model.dart';

class NewsService {
  static const String _apiKey = '6772b7582e9d48b6b72277239f5df490';
  static const String _baseUrl = 'https://newsapi.org/v2/top-headlines';
  
  Future<List<Article>> fetchRandomArticles({int page = 1, int pageSize = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?country=us&page=$page&pageSize=$pageSize&apiKey=$_apiKey')
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseArticles(data['articles']);
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch articles: $e');
    }
  }

  List<Article> _parseArticles(List<dynamic> articlesJson) {
    return articlesJson
        .map((articleJson) => Article.fromJson(articleJson))
        .toList();
  }
}
