import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/emotion_detection_service.dart';
import '../services/emotion_config.dart';
import '../repositories/chat_repository.dart';
import '../models/chat_message.dart';
import '../state/user_state.dart';
import '../utils/app_logger.dart';
import '../utils/responsive_utils.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatMessage {
  _ChatMessage({
    required this.text,
    required this.isUser,
    this.analysis,
    this.suggestedActions,
  });
  final String text;
  final bool isUser;
  final EmotionResult? analysis;
  final List<AppAction>? suggestedActions;
}

class AppAction {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Color color;

  AppAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final EmotionDetectionService _emotionService = EmotionDetectionService(
    model: 'distilroberta', // Using working DistilRoBERTa model
  );
  bool _isAnalyzing = false;
  String? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _initializeChatSession();
    _testEmotionDetection(); // Test API on startup
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _testEmotionDetection() async {
    // Test the emotion detection with a simple message
    AppLogger.d('Testing emotion detection...');
    final testResult = await _emotionService.detectEmotion(
      "I'm feeling really happy today!",
    );
    AppLogger.d(
      'Test result: ${testResult?.label} with confidence ${testResult?.confidence}',
    );
  }

  Future<void> _initializeChatSession() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      // Create or get existing chat session
      _currentSessionId = await ChatRepository.createChatSession(userId);

