class SafetyPlan {
  final List<String> warningSigns;
  final List<String> copingStrategies;
  final List<Contact> safeContacts;
  final List<Contact> professionalSupport;

  SafetyPlan({
    this.warningSigns = const [],
    this.copingStrategies = const [],
    this.safeContacts = const [],
    this.professionalSupport = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'warningSigns': warningSigns,
      'copingStrategies': copingStrategies,
      'safeContacts': safeContacts.map((c) => c.toJson()).toList(),
      'professionalSupport': professionalSupport.map((c) => c.toJson()).toList(),
    };
  }

  factory SafetyPlan.fromJson(Map<String, dynamic> json) {
    return SafetyPlan(
      warningSigns: List<String>.from(json['warningSigns'] ?? []),
      copingStrategies: List<String>.from(json['copingStrategies'] ?? []),
      safeContacts: (json['safeContacts'] as List<dynamic>?)
              ?.map((c) => Contact.fromJson(c))
              .toList() ??
          [],
      professionalSupport: (json['professionalSupport'] as List<dynamic>?)
              ?.map((c) => Contact.fromJson(c))
              .toList() ??
          [],
    );
  }

  SafetyPlan copyWith({
    List<String>? warningSigns,
    List<String>? copingStrategies,
    List<Contact>? safeContacts,
    List<Contact>? professionalSupport,
  }) {
    return SafetyPlan(
      warningSigns: warningSigns ?? this.warningSigns,
      copingStrategies: copingStrategies ?? this.copingStrategies,
      safeContacts: safeContacts ?? this.safeContacts,
      professionalSupport: professionalSupport ?? this.professionalSupport,
    );
  }
}

class Contact {
  final String name;
  final String number;

  Contact({required this.name, required this.number});

  Map<String, dynamic> toJson() => {'name': name, 'number': number};

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'] ?? '',
      number: json['number'] ?? '',
    );
  }
}
