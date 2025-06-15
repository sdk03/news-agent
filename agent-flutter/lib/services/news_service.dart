import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  // Use hardcoded URL for now
  static const String baseUrl = 'http://localhost:3000';
  String? _token;

  Future<void> login() async {
    try {
      print('🔑 News Service: Attempting login...');
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': 'admin',
          'password': 'password',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        print('✅ News Service: Login successful');
      } else {
        print('❌ News Service: Login failed. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ News Service: Login error: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<String> getHeadline() async {
    if (_token == null) {
      print('⚠️ News Service: No token found, logging in first...');
      await login();
    }

    try {
      print('📰 News Service: Fetching headline...');
      final response = await http.get(
        Uri.parse('$baseUrl/api/news/khaleej-times/headline'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ News Service: Headline fetched successfully');
        return data['headline'];
      } else {
        print('❌ News Service: Failed to get headline. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to get headline: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ News Service: Error fetching headline: $e');
      throw Exception('Failed to fetch headline: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getHeadlines() async {
    if (_token == null) {
      print('⚠️ News Service: No token found, logging in first...');
      await login();
    }

    try {
      print('📰 News Service: Fetching headlines...');
      final response = await http.get(
        Uri.parse('$baseUrl/api/news/khaleej-times/headlines'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ News Service: Headlines fetched successfully');
        return List<Map<String, dynamic>>.from(data['headlines']);
      } else {
        print('❌ News Service: Failed to get headlines. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to get headlines: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ News Service: Error fetching headlines: $e');
      throw Exception('Failed to fetch headlines: $e');
    }
  }

  Future<String> getArticleContent(String url) async {
    if (_token == null) {
      print('⚠️ News Service: No token found, logging in first...');
      await login();
    }

    try {
      print('📄 News Service: Fetching article content for URL: $url');
      final response = await http.get(
        Uri.parse('$baseUrl/api/news/khaleej-times/article?url=$url'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ News Service: Article content fetched successfully');
        return data['content'].join('\n');
      } else {
        print('❌ News Service: Failed to get article content. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to get article content: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ News Service: Error fetching article content: $e');
      throw Exception('Failed to fetch article content: $e');
    }
  }
} 