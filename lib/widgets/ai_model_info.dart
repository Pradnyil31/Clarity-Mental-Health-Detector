import 'package:flutter/material.dart';
import '../services/ai_config.dart';

class AIModelInfo extends StatelessWidget {
  const AIModelInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AIConfig.currentConfig;
    final emotionInfo = AIConfig.modelInfo[config['emotion']];
    final chatInfo = AIConfig.modelInfo[config['chat']];

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Models in Use',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Emotion Model Info
            _buildModelCard(
              context,
              'Emotion Detection',
              config['emotion']!,
              emotionInfo,
              Icons.sentiment_satisfied,
              Colors.blue,
            ),

            const SizedBox(height: 12),

            // Chat Model Info
            _buildModelCard(
              context,
              'Conversation',
              config['chat']!,
              chatInfo,
              Icons.chat_bubble,
              Colors.green,
            ),

            const SizedBox(height: 16),

            // Current combination info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This combination provides detailed emotion detection (28 emotions) with high-quality conversational responses.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelCard(
    BuildContext context,
    String title,
    String modelName,
    Map<String, dynamic>? info,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            modelName.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          if (info != null) ...[
            const SizedBox(height: 4),
            Text(
              info['description'] ?? 'AI model for processing',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (info['emotions'] != null)
                  _buildInfoChip(
                    context,
                    '${info['emotions']} emotions',
                    Icons.psychology,
                  ),
                if (info['speed'] != null)
                  _buildInfoChip(
                    context,
                    '${info['speed']} speed',
                    Icons.speed,
                  ),
                if (info['quality'] != null)
                  _buildInfoChip(
                    context,
                    '${info['quality']} quality',
                    Icons.star,
                  ),
                if (info['accuracy'] != null)
                  _buildInfoChip(
                    context,
                    '${info['accuracy']} accuracy',
                    Icons.track_changes,
                  ),
                if (info['creativity'] != null)
                  _buildInfoChip(
                    context,
                    '${info['creativity']} creativity',
                    Icons.auto_awesome,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
