class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> preferences;
  final bool hasCompletedOnboarding;
  final List<String> goals;
  final String? experienceLevel;
  final String? avatarId;
  final String? phoneNumber;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.lastLoginAt,
    this.preferences = const {},
    this.hasCompletedOnboarding = false,
    this.goals = const [],
    this.experienceLevel,
    this.avatarId,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt.millisecondsSinceEpoch,
      'preferences': preferences,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'goals': goals,
      'experienceLevel': experienceLevel,
      'avatarId': avatarId,
      'phoneNumber': phoneNumber,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      lastLoginAt: DateTime.fromMillisecondsSinceEpoch(
        json['lastLoginAt'] as int,
      ),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      goals: (json['goals'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      experienceLevel: json['experienceLevel'] as String?,
      avatarId: json['avatarId'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    bool? hasCompletedOnboarding,
    List<String>? goals,
    String? experienceLevel,
    String? avatarId,
    String? phoneNumber,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      goals: goals ?? this.goals,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      avatarId: avatarId ?? this.avatarId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
