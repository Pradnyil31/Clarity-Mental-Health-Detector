import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../models/safety_plan.dart';
import '../services/firebase_service.dart';

class UserRepository {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;
  static const String _collection = 'users';

  // Create or update user profile
  static Future<void> createOrUpdateUser(UserProfile user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.id)
          .set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  // Get user profile by ID
  static Future<UserProfile?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();

      if (doc.exists && doc.data() != null) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Get user profile by email
  static Future<UserProfile?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserProfile.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Update user preferences
  static Future<void> updateUserPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'preferences': preferences,
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  // Update last login time
  static Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }

  // Delete user profile
  static Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Create user profile from Firebase Auth user
  static Future<UserProfile> createUserFromAuth(User user) async {
    final userProfile = UserProfile(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'User',
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    await createOrUpdateUser(userProfile);
    return userProfile;
  }
  // Log Activity
  static Future<void> logActivity(String userId, Map<String, dynamic> activityData) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('activities')
          .add({
        ...activityData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to log activity: $e');
    }
  }


  // Get Activity Logs Stream
  static Stream<QuerySnapshot> getActivityLogs(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots();
  }

  // Get Safety Plan
  static Future<SafetyPlan?> getSafetyPlan(String userId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('safety_plan')
          .doc('current')
          .get();

      if (doc.exists && doc.data() != null) {
        return SafetyPlan.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get safety plan: $e');
    }
  }

  // Save Safety Plan
  static Future<void> saveSafetyPlan(String userId, SafetyPlan plan) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('safety_plan')
          .doc('current')
          .set(plan.toJson());
    } catch (e) {
      throw Exception('Failed to save safety plan: $e');
    }
  }
}
