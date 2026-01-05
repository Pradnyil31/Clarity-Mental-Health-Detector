import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/assessment.dart';
import '../models/recommendation.dart';

class RecommendationService {
  static Future<Recommendation?> getRecommendation(
    AssessmentKind kind,
    String severity,
  ) async {
    String? assetPath;
    
    switch (kind) {
      case AssessmentKind.sleep:
        assetPath = 'assets/recommendations/sleep.json';
        break;
      case AssessmentKind.phq9:
        assetPath = 'assets/recommendations/phq9.json';
        break;
      case AssessmentKind.gad7:
        assetPath = 'assets/recommendations/gad7.json';
        break;
      case AssessmentKind.happiness:
        assetPath = 'assets/recommendations/happiness.json';
        break;
      case AssessmentKind.selfEsteem:
        assetPath = 'assets/recommendations/self_esteem.json';
        break;
      case AssessmentKind.pss10:
        assetPath = 'assets/recommendations/pss10.json';
        break;
      default:
        return null;
    }

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonMap = json.decode(jsonString);
      final data = RecommendationData.fromJson(jsonMap);
      return data.getRecommendation(severity);
    } catch (e) {
      // Log error or handle gracefully
      print('Error loading recommendations: $e');
      return null;
    }
  }
}
