import 'package:dio/dio.dart';
import 'emotion_config.dart';
import 'emotion_detection_service.dart';
import 'ai_config.dart';
import '../utils/app_logger.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final EmotionResult? detectedEmotion;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.detectedEmotion,
  });
}

class ChatService {
  static const String _baseUrl = 'https://api-inference.huggingface.co/models';

  // Available chat models - intelligent fallback is most reliable
  static const Map<String, String> _availableModels = {
    // Intelligent fallback (always works, emotion-aware)
    'intelligent-fallback': 'intelligent-fallback',

    // API models (may not work with current API key permissions)
    'gpt2': 'gpt2',
    'distilgpt2': 'distilgpt2',
    'dialoGPT-small': 'microsoft/DialoGPT-small',
    'dialoGPT-medium': 'microsoft/DialoGPT-medium',
    'blenderbot-small': 'facebook/blenderbot_small-90M',
    'blenderbot': 'facebook/blenderbot-400M-distill',
    'dialoGPT-large': 'microsoft/DialoGPT-large',
    'gpt2-medium': 'gpt2-medium',
  };

  final String _currentModel;
  final Dio _dio = Dio();
  final EmotionDetectionService _emotionService;

  // Chat monitoring properties
  ModelHealthCheck? _lastHealthCheck;
  int _consecutiveFailures = 0;
  int _totalRequests = 0;
  int _successfulRequests = 0;
  final List<Duration> _responseTimes = [];
  static const int _maxResponseTimeHistory = 10;
  static const int _maxConsecutiveFailures = 3;

  // Conversation context
  final List<ChatMessage> _conversationHistory = [];
  static const int _maxContextLength = 10; // Keep last 10 messages for context

