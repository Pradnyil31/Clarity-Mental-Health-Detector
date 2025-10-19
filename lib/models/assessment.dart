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
      weights: (json['weights'] as List).map((e) => (e as num).toInt()).toList(),
    );
  }
}

enum AssessmentKind { phq9, gad7 }

extension AssessmentKindX on AssessmentKind {
  String get assetPath => this == AssessmentKind.phq9
      ? 'assets/questions/phq9.json'
      : 'assets/questions/gad7.json';

  String get title => this == AssessmentKind.phq9
      ? 'PHQ-9 Depression Check'
      : 'GAD-7 Anxiety Check';

  int get questionCount => this == AssessmentKind.phq9 ? 9 : 7;
}

class AssessmentResult {
  AssessmentResult({required this.totalScore, required this.severity});
  final int totalScore;
  final String severity;
}

class AssessmentScoring {
  static AssessmentResult score(AssessmentKind kind, List<int> answers) {
    final total = answers.fold<int>(0, (sum, v) => sum + v);
    if (kind == AssessmentKind.phq9) {
      final s = total <= 4
          ? 'Minimal'
          : total <= 9
              ? 'Mild'
              : total <= 14
                  ? 'Moderate'
                  : total <= 19
                      ? 'Moderately severe'
                      : 'Severe';
      return AssessmentResult(totalScore: total, severity: s);
    } else {
      final s = total <= 4
          ? 'Minimal'
          : total <= 9
              ? 'Mild'
              : total <= 14
                  ? 'Moderate'
                  : 'Severe';
      return AssessmentResult(totalScore: total, severity: s);
    }
  }
}
