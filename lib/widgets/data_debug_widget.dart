import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/data_persistence_service.dart';
import '../services/firebase_service.dart';
import '../state/user_state.dart';

class DataDebugWidget extends ConsumerWidget {
  const DataDebugWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _buildDebugRow(
              'Firebase Initialized',
              FirebaseService.isInitialized,
            ),
            _buildDebugRow('User Authenticated', userState.profile != null),
            _buildDebugRow('Online Status', DataPersistenceService.isOnline),
            _buildDebugRow(
              'Pending Operations',
              DataPersistenceService.pendingOperationsCount.toString(),
            ),

            if (userState.profile != null) ...[
              const SizedBox(height: 8),
              _buildDebugRow('User ID', userState.profile!.id),
              _buildDebugRow('User Email', userState.profile!.email),
            ],

            if (userState.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Error: ${userState.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _clearPendingOperations(context),
                    child: const Text('Clear Pending'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _forceSyncOperations(context),
                    child: const Text('Force Sync'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value.toString(), style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _clearPendingOperations(BuildContext context) {
    DataPersistenceService.clearPendingOperations();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pending operations cleared'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _forceSyncOperations(BuildContext context) async {
    try {
      await DataPersistenceService.forceSyncPendingOperations();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Force sync completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Force sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
