import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/mood_repository.dart';
import '../services/data_persistence_service.dart';
import '../state/user_state.dart';

class MoodEntry {
  MoodEntry({
    required this.id,
    required this.date,
    required this.score,
    this.factors = const [],
  });

  final String id;
  final DateTime date; // Full timestamp including time
  final int score; // 0..100 scale where higher = better mood
  final List<String> factors;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.millisecondsSinceEpoch, // Store full timestamp
    'score': score,
    'factors': factors,
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    id: json['id'] as String,
    date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
    score: (json['score'] as num).toInt(),
    factors:
        json['factors'] != null ? List<String>.from(json['factors']) : const [],
  );

  MoodEntry copyWith({
    String? id,
    DateTime? date,
    int? score,
    List<String>? factors,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      score: score ?? this.score,
      factors: factors ?? this.factors,
    );
  }
}

class MoodTracker extends Notifier<List<MoodEntry>> {
  StreamSubscription<List<MoodEntry>>? _streamSubscription;

  @override
  List<MoodEntry> build() {
    // Watch the current user ID and load data when it changes
    final userId = ref.watch(currentUserIdProvider);

    // Clean up subscription when provider is disposed
    ref.onDispose(() {
      _streamSubscription?.cancel();
    });

    // Load data when user ID is available
    if (userId != null) {
      // Use a future to avoid blocking the build method
      Future.microtask(() => _loadMoodEntries(userId));
    } else {
      // Cancel subscription and clear state when no user
      _streamSubscription?.cancel();
    }

    return [];
  }

  Future<void> _loadMoodEntries(String userId) async {
    try {
      // Cancel existing subscription
      _streamSubscription?.cancel();

      // Get mood entries from Firestore with real-time updates
      _streamSubscription = MoodRepository.getMoodEntriesStream(userId).listen(
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

  Future<void> recordToday(int score, {List<String> factors = const []}) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();

    // Create mood entry with full timestamp
    final moodEntry = MoodEntry(
      id: id,
      date: now,
      score: score,
      factors: factors,
    );

    try {
      // Update local state immediately for better UX
      final updated = [...state];
      updated.add(moodEntry);
      updated.sort((a, b) => a.date.compareTo(b.date));
      state = updated;

      // Save to Firestore with persistence service
      await DataPersistenceService.saveMoodEntry(userId, moodEntry);
    } catch (e) {
      // If save failed, revert local state
      state = state.where((e) => e.id != moodEntry.id).toList();
      rethrow;
    }
  }

  Future<void> deleteEntry(String entryId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final previousState = [...state];

    try {
      // Optimistically update local state
      state = state.where((e) => e.id != entryId).toList();

      // Delete from persistence
      await DataPersistenceService.deleteMoodEntry(userId, entryId);
    } catch (e) {
      // Revert on failure
      state = previousState;
      rethrow;
    }
  }

  double get average7Days {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = state.where((e) => e.date.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0;

    // Group by day and calculate daily averages
    final Map<String, List<MoodEntry>> groupedByDay = {};
    for (final entry in recent) {
      final dayKey = '${entry.date.year}-${entry.date.month}-${entry.date.day}';
      groupedByDay.putIfAbsent(dayKey, () => []).add(entry);
    }

    // Calculate average of daily averages
    final dailyAverages = groupedByDay.values
        .map(
          (dayEntries) =>
              dayEntries.map((e) => e.score).reduce((a, b) => a + b) /
              dayEntries.length,
        )
        .toList();

    return dailyAverages.reduce((a, b) => a + b) / dailyAverages.length;
  }
}

final moodTrackerProvider = NotifierProvider<MoodTracker, List<MoodEntry>>(
  MoodTracker.new,
);
