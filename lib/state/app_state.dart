import 'package:flutter_riverpod/flutter_riverpod.dart';

class JournalEntry {
  JournalEntry({required this.text, required this.sentimentScore, required this.timestamp});
  final String text;
  final int sentimentScore; // -5..+5
  final DateTime timestamp;
}

class JournalNotifier extends Notifier<List<JournalEntry>> {
  @override
  List<JournalEntry> build() => const [];

  void addEntry(String text) {
    final score = _simpleSentiment(text);
    state = [
      JournalEntry(text: text, sentimentScore: score, timestamp: DateTime.now()),
      ...state,
    ];
  }

  int _simpleSentiment(String text) {
    final lower = text.toLowerCase();
    const positive = ['good', 'great', 'happy', 'calm', 'relaxed', 'proud', 'hopeful'];
    const negative = ['bad', 'sad', 'anxious', 'worried', 'tired', 'angry', 'hopeless'];
    var score = 0;
    for (final w in positive) {
      if (lower.contains(w)) score++;
    }
    for (final w in negative) {
      if (lower.contains(w)) score--;
    }
    if (score > 5) return 5;
    if (score < -5) return -5;
    return score;
  }
}

final journalProvider = NotifierProvider<JournalNotifier, List<JournalEntry>>(
  JournalNotifier.new,
);
