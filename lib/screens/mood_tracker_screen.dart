import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/mood_state.dart';
import '../utils/responsive_utils.dart';

class MoodTrackerScreen extends ConsumerStatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  ConsumerState<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends ConsumerState<MoodTrackerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  int _selectedViewIndex = 0; // 0: Visual, 1: Chart, 2: Calendar, 3: Today
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _isInitialized = true;

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(moodTrackerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Mental Health Mood Tracker',
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop();
            } else {
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: entries.isEmpty
            ? _buildEmptyState(scheme)
            : _buildContent(entries, scheme),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Beautiful Log Mood Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary,
                    scheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showMoodInput(scheme),
                  borderRadius: BorderRadius.circular(28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_reaction_outlined,
                        color: scheme.onPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Log Your Mood',
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // View Toggle Buttons
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(25),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewToggle('Visual', 0, scheme),
                    _buildViewToggle('Chart', 1, scheme),
                    _buildViewToggle('Calendar', 2, scheme),
                    _buildViewToggle('Today', 3, scheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(String label, int index, ColorScheme scheme) {
    final isSelected = _selectedViewIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedViewIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? scheme.onPrimary
                : scheme.onSurface.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primaryContainer,
                    scheme.primaryContainer.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(Icons.mood, size: 60, color: scheme.primary),
            ),
            const SizedBox(height: 32),
            Text(
              'Start Your Mood Journey',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Track your daily mood and discover patterns that help you understand your mental wellness better.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: scheme.onSurface.withValues(alpha: 0.7),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: scheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Start Tips',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTipItem(
                    '📊',
                    'Complete assessments to get mood scores',
                    scheme,
                  ),
                  _buildTipItem(
                    '📱',
                    'Log daily moods with the + button',
                    scheme,
                  ),
                  _buildTipItem(
                    '📈',
                    'View trends and insights over time',
                    scheme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String emoji, String text, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<MoodEntry> entries, ColorScheme scheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMoodSummaryCard(entries, scheme),
          const SizedBox(height: 24),
          if (_selectedViewIndex == 0) ...[
            _buildVisualMoodTracker(entries, scheme),
            const SizedBox(height: 24),
            _buildMoodInsights(entries, scheme),
          ] else if (_selectedViewIndex == 1) ...[
            _buildChartView(entries, scheme),
          ] else if (_selectedViewIndex == 2) ...[
            _buildCalendarView(entries, scheme),
          ] else ...[
            _buildTodayView(entries, scheme),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodSummaryCard(List<MoodEntry> entries, ColorScheme scheme) {
    final recentEntries = entries.take(7).toList();
    final averageScore = recentEntries.isEmpty
        ? 0.0
        : recentEntries.map((e) => e.score).reduce((a, b) => a + b) /
              recentEntries.length;

    final moodData = _getMoodData(averageScore.round());

    return _isInitialized
        ? AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        moodData.color.withValues(alpha: 0.8),
                        moodData.color,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: moodData.color.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Current Mood',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        moodData.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        moodData.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '7-day average',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        : Container();
  }

  Widget _buildVisualMoodTracker(List<MoodEntry> entries, ColorScheme scheme) {
    final recentEntries = entries.reversed.take(14).toList().reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Mood History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildMoodGrid(recentEntries, scheme),
              const SizedBox(height: 20),
              _buildMoodLegend(scheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodGrid(List<MoodEntry> entries, ColorScheme scheme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 14,
      itemBuilder: (context, index) {
        if (index < entries.length) {
          final entry = entries[index];
          final moodData = _getMoodData(entry.score);
          return _buildMoodCell(entry, moodData, scheme);
        } else {
          return _buildEmptyMoodCell(scheme);
        }
      },
    );
  }

  Widget _buildMoodCell(
    MoodEntry entry,
    MoodData moodData,
    ColorScheme scheme,
  ) {
    return GestureDetector(
      onTap: () => _showMoodDetails(entry, moodData),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: moodData.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: moodData.color.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(moodData.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 2),
            Text(
              '${entry.date.day}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMoodCell(ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.add,
        color: scheme.onSurface.withValues(alpha: 0.3),
        size: 16,
      ),
    );
  }

  Widget _buildMoodLegend(ColorScheme scheme) {
    final moodLevels = [
      _getMoodData(90), // Excellent
      _getMoodData(70), // Good
      _getMoodData(50), // Okay
      _getMoodData(30), // Poor
      _getMoodData(10), // Severe
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Scale',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: moodLevels
              .map((mood) => _buildLegendItem(mood, scheme))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(MoodData mood, ColorScheme scheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: mood.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '${mood.emoji} ${mood.label}',
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildChartView(List<MoodEntry> entries, ColorScheme scheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Handle empty data case
    if (entries.isEmpty) {
      return Container(
        height: 380,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.surfaceContainerHighest.withValues(alpha: 0.8),
              scheme.surfaceContainer.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: scheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primary.withValues(alpha: 0.1),
                      scheme.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  size: 48,
                  color: scheme.primary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No mood data yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start tracking your mood to see beautiful trends',
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Process entries to calculate daily averages and sort in ascending order
    final processedEntries = _processEntriesForChart(entries);

    // Limit entries to prevent performance issues (show last 15 days for better visualization)
    final limitedEntries = processedEntries.length > 15
        ? processedEntries.sublist(processedEntries.length - 15)
        : processedEntries;

    final spots = limitedEntries
        .asMap()
        .entries
        .map(
          (entry) => FlSpot(entry.key.toDouble(), entry.value.score.toDouble()),
        )
        .toList();

    // Calculate average for trend line
    final average =
        limitedEntries.map((e) => e.score).reduce((a, b) => a + b) /
        limitedEntries.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Beautiful header with stats
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primaryContainer.withValues(alpha: 0.3),
                scheme.secondaryContainer.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primary,
                      scheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mood Trend Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last ${limitedEntries.length} entries • Avg: ${average.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getTrendColor(limitedEntries).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getTrendColor(
                      limitedEntries,
                    ).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTrendIcon(limitedEntries),
                      size: 16,
                      color: _getTrendColor(limitedEntries),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTrendText(limitedEntries),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getTrendColor(limitedEntries),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Beautiful chart container
        Container(
          height: 320,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.surfaceContainerHighest.withValues(alpha: 0.8),
                scheme.surfaceContainer.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: scheme.outline.withValues(
                      alpha: isDark ? 0.15 : 0.1,
                    ),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => scheme.surfaceContainerHighest,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final moodData = _getMoodData(spot.y.toInt());
                        return LineTooltipItem(
                          '${moodData.label}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Score: ${spot.y.toInt()}',
                              style: TextStyle(
                                color: moodData.color,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 ||
                            value == 20 ||
                            value == 40 ||
                            value == 60 ||
                            value == 80 ||
                            value == 100) {
                          final moodData = _getMoodData(value.toInt());
                          return Container(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  moodData.emoji,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: limitedEntries.length > 7 ? 2 : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < limitedEntries.length) {
                          final date = limitedEntries[index].date;
                          final isToday =
                              DateTime.now().difference(date).inDays == 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isToday
                                      ? 'Today'
                                      : '${date.month}/${date.day}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isToday
                                        ? scheme.primary
                                        : scheme.onSurface.withValues(
                                            alpha: 0.7,
                                          ),
                                    fontWeight: isToday
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (isToday)
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: scheme.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
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
                  // Main mood line
                  LineChartBarData(
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: scheme.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final moodData = _getMoodData(spot.y.toInt());
                        return FlDotCirclePainter(
                          radius: 6,
                          color: moodData.color,
                          strokeWidth: 3,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    spots: spots,
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary,
                        scheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          scheme.primary.withValues(alpha: 0.2),
                          scheme.primary.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                  // Average trend line
                  LineChartBarData(
                    isCurved: false,
                    color: scheme.secondary.withValues(alpha: 0.6),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    dashArray: [8, 4],
                    spots: List.generate(
                      limitedEntries.length,
                      (index) => FlSpot(index.toDouble(), average),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Legend
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildChartLegendItem(
                color: scheme.primary,
                label: 'Mood Trend',
                icon: Icons.show_chart_rounded,
                scheme: scheme,
              ),
              _buildChartLegendItem(
                color: scheme.secondary.withValues(alpha: 0.6),
                label: 'Average (${average.toStringAsFixed(1)})',
                icon: Icons.horizontal_rule_rounded,
                scheme: scheme,
                isDashed: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegendItem({
    required Color color,
    required String label,
    required IconData icon,
    required ColorScheme scheme,
    bool isDashed = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: isDashed
              ? CustomPaint(painter: DashedLinePainter(color: color))
              : null,
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getTrendColor(List<MoodEntry> entries) {
    if (entries.length < 2) return Colors.grey;
    final first = entries.first.score;
    final last = entries.last.score;
    if (last > first) return Colors.green;
    if (last < first) return Colors.red;
    return Colors.orange;
  }

  IconData _getTrendIcon(List<MoodEntry> entries) {
    if (entries.length < 2) return Icons.trending_flat_rounded;
    final first = entries.first.score;
    final last = entries.last.score;
    if (last > first) return Icons.trending_up_rounded;
    if (last < first) return Icons.trending_down_rounded;
    return Icons.trending_flat_rounded;
  }

  String _getTrendText(List<MoodEntry> entries) {
    if (entries.length < 2) return 'Stable';
    final first = entries.first.score;
    final last = entries.last.score;
    if (last > first) return 'Improving';
    if (last < first) return 'Declining';
    return 'Stable';
  }

  void _showMoodDetails(MoodEntry entry, MoodData moodData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text(moodData.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(moodData.label),
                  Text(
                    '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your mood score was ${entry.score}/100 on this day. ${moodData.description}',
            ),
            if (entry.factors.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Factors:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.factors.map((factor) {
                  return Chip(
                    label: Text(factor, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDayMoodDetails(DayMoodData dayMoodData, MoodData moodData) {
    final scheme = Theme.of(context).colorScheme;
    final sortedEntries = dayMoodData.entries.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, dayMoodData.day);
    final isToday =
        dayMoodData.day == now.day &&
        now.month == now.month &&
        now.year == now.year;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                moodData.color.withValues(alpha: 0.1),
                scheme.surface,
                scheme.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: moodData.color.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: moodData.color.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with mood emoji and info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      moodData.color.withValues(alpha: 0.8),
                      moodData.color,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Text(moodData.emoji, style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 12),
                    Text(
                      moodData.label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isToday
                          ? 'Today'
                          : '${_getDayName(date.weekday)}, ${_getMonthName(date.month)} ${dayMoodData.day}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Content area
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Average score card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: moodData.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: moodData.color.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.analytics_rounded,
                                  color: moodData.color,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dayMoodData.entries.length == 1
                                      ? 'Mood Score'
                                      : 'Average Score',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${dayMoodData.averageScore}',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: moodData.color,
                              ),
                            ),
                            Text(
                              '/ 100', // Updated max score
                              style: TextStyle(
                                fontSize: 16,
                                color: scheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              moodData.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: scheme.onSurface.withValues(alpha: 0.8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Individual entries (if multiple)
                      if (dayMoodData.entries.length > 1) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              color: scheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Individual Entries (${dayMoodData.entries.length})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...sortedEntries.asMap().entries.map((mapEntry) {
                          final index = mapEntry.key;
                          final entry = mapEntry.value;
                          final entryMoodData = _getMoodData(entry.score);
                          final time = TimeOfDay.fromDateTime(entry.date);

                          return Container(
                            margin: EdgeInsets.only(
                              bottom: index < sortedEntries.length - 1 ? 12 : 0,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: entryMoodData.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: entryMoodData.color.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: entryMoodData.color.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      entryMoodData.emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entryMoodData.label,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Score: ${entry.score}/100',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: scheme.onSurface.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                      if (entry.factors.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 4,
                                          runSpacing: 4,
                                          children: entry.factors.map((factor) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: scheme.surface,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: scheme.outline.withValues(alpha: 0.2),
                                                ),
                                              ),
                                              child: Text(
                                                factor,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: scheme.onSurface.withValues(alpha: 0.8),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: entryMoodData.color.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: entryMoodData.color,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      index == 0
                                          ? 'Latest'
                                          : '${index + 1}${_getOrdinalSuffix(index + 1)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: scheme.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Entry?'),
                                            content: const Text(
                                              'This will permanently remove this mood entry.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  ref
                                                      .read(
                                                        moodTrackerProvider.notifier,
                                                      )
                                                      .deleteEntry(entry.id);
                                                  Navigator.pop(context); // Dialog
                                                  Navigator.pop(context); // Sheet
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        size: 20,
                                        color: scheme.error.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ),

              // Close button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: moodData.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView(List<MoodEntry> entries, ColorScheme scheme) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    // Group entries by day and calculate daily averages
    final dayEntriesMap = <int, List<MoodEntry>>{};
    for (final entry in entries) {
      if (entry.date.year == now.year && entry.date.month == now.month) {
        dayEntriesMap.putIfAbsent(entry.date.day, () => []).add(entry);
      }
    }

    // Create average entries for each day
    final entryMap = <int, DayMoodData>{};
    for (final dayNumber in dayEntriesMap.keys) {
      final dayEntries = dayEntriesMap[dayNumber]!;
      final averageScore =
          dayEntries.map((e) => e.score).reduce((a, b) => a + b) /
          dayEntries.length;
      entryMap[dayNumber] = DayMoodData(
        day: dayNumber,
        averageScore: averageScore.round(),
        entries: dayEntries,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Calendar - ${_getMonthName(now.month)} ${now.year}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Weekday headers
              Row(
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              // Calendar grid
              ...List.generate(6, (weekIndex) {
                // Check if this week has any valid days
                bool hasValidDays = false;
                for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
                  final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                  if (dayNumber >= 1 && dayNumber <= daysInMonth) {
                    hasValidDays = true;
                    break;
                  }
                }

                // Only show weeks that have valid days
                if (!hasValidDays) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: List.generate(7, (dayIndex) {
                      final dayNumber =
                          weekIndex * 7 + dayIndex - firstWeekday + 1;

                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return const Expanded(child: SizedBox(height: 40));
                      }

                      final dayMoodData = entryMap[dayNumber];
                      final isToday = dayNumber == now.day;

                      return Expanded(
                        child: _buildCalendarDay(
                          dayNumber,
                          dayMoodData,
                          isToday,
                          scheme,
                        ),
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarDay(
    int day,
    DayMoodData? dayMoodData,
    bool isToday,
    ColorScheme scheme,
  ) {
    final moodData = dayMoodData != null
        ? _getMoodData(dayMoodData.averageScore)
        : null;

    return GestureDetector(
      onTap: dayMoodData != null
          ? () => _showDayMoodDetails(dayMoodData, moodData!)
          : null,
      child: Container(
        height: 45,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: dayMoodData != null
              ? moodData!.color.withValues(alpha: 0.2)
              : isToday
              ? scheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: dayMoodData != null
                ? moodData!.color.withValues(alpha: 0.5)
                : isToday
                ? scheme.primary
                : Colors.transparent,
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (dayMoodData != null) ...[
              Text(
                '${dayMoodData.averageScore}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (dayMoodData.entries.length > 1) ...[
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: moodData!.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ] else ...[
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                  color: isToday
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  Widget _buildMoodInsights(List<MoodEntry> entries, ColorScheme scheme) {
    if (entries.length < 3) return const SizedBox.shrink();

    final recentEntries = entries.reversed.take(7).toList();
    final moodCounts = <String, int>{};

    for (final entry in recentEntries) {
      final moodData = _getMoodData(entry.score);
      moodCounts[moodData.label] = (moodCounts[moodData.label] ?? 0) + 1;
    }

    final mostFrequentMood = moodCounts.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    final trend = _calculateTrend(recentEntries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                icon: Icons.trending_up,
                title: 'Weekly Trend',
                value: trend > 0
                    ? 'Improving'
                    : trend < 0
                    ? 'Declining'
                    : 'Stable',
                color: trend > 0
                    ? Colors.green
                    : trend < 0
                    ? Colors.red
                    : Colors.blue,
                scheme: scheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightCard(
                icon: Icons.favorite,
                title: 'Most Common',
                value: mostFrequentMood.key,
                color: _getMoodDataByLabel(mostFrequentMood.key).color,
                scheme: scheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStreakCard(entries, scheme),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required ColorScheme scheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(List<MoodEntry> entries, ColorScheme scheme) {
    final streak = _calculateStreak(entries);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department,
              color: scheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tracking Streak',
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$streak days',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Text('🔥', style: const TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  double _calculateTrend(List<MoodEntry> entries) {
    if (entries.length < 2) return 0;

    final firstHalf = entries.take(entries.length ~/ 2).toList();
    final secondHalf = entries.skip(entries.length ~/ 2).toList();

    final firstAvg =
        firstHalf.map((e) => e.score).reduce((a, b) => a + b) /
        firstHalf.length;
    final secondAvg =
        secondHalf.map((e) => e.score).reduce((a, b) => a + b) /
        secondHalf.length;

    return secondAvg -
        firstAvg; // Higher scores are better, so positive means improving
  }

  int _calculateStreak(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;

    final sortedEntries = entries.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    int streak = 0;
    DateTime? lastDate;

    for (final entry in sortedEntries) {
      if (lastDate == null) {
        streak = 1;
        lastDate = entry.date;
      } else {
        final daysDiff = lastDate.difference(entry.date).inDays;
        if (daysDiff == 1) {
          streak++;
          lastDate = entry.date;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  List<MoodEntry> _processEntriesForChart(List<MoodEntry> entries) {
    // Group entries by date and calculate daily averages
    final Map<String, List<MoodEntry>> groupedByDate = {};

    for (final entry in entries) {
      final dateKey =
          '${entry.date.year}-${entry.date.month}-${entry.date.day}';
      groupedByDate.putIfAbsent(dateKey, () => []).add(entry);
    }

    // Calculate daily averages and create new entries
    final List<MoodEntry> processedEntries = [];

    for (final dateKey in groupedByDate.keys) {
      final dayEntries = groupedByDate[dateKey]!;
      final averageScore =
          dayEntries.map((e) => e.score).reduce((a, b) => a + b) /
          dayEntries.length;

      // Use the first entry's date and ID, but with average score
      final firstEntry = dayEntries.first;
      processedEntries.add(
        MoodEntry(
          id: firstEntry.id,
          date: firstEntry.date,
          score: averageScore.round(),
        ),
      );
    }

    // Sort in ascending order (oldest first)
    processedEntries.sort((a, b) => a.date.compareTo(b.date));

    return processedEntries;
  }

  Widget _buildTodayView(List<MoodEntry> entries, ColorScheme scheme) {
    final today = DateTime.now();
    final todayEntries = entries
        .where(
          (entry) =>
              entry.date.year == today.year &&
              entry.date.month == today.month &&
              entry.date.day == today.day,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Mood - ${today.day}/${today.month}/${today.year}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        if (todayEntries.isEmpty) ...[
          _buildNoTodayDataCard(scheme),
        ] else ...[
          _buildTodayMoodCard(todayEntries, scheme),
          const SizedBox(height: 16),
          _buildTodayTestHistory(todayEntries, scheme),
        ],
      ],
    );
  }

  Widget _buildNoTodayDataCard(ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceContainerHighest.withValues(alpha: 0.8),
            scheme.surfaceContainer.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.1),
                  scheme.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.today_rounded,
              size: 48,
              color: scheme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No mood data for today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take an assessment or log your mood to see today\'s data',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMoodCard(List<MoodEntry> todayEntries, ColorScheme scheme) {
    final averageScore =
        todayEntries.map((e) => e.score).reduce((a, b) => a + b) /
        todayEntries.length;
    final moodData = _getMoodData(averageScore.round());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [moodData.color.withValues(alpha: 0.8), moodData.color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: moodData.color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Average',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    moodData.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(moodData.emoji, style: const TextStyle(fontSize: 48)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${todayEntries.length} test${todayEntries.length == 1 ? '' : 's'} taken • Score: ${averageScore.toStringAsFixed(1)}/100',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTestHistory(
    List<MoodEntry> todayEntries,
    ColorScheme scheme,
  ) {
    // Sort by most recent first for today's history
    final sortedEntries = todayEntries.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, color: scheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Test History (${todayEntries.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sortedEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final moodEntry = entry.value;
            final moodData = _getMoodData(moodEntry.score);
            final time = TimeOfDay.fromDateTime(moodEntry.date);

            return Container(
              margin: EdgeInsets.only(
                bottom: index < sortedEntries.length - 1 ? 8 : 0,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: moodData.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: moodData.color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: moodData.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        moodData.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moodData.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        Text(
                          'Score: ${moodEntry.score}/100',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: moodData.color,
                        ),
                      ),
                      Text(
                        index == 0
                            ? 'Latest'
                            : '${index + 1}${_getOrdinalSuffix(index + 1)} test',
                        style: TextStyle(
                          fontSize: 10,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  MoodData _getMoodDataByLabel(String label) {
    switch (label) {
      case 'Excellent':
        return _getMoodData(90);
      case 'Good':
        return _getMoodData(70);
      case 'Okay':
        return _getMoodData(50);
      case 'Poor':
        return _getMoodData(30);
      case 'Severe':
        return _getMoodData(10);
      default:
        return _getMoodData(50);
    }
  }

  void _showMoodInput(ColorScheme scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MoodInputSheet(
        onMoodSelected: (score, factors) {
          ref.read(moodTrackerProvider.notifier).recordToday(
            score,
            factors: factors,
          );
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Mood logged successfully!'),
              backgroundColor: scheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  MoodData _getMoodData(int score) {
    if (score >= 80) {
      return MoodData(
        emoji: '😊',
        label: 'Excellent',
        color: const Color(0xFF4CAF50),
        description: 'You were feeling great!',
      );
    } else if (score >= 60) {
      return MoodData(
        emoji: '🙂',
        label: 'Good',
        color: const Color(0xFF8BC34A),
        description: 'You were in a positive mood.',
      );
    } else if (score >= 40) {
      return MoodData(
        emoji: '😐',
        label: 'Okay',
        color: const Color(0xFFFFEB3B),
        description: 'You were feeling neutral.',
      );
    } else if (score >= 20) {
      return MoodData(
        emoji: '😔',
        label: 'Poor',
        color: const Color(0xFFFF9800),
        description: 'You were having a tough time.',
      );
    } else {
      return MoodData(
        emoji: '😢',
        label: 'Severe',
        color: const Color(0xFFF44336),
        description: 'You were struggling significantly.',
      );
    }
  }
}

class MoodData {
  final String emoji;
  final String label;
  final Color color;
  final String description;

  MoodData({
    required this.emoji,
    required this.label,
    required this.color,
    required this.description,
  });
}

class DayMoodData {
  final int day;
  final int averageScore;
  final List<MoodEntry> entries;

  DayMoodData({
    required this.day,
    required this.averageScore,
    required this.entries,
  });
}

class _MoodInputSheet extends StatefulWidget {
  final Function(int, List<String>) onMoodSelected;

  const _MoodInputSheet({required this.onMoodSelected});

  @override
  State<_MoodInputSheet> createState() => _MoodInputSheetState();
}

class _MoodInputSheetState extends State<_MoodInputSheet> {
  double _currentValue = 50;
  final List<String> _selectedFactors = [];

  final List<String> _factors = [
    'Work',
    'Family',
    'Friends',
    'Sleep',
    'Activity',
    'Health',
    'Weather',
    'Food',
    'Travel',
    'Relaxation',
    'Finances',
    'Hobbies',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final moodData = _getMoodData(_currentValue.toInt());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 32),
          // Animated Emoji
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: moodData.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: moodData.color.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      moodData.emoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            moodData.label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: moodData.color,
            ),
          ),
          Text(
            '${_currentValue.toInt()}/100',
            style: TextStyle(
              fontSize: 16,
              color: scheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: moodData.color,
              inactiveTrackColor: moodData.color.withValues(alpha: 0.2),
              thumbColor: Colors.white,
              overlayColor: moodData.color.withValues(alpha: 0.1),
              trackHeight: 12,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: _currentValue,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (value) => setState(() => _currentValue = value),
            ),
          ),
          const SizedBox(height: 32),
          // Factors Section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'What\'s affecting you?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _factors.map((factor) {
              final isSelected = _selectedFactors.contains(factor);
              return FilterChip(
                label: Text(factor),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFactors.add(factor);
                    } else {
                      _selectedFactors.remove(factor);
                    }
                  });
                },
                backgroundColor: scheme.surfaceContainerHighest,
                selectedColor: moodData.color.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? moodData.color : scheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? moodData.color.withValues(alpha: 0.5)
                        : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => widget.onMoodSelected(
                _currentValue.toInt(),
                _selectedFactors,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: moodData.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 4,
                shadowColor: moodData.color.withValues(alpha: 0.4),
              ),
              child: const Text(
                'Log Mood',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
        ],
      ),
    );
  }

  MoodData _getMoodData(int score) {
    if (score >= 80) {
      return MoodData(
        emoji: '😊',
        label: 'Excellent',
        color: const Color(0xFF4CAF50),
        description: 'You were feeling great!',
      );
    } else if (score >= 60) {
      return MoodData(
        emoji: '🙂',
        label: 'Good',
        color: const Color(0xFF8BC34A),
        description: 'You were in a positive mood.',
      );
    } else if (score >= 40) {
      return MoodData(
        emoji: '😐',
        label: 'Okay',
        color: const Color(0xFFFFEB3B),
        description: 'You were feeling neutral.',
      );
    } else if (score >= 20) {
      return MoodData(
        emoji: '😔',
        label: 'Poor',
        color: const Color(0xFFFF9800),
        description: 'You were having a tough time.',
      );
    } else {
      return MoodData(
        emoji: '😢',
        label: 'Severe',
        color: const Color(0xFFF44336),
        description: 'You were struggling significantly.',
      );
    }
  }
}

class MoodOption {
  final String emoji;
  final String label;
  final int score;
  final Color color;

  MoodOption({
    required this.emoji,
    required this.label,
    required this.score,
    required this.color,
  });
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 2.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
