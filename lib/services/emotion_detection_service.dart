import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'emotion_config.dart';
import '../utils/app_logger.dart';

enum ModelStatus { responding, notResponding, loading, error, timeout }

class ModelHealthCheck {
  final ModelStatus status;
  final DateTime timestamp;
  final Duration? responseTime;
  final String? errorMessage;
  final bool hasValidResponse;

  ModelHealthCheck({
    required this.status,
    required this.timestamp,
    this.responseTime,
    this.errorMessage,
    required this.hasValidResponse,
  });
}

class EmotionDetectionService {
  static const String _baseUrl = 'https://api-inference.huggingface.co/models';

  // Available emotion detection models - verified working models
  static const Map<String, String> _availableModels = {
    'distilroberta': 'j-hartmann/emotion-english-distilroberta-base',
    'roberta': 'cardiffnlp/twitter-roberta-base-emotion-multilabel-latest',
    'bert': 'nateraw/bert-base-uncased-emotion',
    'goemotions':
        'SamLowe/roberta-base-go_emotions', // Working GoEmotions model - 28 emotions!
  };

  final String _currentModel;
  final Dio _dio = Dio();

  // Model monitoring properties
  ModelHealthCheck? _lastHealthCheck;
  int _consecutiveFailures = 0;
  int _totalRequests = 0;
  int _successfulRequests = 0;
  final List<Duration> _responseTimes = [];
  static const int _maxResponseTimeHistory = 10;
  static const int _maxConsecutiveFailures = 3;

  EmotionDetectionService({String model = 'goemotions'})
    : _currentModel =
          _availableModels[model] ?? _availableModels['goemotions']! {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
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

  Future<EmotionResult?> detectEmotion(String text) async {
    if (text.trim().isEmpty) return null;

    final stopwatch = Stopwatch()..start();
    _totalRequests++;

    try {
      // Check if model is in circuit breaker state
      if (!isHealthy) {
        AppLogger.w('Model circuit breaker activated - using fallback');
        _updateHealthCheck(
          ModelStatus.notResponding,
          stopwatch.elapsed,
          'Circuit breaker activated due to consecutive failures',
          false,
        );
        return _fallbackEmotionAnalysis(text);
      }

      final headers = {'Content-Type': 'application/json'};

      // Add API key if configured
      AppLogger.d('API key configured: ${EmotionConfig.hasValidApiKey}');
      if (EmotionConfig.hasValidApiKey) {
        headers['Authorization'] = 'Bearer ${EmotionConfig.huggingFaceApiKey}';
        AppLogger.d('Using API key for request');
      } else {
        AppLogger.d('No API key configured, using free tier');
      }

      final response = await _dio.post(
        '/$_currentModel',
        data: {
          'inputs': text.trim(),
          'options': {'wait_for_model': true},
        },
        options: Options(headers: headers),
      );

      stopwatch.stop();
      _recordResponseTime(stopwatch.elapsed);

      // Debug logging - temporarily enabled for testing
      AppLogger.d('Hugging Face API Response: ${response.statusCode}');
      AppLogger.d('Response data: ${response.data}');
      AppLogger.d('Response time: ${stopwatch.elapsed.inMilliseconds}ms');

      // Validate response
      if (!_isValidResponse(response)) {
        _updateHealthCheck(
          ModelStatus.error,
          stopwatch.elapsed,
          'Invalid response format',
          false,
        );
        return _fallbackEmotionAnalysis(text);
      }

      if (response.statusCode == 200 && response.data is List) {
        final results = response.data as List;
        if (results.isNotEmpty && results[0] is List) {
          final emotions = results[0] as List;

          // Validate emotion data quality
          if (!_isValidEmotionData(emotions)) {
            _updateHealthCheck(
              ModelStatus.error,
              stopwatch.elapsed,
              'Invalid emotion data format',
              false,
            );
            return _fallbackEmotionAnalysis(text);
          }

          AppLogger.d('Detected emotions: $emotions');
          _successfulRequests++;
          _consecutiveFailures = 0;
          _updateHealthCheck(
            ModelStatus.responding,
            stopwatch.elapsed,
            null,
            true,
          );
          return _parseEmotionResults(emotions);
        }
      } else if (response.statusCode == 503) {
        _updateHealthCheck(
          ModelStatus.loading,
          stopwatch.elapsed,
          'Model is loading',
          false,
        );
        return _fallbackEmotionAnalysis(text);
      }

      // Unexpected response format
      _updateHealthCheck(
        ModelStatus.error,
        stopwatch.elapsed,
        'Unexpected response format',
        false,
      );
      return _fallbackEmotionAnalysis(text);
    } on DioException catch (e) {
      stopwatch.stop();
      _consecutiveFailures++;

      String errorMessage = 'Unknown error';
      ModelStatus status = ModelStatus.error;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        status = ModelStatus.timeout;
        errorMessage = 'Request timeout';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'API key invalid or insufficient permissions';
      } else if (e.response?.statusCode == 503) {
        status = ModelStatus.loading;
        errorMessage = 'Model is loading';
      } else if (e.response?.statusCode != null) {
        errorMessage =
            'HTTP ${e.response!.statusCode}: ${e.response!.statusMessage}';
      } else {
        errorMessage = e.message ?? 'Network error';
      }

      AppLogger.e('Emotion detection error: $errorMessage', error: e);
      AppLogger.d('Error type: ${e.runtimeType}');
      AppLogger.d('Response time: ${stopwatch.elapsed.inMilliseconds}ms');

      _updateHealthCheck(status, stopwatch.elapsed, errorMessage, false);

      // Check for specific permission errors
      if (e.toString().contains('insufficient permissions')) {
        AppLogger.e(
          'API KEY PERMISSION ERROR: Your Hugging Face token needs proper permissions!',
        );
        AppLogger.e(
          'Go to https://huggingface.co/settings/tokens and create a new token with "Read" permissions',
        );
      } else if (e.response?.statusCode == 401) {
        AppLogger.e('API KEY INVALID: Check your Hugging Face API key');
      }

      return _fallbackEmotionAnalysis(text);
    } catch (e) {
      stopwatch.stop();
      _consecutiveFailures++;

      AppLogger.e('Unexpected emotion detection error', error: e);
      AppLogger.d('Error type: ${e.runtimeType}');
      AppLogger.d('Response time: ${stopwatch.elapsed.inMilliseconds}ms');

      _updateHealthCheck(
        ModelStatus.error,
        stopwatch.elapsed,
        'Unexpected error: ${e.toString()}',
        false,
      );

      return _fallbackEmotionAnalysis(text);
    }
  }

