import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assessment.dart';
import '../services/firebase_service.dart';

class AssessmentRepository {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;
  static const String _collection = 'assessments';

  // Add assessment result
  static Future<void> addAssessmentResult(
    String userId,
    AssessmentResult result,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(result.id)
          .set(result.toJson());
    } catch (e) {
      throw Exception('Failed to save assessment result: $e');
    }
  }

  // Get all assessment results for a user
  static Future<List<AssessmentResult>> getAssessmentResults(
    String userId,
  ) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .orderBy('completedAt', descending: true)
          .get();

      return query.docs
          .map((doc) => AssessmentResult.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get assessment results: $e');
    }
  }

  // Get assessment results stream for real-time updates
  static Stream<List<AssessmentResult>> getAssessmentResultsStream(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AssessmentResult.fromJson(doc.data()))
              .toList(),
        );
  }

  // Get assessment results by type
  static Future<List<AssessmentResult>> getAssessmentResultsByType(
    String userId,
    AssessmentKind kind,
  ) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .where('kind', isEqualTo: kind.name)
          .orderBy('completedAt', descending: true)
          .get();

      return query.docs
          .map((doc) => AssessmentResult.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get assessment results by type: $e');
    }
  }

  // Get latest assessment result by type
  static Future<AssessmentResult?> getLatestAssessmentByType(
    String userId,
    AssessmentKind kind,
  ) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .where('kind', isEqualTo: kind.name)
          .orderBy('completedAt', descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return AssessmentResult.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get latest assessment by type: $e');
    }
  }

  // Delete assessment result
  static Future<void> deleteAssessmentResult(
    String userId,
    String resultId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collection)
          .doc(resultId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete assessment result: $e');
    }
  }

  // Get assessment results by date range
  static Future<List<AssessmentResult>> getAssessmentResultsByDateRange(
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
            'completedAt',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'completedAt',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          )
          .orderBy('completedAt', descending: true)
          .get();

      return query.docs
          .map((doc) => AssessmentResult.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get assessment results by date range: $e');
    }
  }
}
