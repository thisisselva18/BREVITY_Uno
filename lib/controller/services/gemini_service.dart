import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:collection';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiFlashService {
  static const String _modelId = 'gemini-2.0-flash';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$_modelId:generateContent';
  static final String _apiKey = dotenv.env['GEMINI_API_KEY']!;

  static final RateLimiter _limiter = RateLimiter(
    maxRequests: 60,
    timeWindow: const Duration(minutes: 1),
  );

  static Future<String> getFreeResponse(String input) async {
    await _limiter.throttle();
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: _buildOptimizedPayload(input),
      ).timeout(const Duration(seconds: 30));

      return _processResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out');
    }
  }

  static String _buildOptimizedPayload(String input) {
    return jsonEncode({
      'contents': [{
        'parts': [{'text': _compressPrompt(input)}]
      }],
      'generationConfig': {
        'maxOutputTokens': 8000,
        'temperature': 0.4,
      },
      // Valid safety settings configuration
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_NONE'
        }
      ]
    });
  }

  static String _compressPrompt(String input) {
    // Improved compression retains essential punctuation
    return input
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'(?<!\w)[^\w\s\.\!\?](?!\w)'), '');
  }

  static String _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final data = jsonDecode(response.body);
        // Safer response parsing
        if (data['candidates'] == null || 
            data['candidates'].isEmpty ||
            data['candidates'][0]['content'] == null) {
          throw Exception('Invalid API response format');
        }
        return data['candidates'][0]['content']['parts'][0]['text'];
      case 429:
        throw Exception('Rate limit exceeded - Slow down requests');
      case 403:
        throw Exception('Free quota exhausted - Wait for reset');
      default:
        throw Exception('API Error: ${response.statusCode}');
    }
  }
}

class RateLimiter {
  final int maxRequests;
  final Duration timeWindow;
  final Queue<DateTime> _requestTimes = Queue();

  RateLimiter({required this.maxRequests, required this.timeWindow});

  Future<void> throttle() async {
    while (_requestTimes.length >= maxRequests) {
      final oldest = _requestTimes.first;
      final age = DateTime.now().difference(oldest);
      if (age < timeWindow) {
        await Future.delayed(timeWindow - age);
      }
      _requestTimes.removeFirst();
    }
    _requestTimes.add(DateTime.now());
  }
}