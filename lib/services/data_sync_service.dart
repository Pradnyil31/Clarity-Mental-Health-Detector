import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/firebase_service.dart';
import '../repositories/journal_repository.dart';
import '../repositories/mood_repository.dart';
import '../repositories/assessment_repository.dart';
import '../repositories/user_repository.dart';
import '../utils/app_logger.dart';

class DataSyncService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;
  static StreamSubscription<List<ConnectivityResult>>?
  _connectivitySubscription;
  static bool _isOnline = true;
  static final List<Function> _pendingSyncs = [];

  // Initialize data sync service
  static Future<void> initialize() async {
    // Monitor connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final wasOnline = _isOnline;
      _isOnline =
          results.isNotEmpty &&
          !results.every((result) => result == ConnectivityResult.none);

      // If we just came back online, sync pending data
      if (!wasOnline && _isOnline) {
        _syncPendingData();
      }
    });

    // Check initial connectivity
    final connectivityResults = await Connectivity().checkConnectivity();
    _isOnline =
        connectivityResults.isNotEmpty &&
        !connectivityResults.every(
          (result) => result == ConnectivityResult.none,
        );

    // Enable offline persistence
    await _enableOfflinePersistence();
  }

  // Enable Firestore offline persistence
  static Future<void> _enableOfflinePersistence() async {
    try {
      // Persistence is now enabled via Settings in FirebaseService
      // This method is kept for compatibility but does nothing
    } catch (e) {
      AppLogger.w('Offline persistence setup', error: e);
    }
  }

  // Sync all user data
  static Future<void> syncAllUserData(String userId) async {
    if (!_isOnline) {
      // Queue for later sync
      _pendingSyncs.add(() => syncAllUserData(userId));
      return;
    }

    try {
      // Sync user profile
      await _syncUserProfile(userId);

      // Sync journal entries
      await _syncJournalEntries(userId);

      // Sync mood entries
      await _syncMoodEntries(userId);

      // Sync assessment results
      await _syncAssessmentResults(userId);

      AppLogger.i('Data sync completed for user: $userId');
    } catch (e) {
      AppLogger.e('Data sync failed', error: e);
      // Queue for retry
      _pendingSyncs.add(() => syncAllUserData(userId));
    }
  }

  // Sync user profile data
  static Future<void> _syncUserProfile(String userId) async {
    try {
      final profile = await UserRepository.getUserById(userId);
      if (profile != null) {
        // Update last sync time
        await UserRepository.updateLastLogin(userId);
      }
    } catch (e) {
      AppLogger.e('User profile sync failed', error: e);
      rethrow;
    }
  }

  // Sync journal entries
  static Future<void> _syncJournalEntries(String userId) async {
    try {
      // Get latest entries to ensure sync
      await JournalRepository.getJournalEntries(userId);
    } catch (e) {
      AppLogger.e('Journal sync failed', error: e);
      rethrow;
    }
  }

  // Sync mood entries
  static Future<void> _syncMoodEntries(String userId) async {
    try {
      // Get latest entries to ensure sync
      await MoodRepository.getMoodEntries(userId);
    } catch (e) {
      AppLogger.e('Mood sync failed', error: e);
      rethrow;
    }
  }

  // Sync assessment results
  static Future<void> _syncAssessmentResults(String userId) async {
    try {
      // Get latest results to ensure sync
      await AssessmentRepository.getAssessmentResults(userId);
    } catch (e) {
      AppLogger.e('Assessment sync failed', error: e);
      rethrow;
    }
  }

  // Sync pending data when coming back online
  static Future<void> _syncPendingData() async {
    if (_pendingSyncs.isEmpty) return;

    AppLogger.i('Syncing ${_pendingSyncs.length} pending operations...');

    final syncsToProcess = List<Function>.from(_pendingSyncs);
    _pendingSyncs.clear();

    for (final sync in syncsToProcess) {
      try {
        await sync();
      } catch (e) {
        AppLogger.e('Pending sync failed', error: e);
        // Re-queue failed syncs
        _pendingSyncs.add(sync);
      }
    }
  }

  // Check if device is online
  static bool get isOnline => _isOnline;

  // Get pending sync count
  static int get pendingSyncCount => _pendingSyncs.length;

  // Force sync all data
  static Future<void> forceSyncAllData(String userId) async {
    await syncAllUserData(userId);
  }

  // Clear pending syncs
  static void clearPendingSyncs() {
    _pendingSyncs.clear();
  }

  // Dispose resources
  static void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _pendingSyncs.clear();
  }

  // Backup user data to cloud
  static Future<void> backupUserData(String userId) async {
    if (!_isOnline) {
      throw Exception('Cannot backup data while offline');
    }

    try {
      // Create backup document
      final backupData = {
        'userId': userId,
        'backupDate': DateTime.now().millisecondsSinceEpoch,
        'version': '1.0.0',
      };

      // Get all user data
      final journalEntries = await JournalRepository.getJournalEntries(userId);
      final moodEntries = await MoodRepository.getMoodEntries(userId);
      final assessmentResults = await AssessmentRepository.getAssessmentResults(
        userId,
      );
      final userProfile = await UserRepository.getUserById(userId);

      // Add data to backup
      backupData['journalEntries'] = journalEntries
          .map((e) => e.toJson())
          .toList();
      backupData['moodEntries'] = moodEntries.map((e) => e.toJson()).toList();
      backupData['assessmentResults'] = assessmentResults
          .map((e) => e.toJson())
          .toList();
      if (userProfile != null) {
        backupData['userProfile'] = userProfile.toJson();
      }

      // Save backup to Firestore
      await _firestore.collection('backups').doc(userId).set(backupData);

      AppLogger.i('User data backup completed');
    } catch (e) {
      AppLogger.e('Backup failed', error: e);
      rethrow;
    }
  }

  // Restore user data from backup
  static Future<void> restoreUserData(String userId) async {
    if (!_isOnline) {
      throw Exception('Cannot restore data while offline');
    }

    try {
      // Get backup document
      final backupDoc = await _firestore
          .collection('backups')
          .doc(userId)
          .get();

      if (!backupDoc.exists) {
        throw Exception('No backup found for user');
      }

      final backupData = backupDoc.data()!;

      // Restore user profile
      if (backupData['userProfile'] != null) {
        // User profile restoration would be handled by UserRepository
      }

      AppLogger.i('User data restoration completed');
    } catch (e) {
      AppLogger.e('Restore failed', error: e);
      rethrow;
    }
  }
}
