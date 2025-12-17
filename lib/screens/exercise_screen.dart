import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/user_repository.dart';
import '../state/user_state.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  // Activity Selection
  String _selectedActivity = 'Walk';
  final List<Map<String, dynamic>> _activities = [
    {'name': 'Walk', 'icon': Icons.directions_walk},
    {'name': 'Run', 'icon': Icons.directions_run},
    {'name': 'Yoga', 'icon': Icons.self_improvement},
    {'name': 'Gym', 'icon': Icons.fitness_center},
    {'name': 'Swim', 'icon': Icons.pool},
    {'name': 'Cycle', 'icon': Icons.directions_bike},
    {'name': 'Dance', 'icon': Icons.music_note},
    {'name': 'Sport', 'icon': Icons.sports_basketball},
  ];

  // Duration
  double _durationMinutes = 30;

  // Intensity (1-5)
  double _intensity = 3;

  Future<void> _saveActivity() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      await UserRepository.logActivity(userId, {
        'type': _selectedActivity,
        'durationMinutes': _durationMinutes.round(),
        'intensity': _intensity.round(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logged $_selectedActivity for ${_durationMinutes.round()} mins',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save activity: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Activity'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Select Activity Type
            Text(
              'What did you do?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _activities.map((activity) {
                final isSelected = _selectedActivity == activity['name'];
                return ChoiceChip(
                  label: Text(activity['name']),
                  avatar: Icon(
                    activity['icon'],
                    size: 18,
                    color: isSelected ? scheme.onPrimary : scheme.onSurface,
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedActivity = activity['name']);
                    }
                  },
                  selectedColor: scheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? scheme.onPrimary : scheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // 2. Duration Slider
            Text(
              'Duration: ${_durationMinutes.round()} min',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('5 min'),
                      const Text('120 min'),
                    ],
                  ),
                  Slider(
                    value: _durationMinutes,
                    min: 5,
                    max: 120,
                    divisions: 23, // 5 minute steps
                    label: '${_durationMinutes.round()} min',
                    onChanged: (value) =>
                        setState(() => _durationMinutes = value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. Intensity Rating
            Text(
              'Intensity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final level = index + 1;
                final isSelected = _intensity >= level;
                return GestureDetector(
                  onTap: () => setState(() => _intensity = level.toDouble()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getIntensityColor(level)
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: _getIntensityColor(level), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        level.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Light', style: Theme.of(context).textTheme.bodySmall),
                Text('Intense', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),

            const SizedBox(height: 48),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _saveActivity,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Log Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 4. Recent Activities
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final userId = ref.watch(currentUserIdProvider);
                if (userId == null) return const SizedBox.shrink();

                return StreamBuilder<QuerySnapshot>(
                  stream: UserRepository.getActivityLogs(userId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error loading logs: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Text(
                        'No activities logged yet.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    }
                    
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final type = data['type'] as String? ?? 'Activity';
                        final duration = data['durationMinutes'] as int? ?? 0;
                        final intensity = data['intensity'] as int? ?? 0;
                        final timestamp = (data['createdAt'] != null) 
                            ? DateTime.tryParse(data['createdAt']) 
                            : null;
                            
                        return Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getActivityIcon(type),
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              type,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              timestamp != null 
                                  ? '${timestamp.day}/${timestamp.month} • $duration mins'
                                  : '$duration mins',
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getIntensityColor(intensity).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Intensity $intensity',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getIntensityColor(intensity),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    final activity = _activities.firstWhere(
      (a) => a['name'] == type,
      orElse: () => {'icon': Icons.fitness_center},
    );
    return activity['icon'] as IconData;
  }

  Color _getIntensityColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
