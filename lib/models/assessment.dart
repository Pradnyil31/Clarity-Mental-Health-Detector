class AssessmentQuestion {
  AssessmentQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.weights,
  });

  final String id;
  final String text;
  final List<String> options;
  final List<int> weights;

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestion(
      id: json['id'] as String,
      text: json['text'] as String,
      options: (json['options'] as List).map((e) => e.toString()).toList(),
      weights: (json['weights'] as List)
          .map((e) => (e as num).toInt())
          .toList(),
    );
  }
}

enum AssessmentKind { phq9, gad7, happiness, selfEsteem, pss10, sleep }

extension AssessmentKindX on AssessmentKind {
  String get assetPath {
    switch (this) {
      case AssessmentKind.phq9:
        return 'assets/questions/phq9.json';
      case AssessmentKind.gad7:
        return 'assets/questions/gad7.json';
      case AssessmentKind.happiness:
        return 'assets/questions/happiness.json';
      case AssessmentKind.selfEsteem:
        return 'assets/questions/self_esteem.json';
      case AssessmentKind.pss10:
        return 'assets/questions/pss10.json';
      case AssessmentKind.sleep:
        return 'assets/questions/sleep.json';
    }
  }

  String get title {
    switch (this) {
      case AssessmentKind.phq9:
        return 'PHQ-9 Depression Check';
      case AssessmentKind.gad7:
        return 'GAD-7 Anxiety Check';
      case AssessmentKind.happiness:
        return 'Happiness Assessment';
      case AssessmentKind.selfEsteem:
        return 'Self-Esteem Assessment';
      case AssessmentKind.pss10:
        return 'Perceived Stress Scale';
      case AssessmentKind.sleep:
        return 'Sleep Quality Assessment';
    }
  }

  int get questionCount {
    switch (this) {
      case AssessmentKind.phq9:
        return 9;
      case AssessmentKind.gad7:
        return 7;
      case AssessmentKind.happiness:
        return 10;
      case AssessmentKind.selfEsteem:
        return 10;
      case AssessmentKind.pss10:
        return 10;
      case AssessmentKind.sleep:
        return 7;
    }
  }
}

class AssessmentResult {
  AssessmentResult({
    required this.id,
    required this.kind,
    required this.totalScore,
    required this.normalizedScore,
    required this.severity,
    required this.completedAt,
    required this.answers,
  });

  final String id;
  final AssessmentKind kind;
  final int totalScore;
  final int normalizedScore; // 0-100 scale (100 = Best)
  final String severity;
  final DateTime completedAt;
  final List<int> answers;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'totalScore': totalScore,
      'normalizedScore': normalizedScore,
      'severity': severity,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'answers': answers,
    };
  }

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      id: json['id'] as String,
      kind: AssessmentKind.values.firstWhere(
        (e) => e.name == json['kind'],
        orElse: () => AssessmentKind.phq9,
      ),
      totalScore: json['totalScore'] as int,
      normalizedScore: (json['normalizedScore'] as num?)?.toInt() ?? 0,
      severity: json['severity'] as String,
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        json['completedAt'] as int,
      ),
      answers: List<int>.from(json['answers'] as List),
    );
  }

  AssessmentResult copyWith({
    String? id,
    AssessmentKind? kind,
    int? totalScore,
    int? normalizedScore,
    String? severity,
    DateTime? completedAt,
    List<int>? answers,
  }) {
    return AssessmentResult(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      totalScore: totalScore ?? this.totalScore,
      normalizedScore: normalizedScore ?? this.normalizedScore,
      severity: severity ?? this.severity,
      completedAt: completedAt ?? this.completedAt,
      answers: answers ?? this.answers,
    );
  }
}

class AssessmentScoring {
  static AssessmentResult score(AssessmentKind kind, List<int> answers) {
    final total = answers.fold<int>(0, (sum, v) => sum + v);
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    String severity;
    switch (kind) {
      case AssessmentKind.phq9:
        severity = total >= 20
            ? 'Severe'
            : total >= 15
            ? 'Moderately severe'
            : total >= 10
            ? 'Moderate'
            : total >= 5
            ? 'Mild'
            : 'Minimal';
        break;
      case AssessmentKind.gad7:
        severity = total >= 15
            ? 'Severe'
            : total >= 10
            ? 'Moderate'
            : total >= 5
            ? 'Mild'
            : 'Minimal';
        break;
      case AssessmentKind.happiness:
        severity = total >= 32
            ? 'Very High'
            : total >= 24
            ? 'High'
            : total >= 16
            ? 'Moderate'
            : total >= 8
            ? 'Low'
            : 'Very Low';
        break;
      case AssessmentKind.selfEsteem:
        severity = total >= 32
            ? 'High'
            : total >= 24
            ? 'Moderate-High'
            : total >= 16
            ? 'Moderate'
            : total >= 8
            ? 'Low'
            : 'Very Low';
        break;
      case AssessmentKind.pss10:
         severity = total >= 27
            ? 'High Stress'
            : total >= 14
            ? 'Moderate Stress'
            : 'Low Stress';
        break;
      case AssessmentKind.sleep:
         severity = total >= 21
            ? 'Excellent'
            : total >= 14
            ? 'Good'
            : total >= 7
            ? 'Fair'
            : 'Poor';
        break;   
    }

    int normalizedScore;
    switch (kind) {
      case AssessmentKind.phq9:
        // Max 27, High is Bad
        normalizedScore = ((27 - total) / 27 * 100).round();
        break;
      case AssessmentKind.gad7:
        // Max 21, High is Bad
        normalizedScore = ((21 - total) / 21 * 100).round();
        break;
      case AssessmentKind.pss10:
        // Max 40, High is Bad
        normalizedScore = ((40 - total) / 40 * 100).round();
        break;
      case AssessmentKind.happiness:
        // Max 40, High is Good
        normalizedScore = (total / 40 * 100).round();
        break;
      case AssessmentKind.selfEsteem:
        // Max 40, High is Good
        normalizedScore = (total / 40 * 100).round();
        break;
      case AssessmentKind.sleep:
        // Max 28, High is Good
        normalizedScore = (total / 28 * 100).round();
        break;
    }
    normalizedScore = normalizedScore.clamp(0, 100);

    return AssessmentResult(
      id: id,
      kind: kind,
      totalScore: total,
      normalizedScore: normalizedScore,
      severity: severity,
      completedAt: DateTime.now(),
      answers: answers,
    );
  }
}
