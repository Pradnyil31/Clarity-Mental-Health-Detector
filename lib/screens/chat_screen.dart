import 'package:flutter/material.dart';
import '../services/emotion_detection_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatMessage {
  _ChatMessage({required this.text, required this.isUser, this.analysis});
  final String text;
  final bool isUser;
  final EmotionResult? analysis;
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final EmotionDetectionService _emotionService = EmotionDetectionService();
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = _ChatMessage(text: text.trim(), isUser: true);
    setState(() {
      _messages.add(userMessage);
      _isAnalyzing = true;
    });
    _controller.clear();
    _scrollToEnd();

    try {
      // Use Hugging Face emotion detection
      final analysis = await _emotionService.detectEmotion(text);
      final reply = _buildSupportiveReply(text, analysis);
      final botMessage = _ChatMessage(
        text: reply,
        isUser: false,
        analysis: analysis,
      );

      if (mounted) {
        setState(() {
          _messages.add(botMessage);
          _isAnalyzing = false;
        });
        _scrollToEnd();
      }
    } catch (e) {
      // Fallback to simple analysis if emotion detection fails
      final fallbackAnalysis = _fallbackEmotionAnalysis(text);
      final reply = _buildSupportiveReply(text, fallbackAnalysis);
      final botMessage = _ChatMessage(
        text: reply,
        isUser: false,
        analysis: fallbackAnalysis,
      );

      if (mounted) {
        setState(() {
          _messages.add(botMessage);
          _isAnalyzing = false;
        });
        _scrollToEnd();
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
      if (pos > neg)
        pos += 1;
      else if (neg > pos)
        neg += 1;
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

  String _buildSupportiveReply(String userText, EmotionResult? analysis) {
    if (analysis == null) {
      return "Thanks for sharing. How are you feeling right now? Sometimes a quick mood check or journaling can help process what's on your mind.";
    }

    switch (analysis.label) {
      case 'sadness':
        return "I hear how tough this feels. You're not alone. Would grounding help right now? Try 4-7-8 breathing or naming 5 things you can see. If you'd like, we can log a quick check-in or write a few thoughts together.";
      case 'joy':
        return "That's encouraging. Noticing what's going well can build momentum. Want to capture this as a note or set a small intention for later today?";
      case 'anger':
        return "I can sense the frustration. It's okay to feel angry. Would you like to try some breathing exercises or write down what's bothering you? Sometimes getting it out can help.";
      case 'fear':
        return "I understand this feels scary. Fear is a natural response. Let's try some grounding techniques - can you name 3 things you can see, hear, and touch right now?";
      case 'surprise':
        return "That sounds unexpected! How are you feeling about this surprise? Sometimes unexpected events can be overwhelming or exciting.";
      case 'disgust':
        return "I can sense some strong feelings here. It's okay to feel this way. Would you like to talk about what's bothering you or try some coping strategies?";
      case 'neutral':
      default:
        return "Thanks for sharing. I'm here to listen. Would you like to reflect more, do a 2‑minute check‑in, or try a short calming exercise?";
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supportive Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop();
            } else {
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'New conversation',
            onPressed: () => setState(() => _messages.clear()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m.isUser;
                final bubbleColor = isUser
                    ? scheme.primaryContainer
                    : scheme.surfaceVariant;
                final textColor = isUser
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant;
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 560),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: Radius.circular(isUser ? 14 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 14),
                      ),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.text, style: TextStyle(color: textColor)),
                        if (!isUser && m.analysis != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: m.analysis!.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: m.analysis!.color.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: m.analysis!.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${m.analysis!.label.toUpperCase()} • ${(m.analysis!.confidence * 100).round()}% confidence',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: m.analysis!.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: 'Share what’s on your mind…',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillColor: Theme.of(context).colorScheme.surface,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isAnalyzing
                        ? null
                        : () => _sendMessage(_controller.text),
                    icon: _isAnalyzing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(_isAnalyzing ? 'Analyzing...' : 'Send'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
