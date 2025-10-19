import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodEntry {
  MoodEntry({required this.date, required this.score});
  final DateTime date; // date-only component considered
  final int score; // 0..27 PHQ or 0..21 GAD normalized to 0..27

  Map<String, dynamic> toJson() => {
    'd': DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
    's': score,
  };

  static MoodEntry fromJson(Map<String, dynamic> json) => MoodEntry(
    date: DateTime.fromMillisecondsSinceEpoch(json['d'] as int),
    score: (json['s'] as num).toInt(),
  );
}

class MoodTracker extends Notifier<List<MoodEntry>> {
  static const _prefsKey = 'mood_entries_v1';

  @override
  List<MoodEntry> build() {
    _loadAsync();
    return const [];
  }

  Future<void> _loadAsync() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    final list = (json.decode(raw) as List)
        .map((e) => MoodEntry.fromJson((e as Map).cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    state = list;
  }

  Future<void> _saveAsync(List<MoodEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  void recordToday(int score) {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    final updated = [...state.where((e) => !_isSameDay(e.date, dateOnly))];
    updated.add(MoodEntry(date: dateOnly, score: score));
    updated.sort((a, b) => a.date.compareTo(b.date));
    state = updated;
    _saveAsync(updated);
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  double get average7Days {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = state.where((e) => e.date.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0;
    return recent.map((e) => e.score).reduce((a, b) => a + b) / recent.length;
  }
}

final moodTrackerProvider = NotifierProvider<MoodTracker, List<MoodEntry>>(MoodTracker.new);
