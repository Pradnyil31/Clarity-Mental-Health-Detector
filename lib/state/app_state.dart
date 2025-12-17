import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/journal_repository.dart';
import '../services/data_persistence_service.dart';
import '../state/user_state.dart';

class JournalEntry {
  JournalEntry({
    required this.id,
    required this.text,
    required this.sentimentScore,
    required this.timestamp,
  });

  final String id;
  final String text;
  final int sentimentScore; // -5..+5
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sentimentScore': sentimentScore,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      text: json['text'] as String,
      sentimentScore: json['sentimentScore'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    );
  }

  JournalEntry copyWith({
    String? id,
    String? text,
    int? sentimentScore,
    DateTime? timestamp,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      text: text ?? this.text,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class JournalNotifier extends Notifier<List<JournalEntry>> {
  StreamSubscription<List<JournalEntry>>? _streamSubscription;

  @override
  List<JournalEntry> build() {
    // Watch the current user ID and load data when it changes
    final userId = ref.watch(currentUserIdProvider);

    // Clean up subscription when provider is disposed
    ref.onDispose(() {
      _streamSubscription?.cancel();
    });

    // Load data when user ID is available
    if (userId != null) {
      // Use a future to avoid blocking the build method
      Future.microtask(() => _loadJournalEntries(userId));
    } else {
      // Cancel subscription and clear state when no user
      _streamSubscription?.cancel();
    }

    return [];
  }

  Future<void> _loadJournalEntries(String userId) async {
    try {
      // Cancel existing subscription
      _streamSubscription?.cancel();

      // Get journal entries from Firestore with real-time updates
      _streamSubscription = JournalRepository.getJournalEntriesStream(userId)
          .listen(
            (entries) {
              state = entries;
            },
            onError: (error) {
              // Handle stream error - could log this properly in production
            },
          );
    } catch (e) {
      // Handle error - could show snackbar or log error
      // For now, just keep empty state
      state = [];
    }
  }

  Future<void> addEntry(String text) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final score = _simpleSentiment(text);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final entry = JournalEntry(
      id: id,
      text: text,
      sentimentScore: score,
      timestamp: DateTime.now(),
    );

    try {
      // Update local state immediately for better UX
      state = [entry, ...state];

      // Save to Firestore with persistence service
      await DataPersistenceService.saveJournalEntry(userId, entry);
    } catch (e) {
      // If save failed, remove from local state
      state = state.where((e) => e.id != entry.id).toList();
      rethrow;
    }
  }

  int _simpleSentiment(String text) {
    final lower = text.toLowerCase();
    const positive = [
      'good',
      'great',
      'happy',
      'calm',
      'relaxed',
      'proud',
      'hopeful',
    ];
    const negative = [
      'bad',
      'sad',
      'anxious',
      'worried',
      'tired',
      'angry',
      'hopeless',
    ];
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
