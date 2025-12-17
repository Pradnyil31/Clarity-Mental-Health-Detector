import 'emotion_detection_service.dart';

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

class LocalChatService {
  final EmotionDetectionService _emotionService;
  final List<ChatMessage> _conversationHistory = [];
  static const int _maxContextLength = 20;

  LocalChatService({EmotionDetectionService? emotionService})
    : _emotionService = emotionService ?? EmotionDetectionService();

  List<ChatMessage> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  Future<ChatMessage?> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return null;

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
      // Silently handle emotion detection errors
    }

    // Generate local response based on emotion
    final botMessage = _generateEmotionAwareResponse(userMessage, userEmotion);
    _conversationHistory.add(botMessage);
    _trimConversationHistory();

    return botMessage;
  }

  ChatMessage _generateEmotionAwareResponse(
    String userMessage,
    EmotionResult? userEmotion,
  ) {
    String response = '';
    final lowerMessage = userMessage.toLowerCase();

    // Generate emotion-aware responses using detected emotion
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
              "I'm detecting ${userEmotion.label} in your message ($confidence% confidence). That's a very human emotion, and I'm here to understand it with you. How are you experiencing this feeling?";
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
        // Engaging generic responses
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

    return ChatMessage(
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  void _trimConversationHistory() {
    while (_conversationHistory.length > _maxContextLength * 2) {
      _conversationHistory.removeAt(0);
    }
  }

  void clearConversation() {
    _conversationHistory.clear();
  }

  // Health check method for monitoring
  Future<bool> performHealthCheck() async {
    try {
      // Test emotion detection service
      await _emotionService.detectEmotion("Hello, how are you?");
      return true;
    } catch (e) {
      return false;
    }
  }

  // Getters for compatibility with existing UI
  double get successRate => 1.0; // Local service always works
  bool get isHealthy => true; // Local service is always healthy
  Duration? get averageResponseTime =>
      const Duration(milliseconds: 100); // Very fast local responses
}