      // Load existing messages
      final messages = await ChatRepository.getChatMessages(
        userId,
        _currentSessionId!,
      );
      setState(() {
        _messages.clear();
        _messages.addAll(
          messages.map(
            (msg) => _ChatMessage(
              text: msg.text,
              isUser: msg.isUser,
              analysis: msg.emotionLabel != null
                  ? EmotionResult(
                      label: msg.emotionLabel!,
                      score: msg.emotionScore ?? 0.0,
                      confidence: msg.emotionScore ?? 0.0,
                      color: Colors.blue,
                      allEmotions: [],
                    )
                  : null,
            ),
          ),
        );
      });
    } catch (e) {
      // Handle error - could show snackbar
      // For now, just continue with empty chat
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _currentSessionId == null) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final userMessage = _ChatMessage(text: text.trim(), isUser: true);
    setState(() {
      _messages.add(userMessage);
      _isAnalyzing = true;
    });
    _controller.clear();
    _scrollToEnd();

    try {
      // Save user message to Firestore
      final userChatMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text.trim(),
        isUser: true,
        timestamp: DateTime.now(),
        sessionId: _currentSessionId!,
      );
      await ChatRepository.addChatMessage(
        userId,
        _currentSessionId!,
        userChatMessage,
      );

      // Use Hugging Face emotion detection
      AppLogger.d('About to call emotion detection for: "$text"');
      final analysis = await _emotionService.detectEmotion(text);
      AppLogger.d(
        'Analysis result: ${analysis?.label} (${analysis?.confidence})',
      );
      final reply = _buildSupportiveReply(text, analysis);
      AppLogger.d('Generated reply: "$reply"');
      final suggestedActions = analysis != null
          ? _getSuggestedActions(analysis.label)
          : <AppAction>[];
      final botMessage = _ChatMessage(
        text: reply,
        isUser: false,
        analysis: analysis,
        suggestedActions: suggestedActions,
      );

      if (mounted) {
        setState(() {
          _messages.add(botMessage);
          _isAnalyzing = false;
        });
        _scrollToEnd();

        // Save bot message to Firestore
        final botChatMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
          emotionLabel: analysis?.label,
          emotionScore: analysis?.score,
          sessionId: _currentSessionId!,
        );
        await ChatRepository.addChatMessage(
          userId,
          _currentSessionId!,
          botChatMessage,
        );
      }
    } catch (e) {
      // Fallback to simple analysis if emotion detection fails
      final fallbackAnalysis = _fallbackEmotionAnalysis(text);
      final reply = _buildSupportiveReply(text, fallbackAnalysis);
      final suggestedActions = _getSuggestedActions(fallbackAnalysis.label);
      final botMessage = _ChatMessage(
        text: reply,
        isUser: false,
        analysis: fallbackAnalysis,
        suggestedActions: suggestedActions,
      );

      if (mounted) {
        setState(() {
          _messages.add(botMessage);
          _isAnalyzing = false;
        });
        _scrollToEnd();

        try {
          // Save user message to Firestore (fallback)
          final userChatMessage = ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: text.trim(),
            isUser: true,
            timestamp: DateTime.now(),
            sessionId: _currentSessionId!,
          );
          await ChatRepository.addChatMessage(
            userId,
            _currentSessionId!,
            userChatMessage,
          );

          // Save bot message to Firestore (fallback)
          final botChatMessage = ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: reply,
            isUser: false,
            timestamp: DateTime.now(),
            emotionLabel: fallbackAnalysis.label,
            emotionScore: fallbackAnalysis.score,
            sessionId: _currentSessionId!,
          );
          await ChatRepository.addChatMessage(
            userId,
            _currentSessionId!,
            botChatMessage,
          );
        } catch (saveError) {
          // Handle save error - could show snackbar
        }
      }
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  EmotionResult _fallbackEmotionAnalysis(String text) {
    final lc = text.toLowerCase();
    int pos = 0;
    int neg = 0;

    // Very simple keyword/emoji scoring. Keeps everything on-device.
    const positive = [
      'grateful',
      'hope',
      'calm',
      'proud',
      'good',
      'great',
      'happy',
      'better',
      'relief',
      'relieved',
      'love',
      'joy',
      '🙂',
      '😊',
      '💪',
      '❤️',
    ];
    const negative = [
      'anxious',
      'anxiety',
      'sad',
      'down',
      'depressed',
      'stressed',
      'angry',
      'fear',
      'panic',
      'tired',
      'overwhelmed',
      'lonely',
      'hopeless',
      '😭',
      '😞',
      '😔',
    ];

    for (final w in positive) {
      if (lc.contains(w)) pos += 2;
    }
    for (final w in negative) {
      if (lc.contains(w)) neg += 2;
    }

    // Intensifiers / negations
    if (lc.contains('very ') || lc.contains('really ') || lc.contains('so ')) {
      if (pos > neg) {
        pos += 1;
      } else if (neg > pos) {
        neg += 1;
      }
    }
    if (lc.contains("not ") || lc.contains("don't ") || lc.contains("no ")) {
      // crude flip towards neutral
      if (pos > 0) pos -= 1;
      if (neg > 0) neg -= 1;
    }

    final delta = pos - neg; // >0 positive, <0 negative
    final magnitude = (pos + neg).clamp(0, 10) / 10.0;

    if (delta >= 2) {
      return EmotionResult(
        label: 'joy',
        score: 0.6 + 0.4 * magnitude,
        confidence: 0.6 + 0.4 * magnitude,
        color: Colors.green,
        allEmotions: [
          {'label': 'joy', 'score': 0.6 + 0.4 * magnitude},
          {'label': 'neutral', 'score': 0.4 - 0.4 * magnitude},
        ],
      );
    } else if (delta <= -2) {
      return EmotionResult(
        label: 'sadness',
        score: 0.6 + 0.4 * magnitude,
        confidence: 0.6 + 0.4 * magnitude,
        color: Colors.red,
        allEmotions: [
          {'label': 'sadness', 'score': 0.6 + 0.4 * magnitude},
          {'label': 'neutral', 'score': 0.4 - 0.4 * magnitude},
        ],
      );
    } else {
      return EmotionResult(
        label: 'neutral',
        score: 0.5,
        confidence: 0.5,
        color: Colors.grey,
        allEmotions: [
          {'label': 'neutral', 'score': 1.0},
        ],
      );
    }
  }

  List<AppAction> _getSuggestedActions(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'sadness':
      case 'grief':
      case 'disappointment':
        return [
          AppAction(
            title: 'Mood Tracker',
            description: 'Log your current mood',
            icon: Icons.mood,
            route: '/mood-tracker',
            color: Colors.blue,
          ),
          AppAction(
            title: 'Journal',
            description: 'Write about your feelings',
            icon: Icons.book,
            route: '/journal',
            color: Colors.purple,
          ),
          AppAction(
            title: 'CBT Exercises',
            description: 'Cognitive behavioral techniques',
            icon: Icons.psychology,
            route: '/cbt',
            color: Colors.teal,
          ),
        ];

      case 'anger':
      case 'annoyance':
        return [
          AppAction(
            title: 'Breathing Exercise',
            description: 'Calm down with guided breathing',
            icon: Icons.air,
            route: '/exercise',
            color: Colors.green,
          ),
          AppAction(
            title: 'Journal',
            description: 'Express your thoughts safely',
            icon: Icons.book,
            route: '/journal',
            color: Colors.purple,
          ),
          AppAction(
            title: 'CBT Exercises',
            description: 'Manage anger with CBT',
            icon: Icons.psychology,
            route: '/cbt',
            color: Colors.teal,
          ),
        ];

      case 'fear':
      case 'nervousness':
        return [
          AppAction(
            title: 'Breathing Exercise',
            description: 'Reduce anxiety with breathing',
            icon: Icons.air,
            route: '/exercise',
            color: Colors.green,
          ),
          AppAction(
            title: 'Assessment',
            description: 'Check your anxiety levels',
            icon: Icons.assessment,
            route: '/assessment',
            color: Colors.orange,
          ),
          AppAction(
            title: 'CBT Exercises',
            description: 'Anxiety management techniques',
            icon: Icons.psychology,
            route: '/cbt',
            color: Colors.teal,
          ),
        ];

      case 'joy':
      case 'excitement':
      case 'gratitude':
        return [
          AppAction(
            title: 'Mood Tracker',
            description: 'Record this positive moment',
            icon: Icons.mood,
            route: '/mood-tracker',
            color: Colors.blue,
          ),
          AppAction(
            title: 'Journal',
            description: 'Capture this feeling',
            icon: Icons.book,
            route: '/journal',
            color: Colors.purple,
          ),
          AppAction(
            title: 'Happiness',
            description: 'Explore happiness practices',
            icon: Icons.sentiment_very_satisfied,
            route: '/happiness',
            color: Colors.amber,
          ),
        ];

      case 'embarrassment':
      case 'remorse':
        return [
          AppAction(
            title: 'Self-Esteem',
            description: 'Build self-compassion',
            icon: Icons.favorite,
            route: '/self-esteem',
            color: Colors.pink,
          ),
          AppAction(
            title: 'Journal',
            description: 'Process these feelings',
            icon: Icons.book,
            route: '/journal',
            color: Colors.purple,
          ),
          AppAction(
            title: 'CBT Exercises',
            description: 'Challenge negative thoughts',
            icon: Icons.psychology,
            route: '/cbt',
            color: Colors.teal,
          ),
        ];

      case 'confusion':
      case 'curiosity':
        return [
          AppAction(
            title: 'Insights',
            description: 'Explore your patterns',
            icon: Icons.insights,
            route: '/insights',
            color: Colors.indigo,
          ),
          AppAction(
            title: 'Assessment',
            description: 'Better understand yourself',
            icon: Icons.assessment,
            route: '/assessment',
            color: Colors.orange,
          ),
          AppAction(
            title: 'Journal',
            description: 'Explore your thoughts',
            icon: Icons.book,
            route: '/journal',
            color: Colors.purple,
          ),
        ];

      default:
        return [
          AppAction(
            title: 'Mood Tracker',
            description: 'Check in with yourself',
            icon: Icons.mood,
            route: '/mood-tracker',
            color: Colors.blue,
          ),
          AppAction(
            title: 'Journal',
            description: 'Reflect on your day',
            icon: Icons.book,
            route: '/journal',
            color: Colors.purple,
          ),
        ];
    }
  }

  String _buildSupportiveReply(String userText, EmotionResult? analysis) {
    if (analysis == null) {
      return "Thanks for sharing. How are you feeling right now? Sometimes a quick mood check or journaling can help process what's on your mind.";
    }

    // Show confidence level in response for debugging
    final confidenceText = analysis.confidence > 0.7
        ? "I can clearly sense"
        : analysis.confidence > 0.5
        ? "I'm picking up on"
        : "I'm getting a sense of";

    final confidenceLevel = "${(analysis.confidence * 100).round()}%";

    switch (analysis.label) {
      // Positive emotions
      case 'joy':
        return "🎉 DETECTED JOY (${confidenceLevel} confidence)! That's absolutely wonderful to hear! Your happiness is shining through your message. Positive emotions like joy can really boost your wellbeing and resilience. I've suggested some ways below to capture and build on this beautiful feeling.";

      case 'sadness':
        return "💙 DETECTED SADNESS (${confidenceLevel} confidence). I can really hear the pain in your words, and I want you to know that you're not alone in feeling this way. Sadness is a natural human emotion, and it's okay to sit with these feelings. I've suggested some gentle tools below that might provide comfort and support right now.";

      case 'anger':
        return "🔥 DETECTED ANGER (${confidenceLevel} confidence). I can sense the intensity of your frustration, and that's completely valid. Anger often signals that something important to you has been affected or violated. It's a powerful emotion that deserves acknowledgment. Check out the suggestions below for healthy ways to process and channel these strong feelings.";

      case 'fear':
        return "🛡️ DETECTED FEAR (${confidenceLevel} confidence). I can feel the anxiety and worry in your message. Fear is our mind's way of trying to protect us, even when it feels overwhelming. You're brave for sharing these vulnerable feelings. I've suggested some grounding tools below that can help you feel more secure and calm.";

      case 'surprise':
        return "⚡ DETECTED SURPRISE (${confidenceLevel} confidence)! It sounds like something unexpected just happened in your world. Surprises can be exciting, overwhelming, or both at the same time. Your mind is probably processing this new information. I've suggested some ways below to help you work through this unexpected moment.";

      case 'disgust':
        return "🚫 DETECTED DISGUST (${confidenceLevel} confidence). That sounds like a really strong negative reaction to something. Disgust is our emotional way of saying 'this doesn't align with my values' or 'this feels wrong to me.' It's completely okay to feel this way. I've suggested some coping strategies below that might help you process these intense feelings.";

      case 'neutral':
        return "⚖️ DETECTED NEUTRAL TONE (${confidenceLevel} confidence). You seem to be in a balanced emotional space right now, which can be really peaceful. Sometimes neutral moments are exactly what we need. I've suggested some helpful tools below for reflection and gentle self-care.";

      // Fallback for any other emotions
      default:
        return "🤖 DETECTED ${analysis.label.toUpperCase()} (${confidenceLevel} confidence). I can sense the ${analysis.label} in your message. Every emotion has value and tells us something important about our inner world. Thank you for sharing this with me. I've suggested some helpful tools below that might support you right now.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFFAFAFA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F0F0F),
                  ]
                : [
                    const Color(0xFFE8F4FD),
                    const Color(0xFFF0F8FF),
                    const Color(0xFFFAFAFA),
                  ],
          ),
        ),
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(context, scheme, isDark),

            // Messages List
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(context, scheme)
                  : _buildMessagesList(context, scheme),
            ),

            // Input Area
            _buildInputArea(context, scheme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(
    BuildContext context,
    ColorScheme scheme,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF0F3460),
                ]
              : [
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                  const Color(0xFFf093fb),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: ResponsiveUtils.allPadding(context),
          child: Row(
            children: [
              // Back Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Always navigate to home to ensure proper tab highlighting
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Chat Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Clarity Assistant',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context,
                                small: 18, medium: 19, large: 20),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      EmotionConfig.hasValidApiKey
                          ? 'AI-powered emotion detection active'
                          : 'Using local emotion analysis',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context,
                            small: 12, medium: 13, large: 14),
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  tooltip: 'New conversation',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showNewConversationDialog(context);
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Chat Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: 0.1),
                    scheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 60,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 32),

            // Welcome Text
            Text(
              'Welcome to Clarity Chat',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'I\'m here to listen and provide support. Share what\'s on your mind, and I\'ll help you process your thoughts and feelings.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Suggested Starters
            _buildSuggestedStarters(context, scheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedStarters(BuildContext context, ColorScheme scheme) {
    final starters = [
      ('How are you feeling?', Icons.mood_rounded),
      ('I\'m feeling anxious', Icons.psychology_rounded),
      ('I had a good day', Icons.sentiment_satisfied_rounded),
      ('I need support', Icons.support_agent_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try saying:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: starters.map((starter) {
            return _buildStarterChip(context, scheme, starter.$1, starter.$2);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStarterChip(
    BuildContext context,
    ColorScheme scheme,
    String text,
    IconData icon,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _controller.text = text;
          _sendMessage(text);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primaryContainer.withValues(alpha: 0.3),
                scheme.secondaryContainer.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, ColorScheme scheme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length + (_isAnalyzing ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isAnalyzing && index == _messages.length) {
          return _buildTypingIndicator(context, scheme);
        }

        final message = _messages[index];
        return _buildMessageBubble(context, scheme, message, index);
      },
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ColorScheme scheme,
    _ChatMessage message,
    int index,
  ) {
    final isUser = message.isUser;
    final isLastMessage = index == _messages.length - 1;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLastMessage ? 20 : 16,
        left: isUser ? 60 : 0,
        right: isUser ? 0 : 60,
      ),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Message Bubble
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isUser
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primary,
                        scheme.primary.withValues(alpha: 0.8),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.surfaceContainerHighest,
                        scheme.surfaceContainer,
                      ],
                    ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 6),
                bottomRight: Radius.circular(isUser ? 6 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isUser ? scheme.primary : scheme.shadow).withValues(
                    alpha: 0.1,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: isUser ? Colors.white : scheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Emotion Analysis for Bot Messages
                if (!isUser && message.analysis != null) ...[
                  const SizedBox(height: 12),
                  _buildEmotionChip(context, message.analysis!),
                ],

                // Suggested Actions for Bot Messages
                if (!isUser &&
                    message.suggestedActions != null &&
                    message.suggestedActions!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSuggestedActions(
                    context,
                    scheme,
                    message.suggestedActions!,
                  ),
                ],
              ],
            ),
          ),

          // Timestamp
          const SizedBox(height: 4),
          Text(
            _formatTime(DateTime.now()),
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedActions(
    BuildContext context,
    ColorScheme scheme,
    List<AppAction> actions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested for you:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: actions
              .map((action) => _buildActionButton(context, action))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, AppAction action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _navigateToScreen(context, action.route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: action.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: action.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: 16, color: action.color),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: action.color,
                    ),
                  ),
                  Text(
                    action.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: action.color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String route) {
    // Navigate to the specified screen
    switch (route) {
      case '/mood-tracker':
        Navigator.of(context).pushNamed('/mood-tracker');
        break;
      case '/journal':
        Navigator.of(context).pushNamed('/journal');
        break;
      case '/cbt':
        Navigator.of(context).pushNamed('/cbt');
        break;
      case '/exercise':
        Navigator.of(context).pushNamed('/exercise');
        break;
      case '/assessment':
        Navigator.of(context).pushNamed('/assessment');
        break;
      case '/happiness':
        Navigator.of(context).pushNamed('/happiness');
        break;
      case '/self-esteem':
        Navigator.of(context).pushNamed('/self-esteem');
        break;
      case '/insights':
        Navigator.of(context).pushNamed('/insights');
        break;
      default:
        // Fallback to home
        Navigator.of(context).pushNamed('/');
    }
  }

  Widget _buildEmotionChip(BuildContext context, EmotionResult analysis) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: analysis.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: analysis.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: analysis.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${analysis.label.toUpperCase()} • ${(analysis.confidence * 100).round()}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: analysis.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context, ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 60),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(scheme.primary, 0),
                const SizedBox(width: 4),
                _buildTypingDot(scheme.primary, 200),
                const SizedBox(width: 4),
                _buildTypingDot(scheme.primary, 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(Color color, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3 + (0.7 * value)),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea(
    BuildContext context,
    ColorScheme scheme,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Text Input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: scheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    style: TextStyle(fontSize: 16, color: scheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Share what\'s on your mind...',
                      hintStyle: TextStyle(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Send Button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isAnalyzing
                        ? [
                            scheme.outline.withValues(alpha: 0.3),
                            scheme.outline.withValues(alpha: 0.2),
                          ]
                        : [
                            scheme.primary,
                            scheme.primary.withValues(alpha: 0.8),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _isAnalyzing
                      ? null
                      : [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isAnalyzing
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            _sendMessage(_controller.text);
                          },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      child: _isAnalyzing
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewConversationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Conversation'),
        content: const Text(
          'Are you sure you want to start a new conversation? This will clear your current chat history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _messages.clear());
            },
            child: const Text('Start New'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
