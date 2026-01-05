class RecommendationTip {
  final String title;
  final String description;

  RecommendationTip({
    required this.title,
    required this.description,
  });

  factory RecommendationTip.fromJson(Map<String, dynamic> json) {
    return RecommendationTip(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

class Recommendation {
  final String title;
  final String description;
  final List<RecommendationTip> tips;

  Recommendation({
    required this.title,
    required this.description,
    required this.tips,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      title: json['title'] as String,
      description: json['description'] as String,
      tips: (json['tips'] as List)
          .map((e) => RecommendationTip.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RecommendationData {
  final Map<String, Recommendation> recommendations;

  RecommendationData({required this.recommendations});

  factory RecommendationData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> textMap = json['recommendations'];
    final Map<String, Recommendation> parsedMap = {};
    
    textMap.forEach((key, value) {
      parsedMap[key] = Recommendation.fromJson(value as Map<String, dynamic>);
    });

    return RecommendationData(recommendations: parsedMap);
  }
  
  Recommendation? getRecommendation(String severity) {
    return recommendations[severity];
  }
}