  ChatService({String? model, EmotionDetectionService? emotionService})
    : _currentModel =
          _availableModels[model ?? AIConfig.chatModel] ??
          _availableModels['blenderbot-large']!,
      _emotionService =
          emotionService ??
          EmotionDetectionService(model: AIConfig.emotionModel) {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  // Public getters for monitoring
  ModelHealthCheck? get lastHealthCheck => _lastHealthCheck;
  double get successRate =>
      _totalRequests > 0 ? _successfulRequests / _totalRequests : 0.0;
  bool get isHealthy => _consecutiveFailures < _maxConsecutiveFailures;
  Duration? get averageResponseTime {
    if (_responseTimes.isEmpty) return null;
    final total = _responseTimes.fold(Duration.zero, (a, b) => a + b);
    return Duration(
      milliseconds: total.inMilliseconds ~/ _responseTimes.length,
    );
  }

  List<ChatMessage> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  Future<ChatMessage?> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return null;

    final stopwatch = Stopwatch()..start();
    _totalRequests++;

    // Add user message to history
    final userChatMessage = ChatMessage(
      content: userMessage.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    _conversationHistory.add(userChatMessage);

    // Detect emotion in user message
    EmotionResult? userEmotion;
    try {
      userEmotion = await _emotionService.detectEmotion(userMessage);
      if (userEmotion != null) {
        // Update the user message with detected emotion
        final updatedUserMessage = ChatMessage(
          content: userMessage.trim(),
          isUser: true,
          timestamp: userChatMessage.timestamp,
          detectedEmotion: userEmotion,
        );
        _conversationHistory[_conversationHistory.length - 1] =
            updatedUserMessage;
      }
    } catch (e) {
      AppLogger.w('Failed to detect emotion', error: e);
    }

    try {
      // Check if we should use intelligent fallback directly
      if (_currentModel == 'intelligent-fallback') {
        AppLogger.i('Using intelligent emotion-aware response system');
        stopwatch.stop();
        _successfulRequests++;
        _consecutiveFailures = 0;
        _updateHealthCheck(
          ModelStatus.responding,
          stopwatch.elapsed,
          null,
          true,
        );
        return _generateFallbackResponse(userMessage, userEmotion);
      }

      // Check if model is in circuit breaker state
      if (!isHealthy) {
        AppLogger.w('Chat model circuit breaker activated - using fallback');
        _updateHealthCheck(
          ModelStatus.notResponding,
          stopwatch.elapsed,
          'Circuit breaker activated due to consecutive failures',
          false,
        );
        return _generateFallbackResponse(userMessage, userEmotion);
      }

      final headers = {'Content-Type': 'application/json'};

      // Add API key if configured
      if (EmotionConfig.hasValidApiKey) {
        headers['Authorization'] = 'Bearer ${EmotionConfig.huggingFaceApiKey}';
        AppLogger.d('Using API key for chat request');
      } else {
        AppLogger.d('No API key configured for chat, using free tier');
      }

      // Prepare conversation context
      final conversationContext = _buildConversationContext();

      // Use the most reliable format - simple text generation
      String prompt = userMessage.trim();

      // Add minimal context for better responses
      if (conversationContext['past_user_inputs']!.isNotEmpty) {
        final lastResponse = conversationContext['generated_responses']!.last;
        prompt = '$lastResponse\nHuman: $userMessage\nAI:';
      } else {
        prompt = 'Human: $userMessage\nAI:';
      }

      final requestData = {
        'inputs': prompt,
        'options': {'wait_for_model': true},
        'parameters': {
          'max_length': prompt.length + 50,
          'temperature': 0.8,
          'do_sample': true,
          'return_full_text': false,
          'stop': ['Human:', '\n\n'],
        },
      };

      AppLogger.d('Making request to model: $_currentModel');
      AppLogger.d('Request data: $requestData');

      // Try the API call but expect it might fail
      final response = await _dio.post(
        '/$_currentModel',
        data: requestData,
        options: Options(headers: headers),
      );

      stopwatch.stop();
      _recordResponseTime(stopwatch.elapsed);

      AppLogger.d('Chat API Response: ${response.statusCode}');
      AppLogger.d('Response time: ${stopwatch.elapsed.inMilliseconds}ms');

      // Validate response
      if (!_isValidChatResponse(response)) {
        _updateHealthCheck(
          ModelStatus.error,
          stopwatch.elapsed,
          'Invalid chat response format',
          false,
        );
        return _generateFallbackResponse(userMessage, userEmotion);
      }

      if (response.statusCode == 200) {
        String botResponse = '';

        AppLogger.d('Raw response data: ${response.data}');
        AppLogger.d('Response data type: ${response.data.runtimeType}');

        // Handle different response formats
        if (response.data is List && (response.data as List).isNotEmpty) {
          final firstItem = (response.data as List)[0];
          if (firstItem is Map && firstItem.containsKey('generated_text')) {
            botResponse = firstItem['generated_text'].toString().trim();
          } else if (firstItem is String) {
            botResponse = firstItem.trim();
          }
        } else if (response.data is Map) {
          final data = response.data as Map;
          if (data.containsKey('generated_text')) {
            botResponse = data['generated_text'].toString().trim();
          } else if (data.containsKey('conversation')) {
            final conversation = data['conversation'];
            if (conversation is Map &&
                conversation.containsKey('generated_responses')) {
              final responses = conversation['generated_responses'] as List;
              if (responses.isNotEmpty) {
                botResponse = responses.last.toString().trim();
              }
            }
          }
        } else if (response.data is String) {
          botResponse = response.data.toString().trim();
        }

        AppLogger.d('Extracted bot response: "$botResponse"');

        if (botResponse.isNotEmpty) {
          _successfulRequests++;
          _consecutiveFailures = 0;
          _updateHealthCheck(
            ModelStatus.responding,
            stopwatch.elapsed,
            null,
            true,
          );

          // Create bot message
          final botMessage = ChatMessage(
            content: _cleanBotResponse(botResponse),
            isUser: false,
            timestamp: DateTime.now(),
          );

          _conversationHistory.add(botMessage);
          _trimConversationHistory();

          return botMessage;
        } else {
          AppLogger.w('Empty bot response, using fallback');
        }
      } else if (response.statusCode == 503) {
        _updateHealthCheck(
          ModelStatus.loading,
          stopwatch.elapsed,
          'Chat model is loading',
          false,
        );
        return _generateFallbackResponse(userMessage, userEmotion);
      }

      // Unexpected response format - always use fallback
      AppLogger.w('Using fallback due to unexpected response format');
      _updateHealthCheck(
        ModelStatus.error,
        stopwatch.elapsed,
        'Unexpected chat response format',
        false,
      );
      return _generateFallbackResponse(userMessage, userEmotion);
    } on DioException catch (e) {
      stopwatch.stop();
      _consecutiveFailures++;

      String errorMessage = 'Unknown error';
      ModelStatus status = ModelStatus.error;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        status = ModelStatus.timeout;
        errorMessage = 'Chat request timeout';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'API key invalid for chat model';
      } else if (e.response?.statusCode == 503) {
        status = ModelStatus.loading;
        errorMessage = 'Chat model is loading';
      } else if (e.response?.statusCode != null) {
        errorMessage =
            'HTTP ${e.response!.statusCode}: ${e.response!.statusMessage}';
      } else {
        errorMessage = e.message ?? 'Network error';
      }

      AppLogger.e('Chat error: $errorMessage', error: e);
      AppLogger.d('Response time: ${stopwatch.elapsed.inMilliseconds}ms');

      _updateHealthCheck(status, stopwatch.elapsed, errorMessage, false);
      return _generateFallbackResponse(userMessage, userEmotion);
    } catch (e) {
      stopwatch.stop();
      _consecutiveFailures++;

      AppLogger.e('Unexpected chat error', error: e);
      AppLogger.d('Response time: ${stopwatch.elapsed.inMilliseconds}ms');

      _updateHealthCheck(
        ModelStatus.error,
        stopwatch.elapsed,
        'Unexpected error: ${e.toString()}',
        false,
      );

      return _generateFallbackResponse(userMessage, userEmotion);
    }
  }

