import 'package:flutter/material.dart';
import '../services/emotion_detection_service.dart';

class ModelHealthMonitor extends StatefulWidget {
  final EmotionDetectionService emotionService;

  const ModelHealthMonitor({super.key, required this.emotionService});

  @override
  State<ModelHealthMonitor> createState() => _ModelHealthMonitorState();
}

class _ModelHealthMonitorState extends State<ModelHealthMonitor> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final healthCheck = widget.emotionService.lastHealthCheck;
    final successRate = widget.emotionService.successRate;
    final averageResponseTime = widget.emotionService.averageResponseTime;
    final isHealthy = widget.emotionService.isHealthy;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              _getStatusIcon(healthCheck?.status),
              color: _getStatusColor(healthCheck?.status, isHealthy),
            ),
            title: const Text('Model Health Status'),
            subtitle: Text(_getStatusText(healthCheck?.status, isHealthy)),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetricRow(
                    'Success Rate',
                    '${(successRate * 100).toStringAsFixed(1)}%',
                  ),
                  if (averageResponseTime != null)
                    _buildMetricRow(
                      'Avg Response Time',
                      '${averageResponseTime.inMilliseconds}ms',
                    ),
                  if (healthCheck?.timestamp != null)
                    _buildMetricRow(
                      'Last Check',
                      _formatTimestamp(healthCheck!.timestamp),
                    ),
                  if (healthCheck?.errorMessage != null)
                    _buildMetricRow(
                      'Last Error',
                      healthCheck!.errorMessage!,
                      isError: true,
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _performHealthCheck,
                          icon: const Icon(Icons.health_and_safety),
                          label: const Text('Run Health Check'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isError ? Colors.red : null,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(ModelStatus? status) {
    switch (status) {
      case ModelStatus.responding:
        return Icons.check_circle;
      case ModelStatus.loading:
        return Icons.hourglass_empty;
      case ModelStatus.timeout:
        return Icons.timer_off;
      case ModelStatus.error:
        return Icons.error;
      case ModelStatus.notResponding:
        return Icons.warning;
      case null:
        return Icons.help;
    }
  }

  Color _getStatusColor(ModelStatus? status, bool isHealthy) {
    if (!isHealthy) return Colors.red;

    switch (status) {
      case ModelStatus.responding:
        return Colors.green;
      case ModelStatus.loading:
        return Colors.orange;
      case ModelStatus.timeout:
        return Colors.red;
      case ModelStatus.error:
        return Colors.red;
      case ModelStatus.notResponding:
        return Colors.red;
      case null:
        return Colors.grey;
    }
  }

  String _getStatusText(ModelStatus? status, bool isHealthy) {
    if (!isHealthy) return 'Circuit breaker active - using fallback';

    switch (status) {
      case ModelStatus.responding:
        return 'Model is responding normally';
      case ModelStatus.loading:
        return 'Model is loading, please wait';
      case ModelStatus.timeout:
        return 'Request timed out';
      case ModelStatus.error:
        return 'Model error occurred';
      case ModelStatus.notResponding:
        return 'Model is not responding';
      case null:
        return 'Status unknown - no requests made yet';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

  Future<void> _performHealthCheck() async {
    try {
      await widget.emotionService.performHealthCheck();
      setState(() {}); // Refresh the UI

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health check completed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Health check failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
