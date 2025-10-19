import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class EmotionDetectionService {
  static const String _baseUrl = 'https://api-inference.huggingface.co/models';
  static const String _modelName =
      'j-hartmann/emotion-english-distilroberta-base';

  final Dio _dio = Dio();

  EmotionDetectionService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<EmotionResult?> detectEmotion(String text) async {
    if (text.trim().isEmpty) return null;

    try {
      // Add API key if available (you can get this from Hugging Face)
      final headers = {'Content-Type': 'application/json'};
      // Uncomment and add your Hugging Face API key:
      // headers['Authorization'] = 'Bearer YOUR_HUGGING_FACE_API_KEY';

      final response = await _dio.post(
        '/$_modelName',
        data: {
          'inputs': text.trim(),
          'options': {'wait_for_model': true},
        },
        options: Options(headers: headers),
      );

      print('Hugging Face API Response: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data is List) {
        final results = response.data as List;
        if (results.isNotEmpty) {
          final emotions = results[0] as List;
          print('Detected emotions: $emotions');
          return _parseEmotionResults(emotions);
        }
      } else if (response.statusCode == 503) {
        print('Model is loading, using fallback');
        return _fallbackEmotionAnalysis(text);
      }
    } catch (e) {
      print('Emotion detection error: $e');
      print('Error type: ${e.runtimeType}');
      // Fallback to local analysis if API fails
      return _fallbackEmotionAnalysis(text);
    }

    print('API returned null, using fallback');
    return _fallbackEmotionAnalysis(text);
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
    switch (huggingFaceLabel.toLowerCase()) {
      case 'joy':
        return 'joy';
      case 'sadness':
        return 'sadness';
      case 'anger':
        return 'anger';
      case 'fear':
        return 'fear';
      case 'surprise':
        return 'surprise';
      case 'disgust':
        return 'disgust';
      case 'neutral':
        return 'neutral';
      default:
        return 'neutral';
    }
  }

  Color _getEmotionColor(String label) {
    switch (label.toLowerCase()) {
      case 'joy':
        return const Color(0xFF4CAF50); // Green
      case 'sadness':
        return const Color(0xFF2196F3); // Blue
      case 'anger':
        return const Color(0xFFF44336); // Red
      case 'fear':
        return const Color(0xFF9C27B0); // Purple
      case 'surprise':
        return const Color(0xFFFF9800); // Orange
      case 'disgust':
        return const Color(0xFF795548); // Brown
      case 'neutral':
        return const Color(0xFF607D8B); // Blue Grey
      default:
        return const Color(0xFF607D8B);
    }
  }

  // Fallback local emotion analysis if API fails
  EmotionResult _fallbackEmotionAnalysis(String text) {
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