  Map<String, List<String>> _buildConversationContext() {
    final pastUserInputs = <String>[];
    final generatedResponses = <String>[];

    // Get recent conversation history (excluding the current message)
    final recentHistory = _conversationHistory
        .where((msg) => !msg.isUser || msg != _conversationHistory.last)
        .take(_maxContextLength)
        .toList();

    for (int i = 0; i < recentHistory.length - 1; i += 2) {
      if (i + 1 < recentHistory.length) {
        if (recentHistory[i].isUser && !recentHistory[i + 1].isUser) {
          pastUserInputs.add(recentHistory[i].content);
          generatedResponses.add(recentHistory[i + 1].content);
        }
      }
    }

    return {
      'past_user_inputs': pastUserInputs,
      'generated_responses': generatedResponses,
    };
  }

  String _cleanBotResponse(String response) {
    // Remove common artifacts from bot responses
    String cleaned = response
        .replaceAll(
          RegExp(r'^(Bot:|AI:|Assistant:|Human:)\s*', caseSensitive: false),
          '',
        )
        .replaceAll(
          RegExp(r'<\|endoftext\|>.*$'),
          '',
        ) // Remove DialoGPT artifacts
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Remove any trailing incomplete sentences
    if (cleaned.isNotEmpty &&
        !cleaned.endsWith('.') &&
        !cleaned.endsWith('!') &&
        !cleaned.endsWith('?')) {
      final lastSentence = cleaned.lastIndexOf(RegExp(r'[.!?]'));
      if (lastSentence > cleaned.length * 0.5) {
        // Only if we're not removing too much
        cleaned = cleaned.substring(0, lastSentence + 1);
      }
    }

    // Ensure response isn't too long
    if (cleaned.length > 200) {
      final cutoff = cleaned.lastIndexOf(' ', 200);
      if (cutoff > 100) {
        cleaned = cleaned.substring(0, cutoff) + '...';
      }
    }

    return cleaned;
  }

