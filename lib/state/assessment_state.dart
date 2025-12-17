import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assessment.dart';
import '../repositories/assessment_repository.dart';
import '../services/data_persistence_service.dart';
import '../state/user_state.dart';

class AssessmentState {
  final List<AssessmentResult> results;
  final bool isLoading;
  final String? error;

  const AssessmentState({
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  AssessmentState copyWith({
    List<AssessmentResult>? results,
    bool? isLoading,
    String? error,
  }) {
    return AssessmentState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AssessmentNotifier extends Notifier<AssessmentState> {
  StreamSubscription<List<AssessmentResult>>? _streamSubscription;

  @override
  AssessmentState build() {
    // Watch the current user ID and load data when it changes
    final userId = ref.watch(currentUserIdProvider);

    // Clean up subscription when provider is disposed
    ref.onDispose(() {
      _streamSubscription?.cancel();
    });

    // Load data when user ID is available
    if (userId != null) {
      // Use a future to avoid blocking the build method
      Future.microtask(() => _loadAssessmentResults(userId));
    } else {
      // Cancel subscription and clear state when no user
      _streamSubscription?.cancel();
    }

    return const AssessmentState();
  }

  Future<void> _loadAssessmentResults(String userId) async {
    try {
      // Cancel existing subscription
      _streamSubscription?.cancel();

      // Set loading state
      state = state.copyWith(isLoading: true, error: null);

      // Get assessment results from Firestore with real-time updates
      _streamSubscription =
          AssessmentRepository.getAssessmentResultsStream(userId).listen(
            (results) {
              state = state.copyWith(
                results: results,
                isLoading: false,
                error: null,
              );
            },
            onError: (error) {
              // Handle stream error
              state = state.copyWith(
                isLoading: false,
                error: 'Failed to load assessment results: $error',
              );
            },
          );
    } catch (e) {
      // Handle error - could show snackbar or log error
      // For now, just keep empty state
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load assessment results: $e',
      );
    }
  }

  Future<void> addAssessmentResult(AssessmentResult result) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      // Update local state immediately for better UX
      final updatedResults = [result, ...state.results];
      state = state.copyWith(results: updatedResults, error: null);

      // Save to Firestore with persistence service
      await DataPersistenceService.saveAssessmentResult(userId, result);
    } catch (e) {
      // If save failed, revert local state
      final revertedResults = state.results
          .where((r) => r.id != result.id)
          .toList();
      state = state.copyWith(
        results: revertedResults,
        error: 'Failed to save assessment result: $e',
      );
    }
  }

  Future<void> refreshResults() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      await _loadAssessmentResults(userId);
    }
  }

  List<AssessmentResult> getResultsByType(AssessmentKind kind) {
    return state.results.where((result) => result.kind == kind).toList();
  }

  AssessmentResult? getLatestResultByType(AssessmentKind kind) {
    final results = getResultsByType(kind);
    if (results.isEmpty) return null;
    return results.first; // Already sorted by date descending
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final assessmentStateProvider =
    NotifierProvider<AssessmentNotifier, AssessmentState>(
      AssessmentNotifier.new,
    );

final assessmentResultsProvider = Provider<List<AssessmentResult>>((ref) {
  return ref.watch(assessmentStateProvider).results;
});

final isAssessmentLoadingProvider = Provider<bool>((ref) {
  return ref.watch(assessmentStateProvider).isLoading;
});

final assessmentErrorProvider = Provider<String?>((ref) {
  return ref.watch(assessmentStateProvider).error;
});

// Provider for getting results by type
final assessmentResultsByTypeProvider =
    Provider.family<List<AssessmentResult>, AssessmentKind>((ref, kind) {
      return ref.watch(assessmentStateProvider.notifier).getResultsByType(kind);
    });

// Provider for getting latest result by type
final latestAssessmentByTypeProvider =
    Provider.family<AssessmentResult?, AssessmentKind>((ref, kind) {
      return ref
          .watch(assessmentStateProvider.notifier)
          .getLatestResultByType(kind);
    });
