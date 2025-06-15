import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  // Replace this with your actual OpenAI API key
  static const String apiKey = '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';
  static const String apiUrl = 'https://api.openai.com/v1/chat/completions';

  // Store chat history for context
  final Map<String, List<Map<String, String>>> _chatHistories = {};

  Future<String> analyzeHeadlines(List<String> headlines) async {
    try {
      print('🤖 OpenAI: Analyzing ${headlines.length} headlines');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-4.1',
          'messages': [
            {
              'role': 'developer',
              'content': 'You are a news analyst. Analyze the following headlines and provide a brief summary of the main stories and their potential impact.'
            },
            {
              'role': 'user',
              'content': 'Here are the headlines:\n${headlines.join('\n')}'
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ OpenAI: Headlines analyzed successfully');
        return data['choices'][0]['message']['content'];
      } else {
        print('❌ OpenAI: Failed to analyze headlines. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to analyze headlines: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ OpenAI: Error analyzing headlines: $e');
      throw Exception('Failed to connect to OpenAI: $e');
    }
  }

  Future<String> getBulletPoints(String content) async {
    try {
      print('🤖 OpenAI: Creating bullet points');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-4.1',
          'messages': [
            {
              'role': 'developer',
              'content': '''You are a helpful news assistant. Create a clear, easy-to-read bullet point summary of the article. Follow these guidelines:
• Use simple, everyday language
• Focus on the most important 5-7 points
• Start each point with a bullet (•)
• Keep each point brief and clear
• Avoid technical jargon unless necessary
• Make it easy for anyone to understand'''
            },
            {
              'role': 'user',
              'content': 'Please create bullet points for this article:\n$content'
            }
          ],
          'temperature': 0.5,
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ OpenAI: Bullet points created successfully');
        return data['choices'][0]['message']['content'];
      } else {
        print('❌ OpenAI: Failed to create bullet points. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to create bullet points: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ OpenAI: Error creating bullet points: $e');
      throw Exception('Failed to connect to OpenAI: $e');
    }
  }

  Future<String> getSummary(String content) async {
    try {
      print('🤖 OpenAI: Creating summary');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-4.1',
          'messages': [
            {
              'role': 'developer',
              'content': '''You are a friendly news assistant. Create a natural, flowing summary of the article. Follow these guidelines:
• Write in a conversational, easy-to-understand style
• Use simple, everyday language
• Keep it under 150 words
• Focus on the main story and key details
• Make it engaging and interesting to read
• Avoid technical terms unless necessary
• Write as if you're explaining it to a friend'''
            },
            {
              'role': 'user',
              'content': 'Please summarize this article in a friendly, easy-to-understand way:\n$content'
            }
          ],
          'temperature': 0.7,
          'max_tokens': 250,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ OpenAI: Summary created successfully');
        return data['choices'][0]['message']['content'];
      } else {
        print('❌ OpenAI: Failed to create summary. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to create summary: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ OpenAI: Error creating summary: $e');
      throw Exception('Failed to connect to OpenAI: $e');
    }
  }

  Future<String> initializeChat(String articleUrl, String summary) async {
    try {
      print('🤖 OpenAI: Initializing chat with article context');
      
      // Initialize chat history with the article context
      _chatHistories[articleUrl] = [
        {
          'role': 'developer',
          'content': '''You are a friendly news assistant. Help users understand the article better. Follow these guidelines:
• Be conversational and friendly
• Use simple, clear language
• If you're not sure about something, say so
• Keep your answers concise but helpful
• Make complex topics easy to understand
• Be helpful and informative
• Write as if you're chatting with a friend

Here is the article summary for context:
$summary'''
        },
        {
          'role': 'assistant',
          'content': '''I've read the article summary. Here's what I understand:

$summary

Feel free to ask me any questions about the article. I'm here to help you understand it better!'''
        }
      ];

      print('✅ OpenAI: Chat initialized with article context');
      return _chatHistories[articleUrl]![1]['content']!;
    } catch (e) {
      print('❌ OpenAI: Error initializing chat: $e');
      throw Exception('Failed to initialize chat: $e');
    }
  }

  Future<String> chatWithAI(String message, String articleUrl) async {
    try {
      print('🤖 OpenAI: Processing chat message');
      
      if (!_chatHistories.containsKey(articleUrl)) {
        throw Exception('Chat not initialized. Please initialize chat first.');
      }

      // Add user message to history
      _chatHistories[articleUrl]!.add({
        'role': 'user',
        'content': message,
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-4.1',
          'messages': _chatHistories[articleUrl]!,
          'temperature': 0.7,
          'max_tokens': 400,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        
        // Add AI response to history
        _chatHistories[articleUrl]!.add({
          'role': 'assistant',
          'content': aiResponse,
        });

        print('✅ OpenAI: Chat response received');
        return aiResponse;
      } else {
        print('❌ OpenAI: Failed to get chat response. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to get chat response: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ OpenAI: Error in chat: $e');
      throw Exception('Failed to connect to OpenAI: $e');
    }
  }

  void clearChatHistory(String articleUrl) {
    _chatHistories.remove(articleUrl);
    print('🧹 OpenAI: Chat history cleared for article: $articleUrl');
  }
} 