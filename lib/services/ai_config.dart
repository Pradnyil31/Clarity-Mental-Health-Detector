// Configuration for AI models used in the app
class AIConfig {
  // Emotion Detection Model Configuration
  static const String emotionModel =
      'goemotions'; // Best for 28 detailed emotions

  // Chat Model Configuration - using local emotion-aware chat
  static const String chatModel =
      'local-emotion-aware'; // Local chat with Hugging Face emotion detection

  // Model combinations and their characteristics:
  static const Map<String, Map<String, String>> modelCombinations = {
    'balanced': {
      'emotion': 'goemotions',
      'chat': 'local-emotion-aware',
      'description':
          'Perfect emotion detection (28 emotions) with intelligent local emotion-aware responses',
    },
    'fast': {
      'emotion': 'distilroberta',
      'chat': 'distilgpt2',
      'description': 'Faster responses, good quality',
    },
    'creative': {
      'emotion': 'goemotions',
      'chat': 'gpt2-medium',
      'description': 'Most creative and varied responses',
    },
    'empathetic': {
      'emotion': 'goemotions',
      'chat': 'dialoGPT-medium',
      'description': 'Best for emotional support conversations',
    },
  };

  // Get current configuration
  static Map<String, String> get currentConfig => {
    'emotion': emotionModel,
    'chat': chatModel,
  };

  // Model performance characteristics
  static const Map<String, Map<String, dynamic>> modelInfo = {
    // Emotion Models
    'goemotions': {
      'type': 'emotion',
      'emotions': 28,
      'speed': 'medium',
      'accuracy': 'high',
      'description': 'Detects 28 detailed emotions with high accuracy',
    },
    'distilroberta': {
      'type': 'emotion',
      'emotions': 6,
      'speed': 'fast',
      'accuracy': 'good',
      'description': 'Fast emotion detection for basic emotions',
    },

    // Chat Models
    'local-emotion-aware': {
      'type': 'chat',
      'name': 'Local Emotion-Aware Chat',
      'description': 'Local chat assistant with Hugging Face emotion detection',
      'provider': 'Local',
      'capabilities': ['conversation', 'emotion-awareness', 'privacy-focused'],
      'responseTime': 'Instant',
      'quality': 'High',
    },
    'intelligent-fallback': {
      'type': 'chat',
      'quality': 'excellent',
      'speed': 'instant',
      'creativity': 'high',
      'description': 'Intelligent emotion-aware responses that always work',
    },
    'blenderbot': {
      'type': 'chat',
      'quality': 'good',
      'speed': 'fast',
      'creativity': 'medium',
      'description': 'Good conversation quality with faster responses',
    },
    'dialoGPT-medium': {
      'type': 'chat',
      'quality': 'good',
      'speed': 'medium',
      'creativity': 'medium',
      'description': 'Structured conversations, good for support',
    },
    'dialoGPT-large': {
      'type': 'chat',
      'quality': 'good',
      'speed': 'slow',
      'creativity': 'medium',
      'description': 'High-quality structured conversations',
    },
    'distilgpt2': {
      'type': 'chat',
      'quality': 'good',
      'speed': 'fast',
      'creativity': 'high',
      'description': 'Fast and creative text generation',
    },
    'gpt2-medium': {
      'type': 'chat',
      'quality': 'variable',
      'speed': 'medium',
      'creativity': 'very high',
      'description': 'Most creative responses, can be unpredictable',
    },
  };
}
