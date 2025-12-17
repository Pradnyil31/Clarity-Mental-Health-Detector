import 'package:cloud_firestore/cloud_firestore.dart';
import '../state/app_state.dart';
import '../services/firebase_service.dart';

class JournalRepository {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;
  static const String _collection = 'journal';

  // Add journal entry
  static Future<void> addJournalEntry(String userId, JournalEntry entry) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(entry.id)
          .set(entry.toJson());
    } catch (e) {
      throw Exception('Failed to save journal entry: $e');
    }
  }

  // Get all journal entries for a user
  static Future<List<JournalEntry>> getJournalEntries(String userId) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs
          .map((doc) => JournalEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get journal entries: $e');
    }
  }

  // Get journal entries stream for real-time updates
  static Stream<List<JournalEntry>> getJournalEntriesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JournalEntry.fromJson(doc.data()))
              .toList(),
        );
  }

  // Update journal entry
  static Future<void> updateJournalEntry(
    String userId,
    JournalEntry entry,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(entry.id)
          .update(entry.toJson());
    } catch (e) {
      throw Exception('Failed to update journal entry: $e');
    }
  }

  // Delete journal entry
  static Future<void> deleteJournalEntry(String userId, String entryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(entryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete journal entry: $e');
    }
  }

  // Get journal entries by date range
  static Future<List<JournalEntry>> getJournalEntriesByDateRange(
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
            'timestamp',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'timestamp',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          )
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs
          .map((doc) => JournalEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get journal entries by date range: $e');
    }
  }
}
