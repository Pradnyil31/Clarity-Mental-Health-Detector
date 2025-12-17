import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/firebase_service.dart';
import '../repositories/journal_repository.dart';
import '../repositories/mood_repository.dart';
import '../repositories/assessment_repository.dart';
import '../repositories/user_repository.dart';
import '../models/user_profile.dart';
import '../models/assessment.dart';
import '../state/app_state.dart';
import '../state/mood_state.dart';

class DataPersistenceService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;
  static StreamSubscription<List<ConnectivityResult>>?
  _connectivitySubscription;
  static bool _isOnline = true;
  static final List<PendingOperation> _pendingOperations = [];
  static Timer? _retryTimer;

  // Initialize data persistence service
  static Future<void> initialize() async {
    // Monitor connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final wasOnline = _isOnline;
      _isOnline =
          results.isNotEmpty &&
          !results.every((result) => result == ConnectivityResult.none);

      // If we just came back online, process pending operations
      if (!wasOnline && _isOnline) {
        _processPendingOperations();
      }
    });

    // Check initial connectivity
    final connectivityResults = await Connectivity().checkConnectivity();
    _isOnline =
        connectivityResults.isNotEmpty &&
        !connectivityResults.every(
          (result) => result == ConnectivityResult.none,
        );

    // Start retry timer for failed operations
    _startRetryTimer();
  }

  // Start retry timer for failed operations
  static void _startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_isOnline && _pendingOperations.isNotEmpty) {
        _processPendingOperations();
      }
    });
  }

  // Save journal entry with retry logic
  static Future<void> saveJournalEntry(
    String userId,
    JournalEntry entry,
  ) async {
    final operation = PendingOperation(
      type: OperationType.saveJournal,
      userId: userId,
      data: entry,
      timestamp: DateTime.now(),
    );

    if (_isOnline) {
      try {
        await JournalRepository.addJournalEntry(userId, entry);
        // Success - no need to queue
        return;
      } catch (e) {
        // Failed - queue for retry
        _pendingOperations.add(operation);
        throw e;
      }
    } else {
      // Offline - queue for later
      _pendingOperations.add(operation);
    }
  }

  // Save mood entry with retry logic
  static Future<void> saveMoodEntry(String userId, MoodEntry entry) async {
    final operation = PendingOperation(
      type: OperationType.saveMood,
      userId: userId,
      data: entry,
      timestamp: DateTime.now(),
    );

    if (_isOnline) {
      try {
        await MoodRepository.addMoodEntry(userId, entry);
        // Success - no need to queue
        return;
      } catch (e) {
        // Failed - queue for retry
        _pendingOperations.add(operation);
        throw e;
      }
    } else {
      // Offline - queue for later
      _pendingOperations.add(operation);
    }
  }

  // Save assessment result with retry logic
  static Future<void> saveAssessmentResult(
    String userId,
    AssessmentResult result,
  ) async {
    final operation = PendingOperation(
      type: OperationType.saveAssessment,
      userId: userId,
      data: result,
      timestamp: DateTime.now(),
    );

    if (_isOnline) {
      try {
        await AssessmentRepository.addAssessmentResult(userId, result);
        // Success - no need to queue
        return;
      } catch (e) {
        // Failed - queue for retry
        _pendingOperations.add(operation);
        throw e;
      }
    } else {
      // Offline - queue for later
      _pendingOperations.add(operation);
    }
  }

  // Update user profile with retry logic
  static Future<void> updateUserProfile(UserProfile profile) async {
    final operation = PendingOperation(
      type: OperationType.updateProfile,
      userId: profile.id,
      data: profile,
      timestamp: DateTime.now(),
    );

    if (_isOnline) {
      try {
        await UserRepository.createOrUpdateUser(profile);
        // Success - no need to queue
        return;
      } catch (e) {
        // Failed - queue for retry
        _pendingOperations.add(operation);
        throw e;
      }
    } else {
      // Offline - queue for later
      _pendingOperations.add(operation);
    }
  }

  // Process pending operations when back online
  static Future<void> _processPendingOperations() async {
    if (_pendingOperations.isEmpty || !_isOnline) return;

    final operationsToProcess = List<PendingOperation>.from(_pendingOperations);
    _pendingOperations.clear();

    for (final operation in operationsToProcess) {
      try {
        await _executeOperation(operation);
      } catch (e) {
        // Re-queue failed operations, but limit retry attempts
        if (operation.retryCount < 3) {
          operation.retryCount++;
          _pendingOperations.add(operation);
        }
      }
    }
  }

  // Execute a pending operation
  static Future<void> _executeOperation(PendingOperation operation) async {
    switch (operation.type) {
      case OperationType.saveJournal:
        await JournalRepository.addJournalEntry(
          operation.userId,
          operation.data as JournalEntry,
        );
        break;
      case OperationType.saveMood:
        await MoodRepository.addMoodEntry(
          operation.userId,
          operation.data as MoodEntry,
        );
        break;
      case OperationType.deleteMood:
        await MoodRepository.deleteMoodEntry(
          operation.userId,
          operation.data as String,
        );
        break;
      case OperationType.saveAssessment:
        await AssessmentRepository.addAssessmentResult(
          operation.userId,
          operation.data as AssessmentResult,
        );
        break;
      case OperationType.updateProfile:
        await UserRepository.createOrUpdateUser(operation.data as UserProfile);
        break;
    }
  }

  // Force sync all pending operations
  static Future<void> forceSyncPendingOperations() async {
    if (_isOnline) {
      await _processPendingOperations();
    }
  }

  // Get pending operations count
  static int get pendingOperationsCount => _pendingOperations.length;

  // Check if device is online
  static bool get isOnline => _isOnline;

  // Clear all pending operations (use with caution)
  static void clearPendingOperations() {
    _pendingOperations.clear();
  }

  // Delete mood entry with retry logic
  static Future<void> deleteMoodEntry(String userId, String entryId) async {
    final operation = PendingOperation(
      type: OperationType.deleteMood,
      userId: userId,
      data: entryId,
      timestamp: DateTime.now(),
    );

    if (_isOnline) {
      try {
        await MoodRepository.deleteMoodEntry(userId, entryId);
        return;
      } catch (e) {
        _pendingOperations.add(operation);
        throw e;
      }
    } else {
      _pendingOperations.add(operation);
    }
  }

  // Dispose resources
  static void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _pendingOperations.clear();
  }
}

// Enum for operation types
enum OperationType { saveJournal, saveMood, deleteMood, saveAssessment, updateProfile }

// Class to represent a pending operation
class PendingOperation {
  final OperationType type;
  final String userId;
  final dynamic data;
  final DateTime timestamp;
  int retryCount;

  PendingOperation({
    required this.type,
    required this.userId,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });
}
