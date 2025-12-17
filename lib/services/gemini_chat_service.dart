import 'package:google_generative_ai/google_generative_ai.dart';
import 'emotion_detection_service.dart';
import 'gemini_config.dart';
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

class GeminiChatService {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
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
  static const int _maxContextLength = 20; // Gemini can handle more context

  GeminiChatService._({
    required String apiKey,
    EmotionDetectionService? emotionService,
  }) : _emotionService = emotionService ?? EmotionDetectionService() {
    _initializeGemini(apiKey);
  }

  static Future<GeminiChatService> create({
    String? apiKey,
    EmotionDetectionService? emotionService,
  }) async {
    String key = apiKey ?? '';

    if (key.isEmpty) {
      key = await GeminiConfig.getApiKey() ?? '';
    }

    if (key.isEmpty) {
      throw Exception(
        'Gemini API key is required. Please configure it in the app settings.',
      );
    }

    return GeminiChatService._(apiKey: key, emotionService: emotionService);
  }

  void _initializeGemini(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.8,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(_getSystemPrompt()),
    );

    _chatSession = _model.startChat();
  }

  String _getSystemPrompt() {
    return '''You are a compassionate AI mental health companion integrated into a mental health app called Clarity. Your role is to:

1. Provide empathetic, supportive responses to users sharing their thoughts and feelings
2. Help users process emotions in a healthy way
3. Offer gentle guidance and coping strategies when appropriate
4. Be warm, understanding, and non-judgmental
5. Recognize when users might need professional help and gently suggest it

Key guidelines:
- Always acknowledge and validate the user's emotions
- Use a warm, conversational tone
- Ask thoughtful follow-up questions to encourage reflection
- Provide practical coping strategies when relevant
- Be concise but meaningful in your responses
- Never provide medical diagnoses or replace professional therapy
- If a user expresses thoughts of self-harm, encourage them to seek immediate professional help

You will receive information about the user's detected emotions to help you provide more contextually appropriate responses. Use this emotional context to tailor your empathy and support.''';
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
      // Prepare the message with emotion context
      String messageWithContext = userMessage.trim();

      if (userEmotion != null) {
        final confidence = (userEmotion.confidence * 100).round();
        messageWithContext =
            '''User message: "$userMessage"

Detected emotion: ${userEmotion.label} (${confidence}% confidence)

Please respond with empathy and understanding, taking into account the detected emotion. Acknowledge their emotional state naturally in your response.''';
      }

      // Send message to Gemini
      final response = await _chatSession.sendMessage(
        Content.text(messageWithContext),
      );

      stopwatch.stop();
      _recordResponseTime(stopwatch.elapsed);

      if (response.text != null && response.text!.isNotEmpty) {
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
          content: response.text!.trim(),
          isUser: false,
          timestamp: DateTime.now(),
        );

        _conversationHistory.add(botMessage);
        _trimConversationHistory();

        return botMessage;
      } else {
        _consecutiveFailures++;
        _updateHealthCheck(
          ModelStatus.error,
          stopwatch.elapsed,
          'Empty response from Gemini',
          false,
        );
        return _generateFallbackResponse(userMessage, userEmotion);
      }
    } catch (e) {
      stopwatch.stop();
      _consecutiveFailures++;

      String errorMessage = 'Gemini API error: ${e.toString()}';
      AppLogger.e('Gemini error', error: e);

      _updateHealthCheck(
        ModelStatus.error,
        stopwatch.elapsed,
        errorMessage,
        false,
      );
      return _generateFallbackResponse(userMessage, userEmotion);
    }
  }

  ChatMessage _generateFallbackResponse(
    String userMessage,
    EmotionResult? userEmotion,
  ) {
    AppLogger.i('Using intelligent emotion-aware fallback response');

    String response = '';
    final lowerMessage = userMessage.toLowerCase();

    // Generate highly intelligent emotion-aware responses
    if (userEmotion != null) {
      final confidence = (userEmotion.confidence * 100).round();

      switch (userEmotion.label.toLowerCase()) {
        case 'joy':
        case 'excitement':
        case 'amusement':
          final joyResponses = [
            "I can really feel the joy in your message! (${confidence}% confidence) What's bringing you such happiness today?",
            "Your excitement is absolutely contagious! Tell me more about what's making you feel so wonderful.",
            "That's fantastic! I love seeing such positive energy. What's the source of all this joy?",
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
          ];
          response =
              loveResponses[DateTime.now().millisecond % loveResponses.length];
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
        ];
        response = greetings[DateTime.now().millisecond % greetings.length];
      } else {
        final fallbackResponses = [
          "That's really fascinating. I can tell there's more to this story - would you like to share more details?",
          "I'm genuinely interested in what you're sharing. How does this situation make you feel?",
          "I'm here and fully focused on you. What's the most important aspect of this for you right now?",
          "Thank you for trusting me with this. I'd love to understand your perspective better - can you tell me more?",
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
    // Start a new chat session to clear Gemini's context
    _chatSession = _model.startChat();
  }

  void resetHealthStats() {
    _consecutiveFailures = 0;
    _totalRequests = 0;
    _successfulRequests = 0;
    _responseTimes.clear();
    _lastHealthCheck = null;
  }

  // Method to update API key if needed
  void updateApiKey(String newApiKey) {
    _initializeGemini(newApiKey);
  }
}
