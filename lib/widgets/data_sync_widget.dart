import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/data_sync_service.dart';
import '../services/data_persistence_service.dart';
import '../state/user_state.dart';
import '../state/app_state.dart';
import '../state/mood_state.dart';
import '../state/assessment_state.dart';

class DataSyncWidget extends ConsumerWidget {
  const DataSyncWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userState = ref.watch(userStateProvider);
    final journalEntries = ref.watch(journalProvider);
    final moodEntries = ref.watch(moodTrackerProvider);
    final assessmentState = ref.watch(assessmentStateProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    DataPersistenceService.isOnline
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_off_rounded,
                    color: DataPersistenceService.isOnline
                        ? Colors.green
                        : Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Sync Status',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? scheme.onSurface.withValues(alpha: 0.95)
                                  : scheme.onSurface,
                            ),
                      ),
                      Text(
                        DataPersistenceService.isOnline ? 'Online' : 'Offline',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: DataPersistenceService.isOnline
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (DataPersistenceService.pendingOperationsCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${DataPersistenceService.pendingOperationsCount} pending',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Data Statistics
            Text(
              'Your Data',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? scheme.onSurface.withValues(alpha: 0.9)
                    : scheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            // Data counts grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
              children: [
                _DataStatItem(
                  icon: Icons.book_outlined,
                  label: 'Journal Entries',
                  count: journalEntries.length,
                  color: const Color(0xFF2196F3),
                ),
                _DataStatItem(
                  icon: Icons.mood_rounded,
                  label: 'Mood Records',
                  count: moodEntries.length,
                  color: const Color(0xFF4CAF50),
                ),
                _DataStatItem(
                  icon: Icons.assessment_rounded,
                  label: 'Assessments',
                  count: assessmentState.results.length,
                  color: const Color(0xFF9C27B0),
                ),
                _DataStatItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  count: userState.profile != null ? 1 : 0,
                  color: const Color(0xFFFF5722),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: DataPersistenceService.isOnline
                        ? () => _forceSyncData(context, ref)
                        : null,
                    icon: const Icon(Icons.sync_rounded, size: 18),
                    label: const Text('Sync Now'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: DataPersistenceService.isOnline
                        ? () => _backupData(context, ref)
                        : null,
                    icon: const Icon(Icons.backup_rounded, size: 18),
                    label: const Text('Backup'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            // Last sync info
            if (userState.profile != null) ...[
              const SizedBox(height: 12),
              Text(
                'Last sync: ${_formatLastSync(userState.profile!.lastLoginAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? scheme.onSurface.withValues(alpha: 0.7)
                      : scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _forceSyncData(BuildContext context, WidgetRef ref) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Syncing data...'),
            ],
          ),
        ),
      );

      // Force sync pending operations
      await DataPersistenceService.forceSyncPendingOperations();

      // Also sync with the old service for compatibility
      await DataSyncService.forceSyncAllData(userId);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synced successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _backupData(BuildContext context, WidgetRef ref) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creating backup...'),
            ],
          ),
        ),
      );

      await DataSyncService.backupUserData(userId);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _DataStatItem extends StatelessWidget {
  const _DataStatItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8)
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
