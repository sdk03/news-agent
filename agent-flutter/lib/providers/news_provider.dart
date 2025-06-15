import 'package:flutter/foundation.dart';
import '../services/news_service.dart';
import '../services/openai_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();
  final OpenAIService _openAIService = OpenAIService();

  List<Map<String, dynamic>> _headlines = [];
  Map<String, String> _bulletPoints = {};
  Map<String, String> _summaries = {};
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get headlines => _headlines;
  Map<String, String> get bulletPoints => _bulletPoints;
  Map<String, String> get summaries => _summaries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHeadlines() async {
    _setLoading(true);
    _error = null;
    try {
      print('📰 NewsProvider: Fetching headlines');
      _headlines = await _newsService.getHeadlines();
      print('✅ NewsProvider: Headlines fetched successfully');
      _setLoading(false);
    } catch (e) {
      print('❌ NewsProvider: Error fetching headlines: $e');
      _error = 'Failed to load headlines. Please try again.';
      _setLoading(false);
    }
  }

  Future<void> fetchArticleSummary(String url) async {
    _setLoading(true);
    _error = null;
    try {
      print('📰 NewsProvider: Fetching article content for $url');
      final content = await _newsService.getArticleContent(url);
      
      if (content == null || content.isEmpty) {
        print('❌ NewsProvider: No content received for article');
        _bulletPoints[url] = 'Sorry, we couldn\'t get the article content. Please try again later.';
        _summaries[url] = 'Sorry, we couldn\'t get the article content. Please try again later.';
        _setLoading(false);
        return;
      }

      print('✅ NewsProvider: Article content fetched successfully');
      
      // Get bullet points
      print('🤖 NewsProvider: Creating bullet points');
      final bulletPoints = await _openAIService.getBulletPoints(content);
      _bulletPoints[url] = bulletPoints;
      print('✅ NewsProvider: Bullet points created successfully');

      // Get summary
      print('🤖 NewsProvider: Creating summary');
      final summary = await _openAIService.getSummary(content);
      _summaries[url] = summary;
      print('✅ NewsProvider: Summary created successfully');

      _setLoading(false);
    } catch (e) {
      print('❌ NewsProvider: Error fetching article summary: $e');
      _error = 'Failed to load summary. Please try again.';
      _bulletPoints[url] = 'Sorry, we couldn\'t create a summary. Please try again later.';
      _summaries[url] = 'Sorry, we couldn\'t create a summary. Please try again later.';
      _setLoading(false);
    }
  }

  Future<String> chatWithAI(String message, String articleUrl) async {
    try {
      print('🤖 NewsProvider: Processing chat message');
      final content = await _newsService.getArticleContent(articleUrl);
      if (content == null || content.isEmpty) {
        return 'Sorry, I couldn\'t access the article content. Please try again later.';
      }
      final response = await _openAIService.chatWithAI(message, articleUrl);
      print('✅ NewsProvider: Chat response received');
      return response;
    } catch (e) {
      print('❌ NewsProvider: Error in chat: $e');
      return 'Sorry, I encountered an error. Please try again.';
    }
  }

  void clearChatHistory(String articleUrl) {
    _openAIService.clearChatHistory(articleUrl);
    print('🧹 NewsProvider: Chat history cleared for article: $articleUrl');
  }

  Future<String> initializeChat(String articleUrl, String summary) async {
    try {
      print('🤖 NewsProvider: Initializing chat');
      final response = await _openAIService.initializeChat(articleUrl, summary);
      print('✅ NewsProvider: Chat initialized successfully');
      return response;
    } catch (e) {
      print('❌ NewsProvider: Error initializing chat: $e');
      throw Exception('Failed to initialize chat: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
} 