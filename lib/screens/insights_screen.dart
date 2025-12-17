import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/mood_state.dart';
import '../state/app_state.dart';
import '../state/assessment_state.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final moodEntries = ref.watch(moodTrackerProvider);
    final journalEntries = ref.watch(journalProvider);
    final assessmentState = ref.watch(assessmentStateProvider);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Your Insights'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? scheme.onSurface.withValues(alpha: 0.95)
                    : scheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildInsightCard(
                  context,
                  'Mood Entries',
                  '${moodEntries.length}',
                  Icons.mood_rounded,
                  const Color(0xFF4CAF50),
                ),
                _buildInsightCard(
                  context,
                  'Journal Entries',
                  '${journalEntries.length}',
                  Icons.edit_note_rounded,
                  const Color(0xFF2196F3),
                ),
                _buildInsightCard(
                  context,
                  'Assessments',
                  '${assessmentState.results.length}',
                  Icons.assessment_rounded,
                  const Color(0xFF9C27B0),
                ),
                _buildInsightCard(
                  context,
                  'Average Mood',
                  moodEntries.isNotEmpty
                      ? (moodEntries
                                    .map((e) => e.score)
                                    .reduce((a, b) => a + b) /
                                moodEntries.length)
                            .toStringAsFixed(1)
                      : '0.0',
                  Icons.trending_up_rounded,
                  const Color(0xFFFF5722),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? scheme.onSurface.withValues(alpha: 0.95)
                    : scheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  if (journalEntries.isNotEmpty) ...[
                    _buildActivityItem(
                      context,
                      'Latest Journal Entry',
                      _formatDate(journalEntries.first.timestamp),
                      Icons.book_rounded,
                      const Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (moodEntries.isNotEmpty) ...[
                    _buildActivityItem(
                      context,
                      'Latest Mood Entry',
                      _formatDate(moodEntries.first.date),
                      Icons.mood_rounded,
                      const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (assessmentState.results.isNotEmpty) ...[
                    _buildActivityItem(
                      context,
                      'Latest Assessment',
                      _formatDate(assessmentState.results.first.completedAt),
                      Icons.assessment_rounded,
                      const Color(0xFF9C27B0),
                    ),
                  ],
                  if (journalEntries.isEmpty &&
                      moodEntries.isEmpty &&
                      assessmentState.results.isEmpty)
                    const Text('No recent activity'),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? scheme.onSurface.withValues(alpha: 0.9)
                  : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String date,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.95)
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7)
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
