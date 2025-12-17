import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../repositories/journal_repository.dart';
import '../repositories/mood_repository.dart';
import '../repositories/assessment_repository.dart';
import '../repositories/user_repository.dart';
import '../models/user_profile.dart';
import '../state/app_state.dart';
import '../state/mood_state.dart';
import '../models/assessment.dart';

class DataExportService {
  // Export all user data to JSON
  static Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      // Get all user data
      final userProfile = await UserRepository.getUserById(userId);
      final journalEntries = await JournalRepository.getJournalEntries(userId);
      final moodEntries = await MoodRepository.getMoodEntries(userId);
      final assessmentResults = await AssessmentRepository.getAssessmentResults(
        userId,
      );

      // Create export data structure
      final exportData = {
        'exportVersion': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'userId': userId,
        'userProfile': userProfile?.toJson(),
        'data': {
          'journalEntries': journalEntries.map((e) => e.toJson()).toList(),
          'moodEntries': moodEntries.map((e) => e.toJson()).toList(),
          'assessmentResults': assessmentResults
              .map((e) => e.toJson())
              .toList(),
        },
        'statistics': {
          'totalJournalEntries': journalEntries.length,
          'totalMoodEntries': moodEntries.length,
          'totalAssessments': assessmentResults.length,
          'dateRange': {
            'earliest': _getEarliestDate(
              journalEntries,
              moodEntries,
              assessmentResults,
            ),
            'latest': _getLatestDate(
              journalEntries,
              moodEntries,
              assessmentResults,
            ),
          },
        },
      };

      return exportData;
    } catch (e) {
      throw Exception('Failed to export user data: $e');
    }
  }

  // Export data to file and share
  static Future<void> exportToFile(
    String userId, {
    String? customFileName,
  }) async {
    try {
      final exportData = await exportUserData(userId);
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      final fileName =
          customFileName ??
          'clarity_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      if (kIsWeb) {
        // For web, use download
        await _downloadForWeb(jsonString, fileName);
      } else {
        // For mobile, save to file and share
        final file = await _saveToFile(jsonString, fileName);
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Clarity Mental Health Data Backup');
      }
    } catch (e) {
      throw Exception('Failed to export to file: $e');
    }
  }

  // Save data to local file
  static Future<File> _saveToFile(String content, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.writeAsString(content);
  }

  // Download for web platform
  static Future<void> _downloadForWeb(String content, String fileName) async {
    // This would need web-specific implementation
    // For now, just throw an error to indicate web support needed
    throw UnimplementedError('Web download not implemented yet');
  }

  // Import data from JSON
  static Future<void> importUserData(
    String userId,
    Map<String, dynamic> importData,
  ) async {
    try {
      // Validate import data structure
      if (!_validateImportData(importData)) {
        throw Exception('Invalid import data format');
      }

      final data = importData['data'] as Map<String, dynamic>;

      // Import journal entries
      if (data['journalEntries'] != null) {
        final journalEntries = (data['journalEntries'] as List)
            .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
            .toList();

        for (final entry in journalEntries) {
          await JournalRepository.addJournalEntry(userId, entry);
        }
      }

      // Import mood entries
      if (data['moodEntries'] != null) {
        final moodEntries = (data['moodEntries'] as List)
            .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
            .toList();

        for (final entry in moodEntries) {
          await MoodRepository.addMoodEntry(userId, entry);
        }
      }

      // Import assessment results
      if (data['assessmentResults'] != null) {
        final assessmentResults = (data['assessmentResults'] as List)
            .map((e) => AssessmentResult.fromJson(e as Map<String, dynamic>))
            .toList();

        for (final result in assessmentResults) {
          await AssessmentRepository.addAssessmentResult(userId, result);
        }
      }

      // Update user profile if provided
      if (importData['userProfile'] != null) {
        final userProfile = UserProfile.fromJson(
          importData['userProfile'] as Map<String, dynamic>,
        );
        await UserRepository.createOrUpdateUser(userProfile);
      }
    } catch (e) {
      throw Exception('Failed to import user data: $e');
    }
  }

  // Import data from file
  static Future<void> importFromFile(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final importData = json.decode(content) as Map<String, dynamic>;

      await importUserData(userId, importData);
    } catch (e) {
      throw Exception('Failed to import from file: $e');
    }
  }

  // Validate import data structure
  static bool _validateImportData(Map<String, dynamic> data) {
    // Check required fields
    if (!data.containsKey('exportVersion') ||
        !data.containsKey('exportDate') ||
        !data.containsKey('data')) {
      return false;
    }

    // Check data structure
    final dataSection = data['data'];
    if (dataSection is! Map<String, dynamic>) {
      return false;
    }

    return true;
  }

  // Get earliest date from all data
  static String? _getEarliestDate(
    List<JournalEntry> journalEntries,
    List<MoodEntry> moodEntries,
    List<AssessmentResult> assessmentResults,
  ) {
    final dates = <DateTime>[];

    dates.addAll(journalEntries.map((e) => e.timestamp));
    dates.addAll(moodEntries.map((e) => e.date));
    dates.addAll(assessmentResults.map((e) => e.completedAt));

    if (dates.isEmpty) return null;

    dates.sort();
    return dates.first.toIso8601String();
  }

  // Get latest date from all data
  static String? _getLatestDate(
    List<JournalEntry> journalEntries,
    List<MoodEntry> moodEntries,
    List<AssessmentResult> assessmentResults,
  ) {
    final dates = <DateTime>[];

    dates.addAll(journalEntries.map((e) => e.timestamp));
    dates.addAll(moodEntries.map((e) => e.date));
    dates.addAll(assessmentResults.map((e) => e.completedAt));

    if (dates.isEmpty) return null;

    dates.sort();
    return dates.last.toIso8601String();
  }

  // Generate data summary for user
  static Future<Map<String, dynamic>> generateDataSummary(String userId) async {
    try {
      final exportData = await exportUserData(userId);
      final statistics = exportData['statistics'] as Map<String, dynamic>;

      return {
        'totalEntries':
            statistics['totalJournalEntries'] +
            statistics['totalMoodEntries'] +
            statistics['totalAssessments'],
        'journalEntries': statistics['totalJournalEntries'],
        'moodEntries': statistics['totalMoodEntries'],
        'assessments': statistics['totalAssessments'],
        'dateRange': statistics['dateRange'],
        'exportSize': _calculateDataSize(exportData),
      };
    } catch (e) {
      throw Exception('Failed to generate data summary: $e');
    }
  }

  // Calculate approximate data size
  static String _calculateDataSize(Map<String, dynamic> data) {
    final jsonString = json.encode(data);
    final sizeInBytes = utf8.encode(jsonString).length;

    if (sizeInBytes < 1024) {
      return '${sizeInBytes}B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  // Create anonymized export (removes personal info)
  static Future<Map<String, dynamic>> exportAnonymizedData(
    String userId,
  ) async {
    try {
      final exportData = await exportUserData(userId);

      // Remove personal information
      exportData.remove('userId');
      exportData.remove('userProfile');

      // Anonymize journal entries (keep structure but remove text)
      final data = exportData['data'] as Map<String, dynamic>;
      if (data['journalEntries'] != null) {
        final journalEntries = data['journalEntries'] as List;
        for (final entry in journalEntries) {
          (entry as Map<String, dynamic>)['text'] = '[REDACTED]';
        }
      }

      exportData['anonymized'] = true;
      exportData['note'] = 'This export has been anonymized for privacy';

      return exportData;
    } catch (e) {
      throw Exception('Failed to create anonymized export: $e');
    }
  }
}
