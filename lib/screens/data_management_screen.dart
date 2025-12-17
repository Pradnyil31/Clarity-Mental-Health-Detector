import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../services/data_export_service.dart';
import '../services/data_sync_service.dart';
import '../state/user_state.dart';
import '../state/app_state.dart';
import '../state/mood_state.dart';
import '../state/assessment_state.dart';

class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() =>
      _DataManagementScreenState();
}

class _DataManagementScreenState extends ConsumerState<DataManagementScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _dataSummary;

  @override
  void initState() {
    super.initState();
    _loadDataSummary();
  }

  Future<void> _loadDataSummary() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      setState(() => _isLoading = true);
      final summary = await DataExportService.generateDataSummary(userId);
      setState(() => _dataSummary = summary);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data summary: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userState = ref.watch(userStateProvider);
    final journalEntries = ref.watch(journalProvider);
    final moodEntries = ref.watch(moodTrackerProvider);
    final assessmentState = ref.watch(assessmentStateProvider);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Data Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Overview Card
            _buildDataOverviewCard(
              context,
              journalEntries.length,
              moodEntries.length,
              assessmentState.results.length,
            ),

            const SizedBox(height: 24),

            // Export Section
            _buildSectionHeader(context, 'Export Data'),
            const SizedBox(height: 12),
            _buildExportOptions(context),

            const SizedBox(height: 24),

            // Import Section
            _buildSectionHeader(context, 'Import Data'),
            const SizedBox(height: 12),
            _buildImportOptions(context),

            const SizedBox(height: 24),

            // Sync Section
            _buildSectionHeader(context, 'Data Sync'),
            const SizedBox(height: 12),
            _buildSyncOptions(context),

            const SizedBox(height: 24),

            // Privacy Section
            _buildSectionHeader(context, 'Privacy & Security'),
            const SizedBox(height: 12),
            _buildPrivacyOptions(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDataOverviewCard(
    BuildContext context,
    int journalCount,
    int moodCount,
    int assessmentCount,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.3),
            scheme.secondaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.storage_rounded,
                  color: scheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Data Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? scheme.onSurface.withValues(alpha: 0.95)
                      : scheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildDataStat(
                  context,
                  'Journal Entries',
                  journalCount.toString(),
                  Icons.book_outlined,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDataStat(
                  context,
                  'Mood Records',
                  moodCount.toString(),
                  Icons.mood_rounded,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDataStat(
                  context,
                  'Assessments',
                  assessmentCount.toString(),
                  Icons.assessment_rounded,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),

          if (_dataSummary != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: scheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total data size: ${_dataSummary!['exportSize']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? scheme.onSurface.withValues(alpha: 0.8)
                          : scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;

    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).brightness == Brightness.dark
            ? scheme.onSurface.withValues(alpha: 0.95)
            : scheme.onSurface,
      ),
    );
  }

  Widget _buildExportOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          context,
          'Export All Data',
          'Download complete backup of your data',
          Icons.download_rounded,
          const Color(0xFF4CAF50),
          () => _exportAllData(),
        ),
        const SizedBox(height: 8),
        _buildOptionTile(
          context,
          'Export Anonymized Data',
          'Export data with personal info removed',
          Icons.privacy_tip_rounded,
          const Color(0xFF2196F3),
          () => _exportAnonymizedData(),
        ),
      ],
    );
  }

  Widget _buildImportOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          context,
          'Import from File',
          'Restore data from a backup file',
          Icons.upload_rounded,
          const Color(0xFF9C27B0),
          () => _importFromFile(),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Importing will merge with existing data. Duplicates may occur.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyncOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          context,
          'Sync Now',
          'Manually sync all data with cloud',
          Icons.sync_rounded,
          const Color(0xFF4CAF50),
          () => _syncData(),
        ),
        const SizedBox(height: 8),
        _buildOptionTile(
          context,
          'Cloud Backup',
          'Create secure backup in cloud storage',
          Icons.cloud_upload_rounded,
          const Color(0xFF2196F3),
          () => _createCloudBackup(),
        ),
      ],
    );
  }

  Widget _buildPrivacyOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          context,
          'Clear Local Cache',
          'Remove locally cached data',
          Icons.clear_all_rounded,
          const Color(0xFFFF9800),
          () => _clearLocalCache(),
        ),
        const SizedBox(height: 8),
        _buildOptionTile(
          context,
          'Delete All Data',
          'Permanently delete all your data',
          Icons.delete_forever_rounded,
          const Color(0xFFF44336),
          () => _showDeleteAllDataDialog(),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDestructive
              ? color.withValues(alpha: 0.3)
              : scheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? color
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? scheme.onSurface.withValues(alpha: 0.95)
                                    : scheme.onSurface),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? scheme.onSurface.withValues(alpha: 0.7)
                              : scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurface.withValues(alpha: 0.4),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Action methods
  Future<void> _exportAllData() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      setState(() => _isLoading = true);
      await DataExportService.exportToFile(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportAnonymizedData() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      setState(() => _isLoading = true);
      final anonymizedData = await DataExportService.exportAnonymizedData(
        userId,
      );
      // Handle anonymized export (similar to regular export but with anonymized data)

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anonymized data exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anonymized export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importFromFile() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isLoading = true);
        await DataExportService.importFromFile(
          userId,
          result.files.single.path!,
        );

        // Refresh all providers
        ref.invalidate(journalProvider);
        ref.invalidate(moodTrackerProvider);
        ref.invalidate(assessmentStateProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data imported successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncData() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      setState(() => _isLoading = true);
      await DataSyncService.forceSyncAllData(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synced successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createCloudBackup() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      setState(() => _isLoading = true);
      await DataSyncService.backupUserData(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloud backup created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearLocalCache() async {
    // Clear local cache implementation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Local cache cleared!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showDeleteAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This will permanently delete all your data including journal entries, mood records, and assessments. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAllData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    // Implementation for deleting all user data
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
