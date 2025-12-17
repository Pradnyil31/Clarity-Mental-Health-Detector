import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OnboardingStep {
  splash,
  carousel,
  personalization,
  breathing,
  completion,
}

class OnboardingState {
  final OnboardingStep currentStep;
  final String? userName;
  final List<String> selectedGoals;
  final String? experienceLevel;
  final int carouselPage;
  final int personalizationStep;
  final String? selectedAvatar;

  const OnboardingState({
    this.currentStep = OnboardingStep.splash,
    this.userName,
    this.selectedGoals = const [],
    this.experienceLevel,
    this.carouselPage = 0,
    this.personalizationStep = 0,
    this.selectedAvatar,
  });

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    String? userName,
    List<String>? selectedGoals,
    String? experienceLevel,
    int? carouselPage,
    int? personalizationStep,
    String? selectedAvatar,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      userName: userName ?? this.userName,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      carouselPage: carouselPage ?? this.carouselPage,
      personalizationStep: personalizationStep ?? this.personalizationStep,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  void setStep(OnboardingStep step) {
    state = state.copyWith(currentStep: step);
  }

  void setCarouselPage(int page) {
    state = state.copyWith(carouselPage: page);
  }

  void setPersonalizationStep(int step) {
    state = state.copyWith(personalizationStep: step);
  }

  void updateName(String name) {
    state = state.copyWith(userName: name);
  }
  
  void setAvatar(String avatarId) {
    state = state.copyWith(selectedAvatar: avatarId);
  }

  void toggleGoal(String goal) {
    final goals = List<String>.from(state.selectedGoals);
    if (goals.contains(goal)) {
      goals.remove(goal);
    } else {
      goals.add(goal);
    }
    state = state.copyWith(selectedGoals: goals);
  }

  void setExperienceLevel(String level) {
    state = state.copyWith(experienceLevel: level);
  }

  void reset() {
    state = const OnboardingState();
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);
