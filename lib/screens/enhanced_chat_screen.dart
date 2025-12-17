import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/local_chat_service.dart';
import '../services/emotion_detection_service.dart';
import '../widgets/model_health_monitor.dart';
import '../widgets/ai_model_info.dart';

class EnhancedChatScreen extends StatefulWidget {
  const EnhancedChatScreen({super.key});

  @override
  State<EnhancedChatScreen> createState() => _EnhancedChatScreenState();
}

class _EnhancedChatScreenState extends State<EnhancedChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  LocalChatService? _chatService;
  late final EmotionDetectionService _emotionService;
  bool _isLoading = false;
  bool _showHealthMonitor = false;
  bool _hasText = false;
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _emotionService = EmotionDetectionService();
    _initializeChatService();

    // Listen to text changes to enable/disable send button
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  Future<void> _initializeChatService() async {
    try {
      final chatService = LocalChatService(emotionService: _emotionService);

      if (mounted) {
        setState(() {
          _chatService = chatService;
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = e.toString();
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show loading or error state during initialization
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Chat Assistant')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing Chat Assistant...'),
            ],
          ),
        ),
      );
    }

    if (_initError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Chat Assistant')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to initialize Chat Assistant'),
              const SizedBox(height: 8),
              Text(
                _initError!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _initError = null;
                    _isInitializing = true;
                  });
                  _initializeChatService();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_chatService == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Chat Assistant')),
        body: const Center(child: Text('Chat service not available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Assistant'),
        actions: [
          IconButton(
            icon: Icon(
              _showHealthMonitor
                  ? Icons.monitor_heart
                  : Icons.monitor_heart_outlined,
            ),
            onPressed: () =>
                setState(() => _showHealthMonitor = !_showHealthMonitor),
            tooltip: 'Toggle Health Monitor',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear Conversation'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'health_check',
                child: Row(
                  children: [
                    Icon(Icons.health_and_safety),
                    SizedBox(width: 8),
                    Text('Run Health Check'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('AI Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showHealthMonitor)
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const AIModelInfo(),
                    ModelHealthMonitor(emotionService: _emotionService),
                    _ChatHealthMonitor(chatService: _chatService!),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _chatService!.conversationHistory.isEmpty
                ? _buildWelcomeScreen()
                : _buildChatList(),
          ),
          _buildInputArea(colorScheme),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to AI Chat',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'I\'m here to listen and chat with you. I can detect emotions in your messages and provide supportive responses.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSuggestionChip('How are you feeling today?'),
                _buildSuggestionChip('I need someone to talk to'),
                _buildSuggestionChip('Tell me about yourself'),
                _buildSuggestionChip('I\'m having a difficult day'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () => _sendMessage(text),
      avatar: const Icon(Icons.chat, size: 16),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount:
          _chatService!.conversationHistory.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _chatService!.conversationHistory.length && _isLoading) {
          return _buildTypingIndicator();
        }

        final message = _chatService!.conversationHistory[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary,
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUser
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                  if (message.detectedEmotion != null) ...[
                    const SizedBox(height: 8),
                    _buildEmotionChip(message.detectedEmotion!),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color:
                          (isUser
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface)
                              .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.secondary,
              child: Icon(
                Icons.person,
                size: 16,
                color: colorScheme.onSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionChip(EmotionResult emotion) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: emotion.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: emotion.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.psychology, size: 12, color: emotion.color),
          const SizedBox(width: 4),
          Text(
            '${emotion.label} (${(emotion.confidence * 100).round()}%)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: emotion.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.smart_toy,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI is typing...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: _isLoading ? null : _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _isLoading || !_hasText
                ? null
                : () => _sendMessage(_controller.text),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _chatService!.sendMessage(text);

      if (response != null) {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear':
        _clearConversation();
        break;
      case 'health_check':
        _performHealthCheck();
        break;
      case 'settings':
        // Show emotion detection settings or info
        _showEmotionSettings();
        break;
    }
  }

  void _clearConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation'),
        content: const Text(
          'Are you sure you want to clear the entire conversation? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _chatService!.clearConversation();
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _performHealthCheck() async {
    try {
      await _chatService!.performHealthCheck();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health check completed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Health check failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEmotionSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emotion Detection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This chat assistant uses Hugging Face AI to detect emotions in your messages and provide supportive responses.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Real-time emotion detection'),
            const Text('• Emotion-aware responses'),
            const Text('• Local chat processing'),
            const Text('• Privacy-focused design'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Chat-specific health monitor widget
class _ChatHealthMonitor extends StatefulWidget {
  final LocalChatService chatService;

  const _ChatHealthMonitor({required this.chatService});

  @override
  State<_ChatHealthMonitor> createState() => _ChatHealthMonitorState();
}

class _ChatHealthMonitorState extends State<_ChatHealthMonitor> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final successRate = widget.chatService.successRate;
    final averageResponseTime = widget.chatService.averageResponseTime;
    final isHealthy = widget.chatService.isHealthy;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.chat,
              color: isHealthy ? Colors.green : Colors.red,
            ),
            title: const Text('Chat Model Health'),
            subtitle: Text(
              isHealthy
                  ? 'Chat model is responding'
                  : 'Chat model issues detected',
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMetricRow(
                    'Success Rate',
                    '${(successRate * 100).toStringAsFixed(1)}%',
                  ),
                  if (averageResponseTime != null)
                    _buildMetricRow(
                      'Avg Response Time',
                      '${averageResponseTime.inMilliseconds}ms',
                    ),
                  _buildMetricRow(
                    'Conversation Length',
                    '${widget.chatService.conversationHistory.length} messages',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
