import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/data_persistence_service.dart';

class UserState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  const UserState({this.profile, this.isLoading = false, this.error});

  UserState copyWith({UserProfile? profile, bool? isLoading, String? error}) {
    return UserState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserNotifier extends Notifier<UserState> {
  @override
  UserState build() {
    // Get the current auth state synchronously without watching
    final authStateAsync = ref.read(authStateProvider);
    
    // Set up listener for future auth state changes
    ref.listen(authStateProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            // Only load if we don't have a profile yet
            if (state.profile == null) {
              _loadUserProfile(user);
            }
          } else {
            // User signed out, clear profile
            state = const UserState();
          }
        },
        loading: () {
          // Auth is re-loading, set loading but preserve profile if needed
          state = state.copyWith(isLoading: true);
        },
        error: (error, stack) {
          state = state.copyWith(
            isLoading: false,
            error: error.toString(),
          );
        },
      );
    });

    // Determine initial state based on current auth state
    return authStateAsync.when(
      data: (user) {
        if (user != null) {
          // User is authenticated - trigger profile load
          Future.microtask(() => _loadUserProfile(user));
          // Return loading state while profile loads
          return const UserState(isLoading: true);
        }
        // No user - return empty state
        return const UserState();
      },
      loading: () {
        // Auth is loading
        return const UserState(isLoading: true);
      },
      error: (error, stack) {
        // Auth error
        return UserState(
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }

  Future<void> _loadUserProfile(User user) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Check if user profile exists in Firestore with a timeout
      // This prevents the app from getting stuck if there's no internet
      UserProfile? profile = await UserRepository.getUserById(user.uid)
          .timeout(const Duration(seconds: 10));

      if (profile == null) {
        // Create new user profile
        profile = await UserRepository.createUserFromAuth(user)
            .timeout(const Duration(seconds: 10));
      } else {
        // Update last login time
        // We don't await this to avoid blocking UI if it's slow
        UserRepository.updateLastLogin(user.uid).then((_) {
            // Background update specific fields if needed
            if (user.displayName != null && 
                user.displayName!.isNotEmpty && 
                user.displayName != profile!.displayName) {
                  final updated = profile!.copyWith(displayName: user.displayName!);
                  UserRepository.createOrUpdateUser(updated);
            }
        }).catchError((e) {
             // Ignore background update errors
             print('Error updating user stats: $e');
        });
        
        profile = profile.copyWith(lastLoginAt: DateTime.now());
      }

      state = state.copyWith(profile: profile, isLoading: false, error: null);
    } catch (e) {
      // Handle timeout and other errors
      final errorMessage = e.toString().contains('Timeout') 
          ? 'Network timeout. Please check your connection.' 
          : 'Failed to load user profile: $e';
          
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Update local state immediately
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        error: null,
      );

      // Save to Firestore with persistence service
      await DataPersistenceService.updateUserProfile(updatedProfile);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile: $e',
      );
    }
  }

  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    final currentProfile = state.profile;
    if (currentProfile == null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      await UserRepository.updateUserPreferences(
        currentProfile.id,
        preferences,
      );

      final updatedProfile = currentProfile.copyWith(preferences: preferences);
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update preferences: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final userStateProvider = NotifierProvider<UserNotifier, UserState>(
  UserNotifier.new,
);

final currentUserProvider = Provider<UserProfile?>((ref) {
  return ref.watch(userStateProvider).profile;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(userStateProvider).profile?.id;
});

final isUserLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userStateProvider).isLoading;
});

final userErrorProvider = Provider<String?>((ref) {
  return ref.watch(userStateProvider).error;
});