  bool _isValidResponse(Response response) {
    return response.statusCode == 200 &&
        response.data != null &&
        response.data is List &&
        (response.data as List).isNotEmpty;
  }

  bool _isValidEmotionData(List emotions) {
    if (emotions.isEmpty) return false;

    for (final emotion in emotions) {
      if (emotion is! Map) return false;
      if (!emotion.containsKey('label') || !emotion.containsKey('score'))
        return false;
      if (emotion['label'] is! String || emotion['score'] is! double)
        return false;
      if ((emotion['score'] as double) < 0 || (emotion['score'] as double) > 1)
        return false;
    }

    return true;
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
    const testText = "I am feeling good today";
    final stopwatch = Stopwatch()..start();

    try {
      final result = await detectEmotion(testText);
      stopwatch.stop();

      final isHealthy = result != null;
      _updateHealthCheck(
        isHealthy ? ModelStatus.responding : ModelStatus.error,
        stopwatch.elapsed,
        isHealthy ? null : 'Health check failed - no result returned',
        isHealthy,
      );

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

  EmotionResult _parseEmotionResults(List<dynamic> emotions) {
    // Sort emotions by score (highest first)
    emotions.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );

    final topEmotion = emotions.first;
    final label = topEmotion['label'] as String;
    final score = topEmotion['score'] as double;

    return EmotionResult(
      label: _mapEmotionLabel(label),
      score: score,
      confidence: score,
      color: _getEmotionColor(label),
      allEmotions: emotions
          .map(
            (e) => {'label': _mapEmotionLabel(e['label']), 'score': e['score']},
          )
          .toList(),
    );
  }

  String _mapEmotionLabel(String huggingFaceLabel) {
    // GoEmotions model returns 28 different emotions
    // We'll keep the original labels for more detailed analysis
    final label = huggingFaceLabel.toLowerCase().replaceAll('_', ' ');

    // Map some emotions to more user-friendly terms
    switch (label) {
      case 'admiration':
        return 'admiration';
      case 'amusement':
        return 'amusement';
      case 'anger':
        return 'anger';
      case 'annoyance':
        return 'annoyance';
      case 'approval':
        return 'approval';
      case 'caring':
        return 'caring';
      case 'confusion':
        return 'confusion';
      case 'curiosity':
        return 'curiosity';
      case 'desire':
        return 'desire';
      case 'disappointment':
        return 'disappointment';
      case 'disapproval':
        return 'disapproval';
      case 'disgust':
        return 'disgust';
      case 'embarrassment':
        return 'embarrassment';
      case 'excitement':
        return 'excitement';
      case 'fear':
        return 'fear';
      case 'gratitude':
        return 'gratitude';
      case 'grief':
        return 'grief';
      case 'joy':
        return 'joy';
      case 'love':
        return 'love';
      case 'nervousness':
        return 'nervousness';
      case 'optimism':
        return 'optimism';
      case 'pride':
        return 'pride';
      case 'realization':
        return 'realization';
      case 'relief':
        return 'relief';
      case 'remorse':
        return 'remorse';
      case 'sadness':
        return 'sadness';
      case 'surprise':
        return 'surprise';
      case 'neutral':
        return 'neutral';
      default:
        return label; // Return as-is for any new emotions
    }
  }

  Color _getEmotionColor(String label) {
    switch (label.toLowerCase()) {
      // Positive emotions - Green tones
      case 'joy':
      case 'amusement':
      case 'excitement':
        return const Color(0xFF4CAF50); // Green
      case 'love':
      case 'caring':
      case 'gratitude':
        return const Color(0xFFE91E63); // Pink
      case 'admiration':
      case 'approval':
      case 'pride':
        return const Color(0xFF8BC34A); // Light Green
      case 'optimism':
      case 'relief':
        return const Color(0xFF00BCD4); // Cyan

      // Negative emotions - Red/Orange tones
      case 'anger':
      case 'annoyance':
        return const Color(0xFFF44336); // Red
      case 'sadness':
      case 'grief':
      case 'disappointment':
        return const Color(0xFF2196F3); // Blue
      case 'fear':
      case 'nervousness':
        return const Color(0xFF9C27B0); // Purple
      case 'disgust':
        return const Color(0xFF795548); // Brown
      case 'embarrassment':
      case 'remorse':
        return const Color(0xFFFF5722); // Deep Orange

      // Neutral/Complex emotions - Grey/Yellow tones
      case 'surprise':
      case 'realization':
        return const Color(0xFFFF9800); // Orange
      case 'confusion':
      case 'curiosity':
        return const Color(0xFFFFEB3B); // Yellow
      case 'desire':
        return const Color(0xFF673AB7); // Deep Purple
      case 'disapproval':
        return const Color(0xFF607D8B); // Blue Grey
      case 'neutral':
        return const Color(0xFF9E9E9E); // Grey

      default:
        return const Color(0xFF607D8B); // Default Blue Grey
    }
  }

  // Fallback local emotion analysis if API fails
  EmotionResult _fallbackEmotionAnalysis(String text) {
    AppLogger.i('Using fallback local emotion analysis (API not available)');
    final lc = text.toLowerCase();
    int joy = 0, sadness = 0, anger = 0, fear = 0;

    // Joy keywords
    const joyWords = [
      'happy',
      'joy',
      'excited',
      'great',
      'wonderful',
      'amazing',
      'love',
      '😊',
      '😄',
      '🎉',
    ];
    // Sadness keywords
    const sadnessWords = [
      'sad',
      'depressed',
      'down',
      'cry',
      'hurt',
      'pain',
      '😢',
      '😭',
      '💔',
    ];
    // Anger keywords
    const angerWords = [
      'angry',
      'mad',
      'furious',
      'rage',
      'hate',
      'annoyed',
      '😠',
      '😡',
      '💢',
    ];
    // Fear keywords
    const fearWords = [
      'scared',
      'afraid',
      'anxious',
      'worried',
      'panic',
      'fear',
      '😰',
      '😨',
      '😱',
    ];

    for (final word in joyWords) {
      if (lc.contains(word)) joy++;
    }
    for (final word in sadnessWords) {
      if (lc.contains(word)) sadness++;
    }
    for (final word in angerWords) {
      if (lc.contains(word)) anger++;
    }
    for (final word in fearWords) {
      if (lc.contains(word)) fear++;
    }

    final emotions = {
      'joy': joy,
      'sadness': sadness,
      'anger': anger,
      'fear': fear,
    };

    final topEmotion = emotions.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    final total = emotions.values.fold(0, (a, b) => a + b);
    final confidence = total > 0 ? topEmotion.value / total : 0.5;

    return EmotionResult(
      label: topEmotion.key,
      score: confidence,
      confidence: confidence,
      color: _getEmotionColor(topEmotion.key),
      allEmotions: emotions.entries
          .map(
            (e) => {'label': e.key, 'score': e.value / (total > 0 ? total : 1)},
          )
          .toList(),
    );
  }
}

class EmotionResult {
  final String label;
  final double score;
  final double confidence;
  final Color color;
  final List<Map<String, dynamic>> allEmotions;

  EmotionResult({
    required this.label,
    required this.score,
    required this.confidence,
    required this.color,
    required this.allEmotions,
  });
}
