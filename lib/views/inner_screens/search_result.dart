import 'package:flutter/material.dart';
import 'package:newsai/controller/services/news_services.dart';
import 'package:newsai/models/article_model.dart';
import 'package:newsai/views/common_widgets/article_list_item.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late Future<List<Article>> _searchResults;
  final NewsService _newsService = NewsService();

  @override
  void initState() {
    super.initState();
    _searchResults = _newsService.searchNews(widget.query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      appBar: AppBar(
        backgroundColor: const Color(0xFF222222),
        title: Text(
          'Results for "${widget.query}"',
          style: const TextStyle(color: Color.fromARGB(221, 249, 249, 249)),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(221, 249, 249, 249)),
      ),
      body: FutureBuilder<List<Article>>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                ),
              ),
            );
          }

          final results = snapshot.data ?? [];
          
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 70, color: Colors.grey[500]),
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "${widget.query}"',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final article = results[index];
              return ArticleListItem(
                article: article,
                onTap: () => _launchArticle(article.url),
                showBookmark: true,
              );
            },
          );
        },
      ),
    );
  }

  void _launchArticle(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF333333),
            content: Text(
              'Failed to open article: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }
}