  ChatMessage _generateFallbackResponse(
    String userMessage,
    EmotionResult? userEmotion,
  ) {
    AppLogger.i('Using intelligent emotion-aware fallback response');

    String response = '';
    final lowerMessage = userMessage.toLowerCase();

    // Generate highly intelligent emotion-aware responses using the working emotion detection
    if (userEmotion != null) {
      final confidence = (userEmotion.confidence * 100).round();

      switch (userEmotion.label.toLowerCase()) {
        case 'joy':
        case 'excitement':
        case 'amusement':
          final joyResponses = [
            "I can really feel the joy in your message! ($confidence% confidence) What's bringing you such happiness today?",
            "Your excitement is absolutely contagious! Tell me more about what's making you feel so wonderful.",
            "That's fantastic! I love seeing such positive energy. What's the source of all this joy?",
            "Your happiness really shines through! I'm genuinely excited to hear what's going so well for you.",
          ];
          response =
              joyResponses[DateTime.now().millisecond % joyResponses.length];
          break;

        case 'sadness':
        case 'grief':
        case 'disappointment':
          final sadResponses = [
            "I can sense the sadness in your words, and I want you to know I'm here for you. What's weighing on your heart?",
            "That sounds really difficult. Sometimes when we're feeling down, it helps to talk through what's happening. I'm listening.",
            "I hear the pain in what you're sharing. You don't have to carry this alone - what's been troubling you?",
            "It takes courage to express sadness. I'm here to support you through whatever you're going through. Want to share more?",
          ];
          response =
              sadResponses[DateTime.now().millisecond % sadResponses.length];
          break;

        case 'anger':
        case 'annoyance':
        case 'frustration':
          final angerResponses = [
            "I can tell you're really frustrated about something. Sometimes it helps to get these feelings out - what's bothering you?",
            "That anger is coming through clearly. It sounds like something really got under your skin. Want to talk about it?",
            "I hear the frustration in your message. When we feel this way, there's usually something important behind it. What happened?",
            "It sounds like you're dealing with something really annoying. I'm here to listen if you want to vent about it.",
          ];
          response =
              angerResponses[DateTime.now().millisecond %
                  angerResponses.length];
          break;

        case 'fear':
        case 'nervousness':
        case 'anxiety':
          final fearResponses = [
            "I can sense some anxiety in what you're sharing. Those feelings are completely valid - what's making you feel nervous?",
            "Fear can be overwhelming, but you're not alone with these feelings. What's been worrying you?",
            "I hear the nervousness in your message. Sometimes talking through our fears helps make them feel more manageable. What's on your mind?",
            "Anxiety is such a human experience. You're brave for reaching out. What's been causing you to feel this way?",
          ];
          response =
              fearResponses[DateTime.now().millisecond % fearResponses.length];
          break;

        case 'love':
        case 'caring':
        case 'gratitude':
          final loveResponses = [
            "There's so much warmth and love in your message! It's beautiful to see such caring emotions. What's inspiring these feelings?",
            "I can feel the gratitude radiating from your words. It's wonderful when we feel so connected and thankful. Tell me more!",
            "Your caring nature really comes through. The world needs more people with hearts like yours. What's bringing out these loving feelings?",
            "That's so heartwarming! Love and gratitude are such powerful emotions. I'd love to hear what's behind these beautiful feelings.",
          ];
          response =
              loveResponses[DateTime.now().millisecond % loveResponses.length];
          break;

        case 'curiosity':
        case 'confusion':
          final curiousResponses = [
            "I love your curiosity! There's something you're wondering about, and I'm here to explore it with you. What's got you thinking?",
            "Your inquisitive nature is wonderful! What questions are on your mind? Let's figure this out together.",
            "I can sense you're trying to understand something. That's such a valuable trait! What would you like to explore?",
          ];
          response =
              curiousResponses[DateTime.now().millisecond %
                  curiousResponses.length];
          break;

        case 'pride':
        case 'admiration':
          final prideResponses = [
            "I can feel the pride in your message! That's fantastic - you should absolutely feel proud. What accomplishment are you celebrating?",
            "There's such a sense of achievement in what you're sharing! I'm excited to hear about what's making you feel so proud.",
            "Your sense of pride really comes through! It's wonderful when we recognize our own accomplishments. Tell me more!",
          ];
          response =
              prideResponses[DateTime.now().millisecond %
                  prideResponses.length];
          break;

        case 'surprise':
        case 'realization':
          response =
              "I can sense the surprise in your message! Something unexpected happened, didn't it? I'd love to hear about this revelation.";
          break;

        case 'neutral':
          final neutralResponses = [
            "I'm picking up on a calm, neutral tone from you. Sometimes that's exactly what we need. What's on your mind today?",
            "You seem to be in a balanced headspace right now. How are things going for you?",
            "There's a steady, thoughtful quality to your message. What would you like to talk about?",
          ];
          response =
              neutralResponses[DateTime.now().millisecond %
                  neutralResponses.length];
          break;

        default:
          response =
              "I'm detecting ${userEmotion.label} in your message (${confidence}% confidence). That's a very human emotion, and I'm here to understand it with you. How are you experiencing this feeling?";
      }
    } else {
      // Context-aware responses when no emotion is detected
      if (lowerMessage.contains('hello') ||
          lowerMessage.contains('hi') ||
          lowerMessage.contains('hey')) {
        final greetings = [
          "Hello there! I'm so glad you reached out. How are you feeling today?",
          "Hi! It's wonderful to connect with you. What's on your mind right now?",
          "Hey! I'm here and ready to listen to whatever you'd like to share. How's your day going?",
          "Hello! I'm excited to chat with you. What would you like to talk about?",
        ];
        response = greetings[DateTime.now().millisecond % greetings.length];
      } else if (lowerMessage.contains('how are you')) {
        final statusResponses = [
          "I'm doing wonderfully, thank you for asking! I'm here, present, and ready to focus entirely on you. How are you doing?",
          "I'm great! I love having meaningful conversations like this. More importantly, how are you feeling right now?",
          "I'm doing well and I'm genuinely happy to be here with you. Tell me about your day - how are things going?",
          "I'm fantastic, thanks! But I'm much more interested in how you're doing. What's happening in your world?",
        ];
        response =
            statusResponses[DateTime.now().millisecond %
                statusResponses.length];
      } else if (lowerMessage.contains('thank')) {
        final thankResponses = [
          "You're so very welcome! It means a lot that you appreciate our conversation. What else would you like to explore together?",
          "It's absolutely my pleasure! I'm here because I genuinely care about supporting you. How else can I help?",
          "Thank you for saying that! I really enjoy our chats. What's next on your mind?",
        ];
        response =
            thankResponses[DateTime.now().millisecond % thankResponses.length];
      } else {
        // Highly engaging generic responses
        final fallbackResponses = [
          "That's really fascinating. I can tell there's more to this story - would you like to share more details?",
          "I'm genuinely interested in what you're sharing. How does this situation make you feel?",
          "I'm here and fully focused on you. What's the most important aspect of this for you right now?",
          "Thank you for trusting me with this. I'd love to understand your perspective better - can you tell me more?",
          "That sounds like something that's really on your mind. I'm here to listen and support you through it.",
          "I can tell this matters to you. Sometimes talking through our thoughts helps clarify them - what are you thinking?",
          "I'm curious to learn more about your experience with this. What's been going through your mind?",
          "That's definitely worth exploring together. How long has this been something you've been considering?",
        ];

        response =
            fallbackResponses[DateTime.now().millisecond %
                fallbackResponses.length];
      }
    }

    final botMessage = ChatMessage(
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
    );

    _conversationHistory.add(botMessage);
    _trimConversationHistory();

    return botMessage;
  }

