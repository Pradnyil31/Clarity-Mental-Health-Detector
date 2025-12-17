import 'package:cloud_firestore/cloud_firestore.dart';
import '../state/mood_state.dart';
import '../services/firebase_service.dart';

class MoodRepository {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;
  static const String _collection = 'moods';

  // Add mood entry
  static Future<void> addMoodEntry(String userId, MoodEntry entry) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(entry.id)
          .set(entry.toJson());
    } catch (e) {
      throw Exception('Failed to save mood entry: $e');
    }
  }

  // Get all mood entries for a user
  static Future<List<MoodEntry>> getMoodEntries(String userId) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .orderBy('date', descending: true)
          .get();

      return query.docs.map((doc) => MoodEntry.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get mood entries: $e');
    }
  }

  // Get mood entries stream for real-time updates
  static Stream<List<MoodEntry>> getMoodEntriesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MoodEntry.fromJson(doc.data()))
              .toList(),
        );
  }

  // Update mood entry
  static Future<void> updateMoodEntry(String userId, MoodEntry entry) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(entry.id)
          .update(entry.toJson());
    } catch (e) {
      throw Exception('Failed to update mood entry: $e');
    }
  }

  // Delete mood entry
  static Future<void> deleteMoodEntry(String userId, String entryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(entryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete mood entry: $e');
    }
  }

  // Get mood entries by date range
  static Future<List<MoodEntry>> getMoodEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .where(
            'date',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where('date', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .orderBy('date', descending: true)
          .get();

      return query.docs.map((doc) => MoodEntry.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get mood entries by date range: $e');
    }
  }

  // Get mood entry for specific date
  static Future<MoodEntry?> getMoodEntryForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .where('date', isEqualTo: dateOnly.millisecondsSinceEpoch)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return MoodEntry.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get mood entry for date: $e');
    }
  }
}
