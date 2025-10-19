import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/mood_state.dart';

class MoodTrackerScreen extends ConsumerWidget {
  const MoodTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(moodTrackerProvider);
    final scheme = Theme.of(context).colorScheme;

    final spots = entries
        .map(
          (e) => FlSpot(
            e.date.millisecondsSinceEpoch.toDouble(),
            e.score.toDouble(),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop();
            } else {
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: entries.isEmpty
            ? const Center(
                child: Text(
                  'No mood entries yet. Complete an assessment to get started.',
                ),
              )
            : LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 27,
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: entries.length > 7
                            ? (entries.length / 7).floorToDouble()
                            : 1,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            value.toInt(),
                          );
                          final label = '${date.month}/${date.day}';
                          return Text(
                            label,
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: scheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      spots: spots,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