  void _trimConversationHistory() {
    while (_conversationHistory.length > _maxContextLength * 2) {
      _conversationHistory.removeAt(0);
    }
  }

  bool _isValidChatResponse(Response response) {
    return response.statusCode == 200 && response.data != null;
  }

  void _recordResponseTime(Duration responseTime) {
    _responseTimes.add(responseTime);
    if (_responseTimes.length > _maxResponseTimeHistory) {
      _responseTimes.removeAt(0);
    }
  }

  void _updateHealthCheck(
    ModelStatus status,
    Duration responseTime,
    String? errorMessage,
    bool hasValidResponse,
  ) {
    _lastHealthCheck = ModelHealthCheck(
      status: status,
      timestamp: DateTime.now(),
      responseTime: responseTime,
      errorMessage: errorMessage,
      hasValidResponse: hasValidResponse,
    );
  }

  // Health check method for monitoring
  Future<ModelHealthCheck> performHealthCheck() async {
    const testMessage = "Hello, how are you?";
    final stopwatch = Stopwatch()..start();

    try {
      final result = await sendMessage(testMessage);
      stopwatch.stop();

      final isHealthy = result != null && result.content.isNotEmpty;
      _updateHealthCheck(
        isHealthy ? ModelStatus.responding : ModelStatus.error,
        stopwatch.elapsed,
        isHealthy ? null : 'Health check failed - no valid response',
        isHealthy,
      );

      // Remove test message from history
      if (_conversationHistory.length >= 2) {
        _conversationHistory.removeLast(); // bot response
        _conversationHistory.removeLast(); // user message
      }

      return _lastHealthCheck!;
    } catch (e) {
      stopwatch.stop();
      _updateHealthCheck(
        ModelStatus.error,
        stopwatch.elapsed,
        'Health check failed: ${e.toString()}',
        false,
      );
      return _lastHealthCheck!;
    }
  }

  void clearConversation() {
    _conversationHistory.clear();
  }

  void resetHealthStats() {
    _consecutiveFailures = 0;
    _totalRequests = 0;
    _successfulRequests = 0;
    _responseTimes.clear();
    _lastHealthCheck = null;
  }
}
