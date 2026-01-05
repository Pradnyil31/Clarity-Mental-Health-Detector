
class SafetyPlan {
  final List<Contact> safeContacts;
  final List<Contact> professionalSupport;

  SafetyPlan({
    this.safeContacts = const [],
    this.professionalSupport = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'safeContacts': safeContacts.map((c) => c.toJson()).toList(),
      'professionalSupport': professionalSupport.map((c) => c.toJson()).toList(),
    };
  }

  factory SafetyPlan.fromJson(Map<String, dynamic> json) {
    return SafetyPlan(
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
    List<Contact>? safeContacts,
    List<Contact>? professionalSupport,
  }) {
    return SafetyPlan(
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
