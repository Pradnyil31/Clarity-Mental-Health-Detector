import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/mood_state.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(moodTrackerProvider);
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final startOfMonth = DateTime(now.year, now.month, 1);

    int sum(Iterable<int> xs) => xs.isEmpty ? 0 : xs.reduce((a, b) => a + b);

    final weekScores = entries
        .where((e) => e.date.isAfter(startOfWeek))
        .map((e) => e.score)
        .toList();
    final monthScores = entries
        .where((e) => e.date.isAfter(startOfMonth))
        .map((e) => e.score)
        .toList();
    final weekAvg = weekScores.isEmpty
        ? 0
        : sum(weekScores) / weekScores.length;
    final monthAvg = monthScores.isEmpty
        ? 0
        : sum(monthScores) / monthScores.length;

    int streak = 0;
    DateTime? prev;
    for (final e in entries.reversed) {
      if (prev == null) {
        prev = e.date;
        streak = 1;
      } else {
        final p = prev;
        final expected = DateTime(
          p.year,
          p.month,
          p.day,
        ).subtract(const Duration(days: 1));
        if (e.date.year == expected.year &&
            e.date.month == expected.month &&
            e.date.day == expected.day) {
          streak++;
          prev = e.date;
        } else {
          break;
        }
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea).withValues(alpha: 0.1),
              const Color(0xFF764ba2).withValues(alpha: 0.05),
              const Color(0xFFf093fb).withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Beautiful Header
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).maybePop();
                      } else {
                        Navigator.of(context).pushReplacementNamed('/');
                      }
                    },
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background shapes
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF667eea).withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFf093fb).withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Your Mental Health',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Insights & Trends',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Cards
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _BeautifulStatCard(
                      title: 'This Week',
                      value: weekAvg.toStringAsFixed(1),
                      subtitle: 'Average Score',
                      icon: Icons.calendar_view_week_rounded,
                      gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
                      trend: _calculateTrend(weekScores),
                    ),
                    const SizedBox(height: 12),
                    _BeautifulStatCard(
                      title: 'This Month',
                      value: monthAvg.toStringAsFixed(1),
                      subtitle: 'Average Score',
                      icon: Icons.calendar_month_rounded,
                      gradient: const [Color(0xFFf093fb), Color(0xFFf5576c)],
                      trend: _calculateTrend(monthScores),
                    ),
                    const SizedBox(height: 12),
                    _BeautifulStatCard(
                      title: 'Streak',
                      value: entries.isEmpty ? '0' : '$streak',
                      subtitle: 'Days in a row',
                      icon: Icons.local_fire_department_rounded,
                      gradient: const [Color(0xFF4facfe), Color(0xFF00f2fe)],
                      trend: null,
                    ),
                    const SizedBox(height: 12),
                    _BeautifulStatCard(
                      title: 'Total Entries',
                      value: '${entries.length}',
                      subtitle: 'Check-ins',
                      icon: Icons.analytics_rounded,
                      gradient: const [Color(0xFF43e97b), Color(0xFF38f9d7)],
                      trend: null,
                    ),
                  ]),
                ),
              ),

              // Progress Chart Section
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: _ProgressChartCard(entries: entries),
                ),
              ),

              // Tips Section
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(child: _TipsCard()),
              ),

              // Motivational Quote
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                sliver: SliverToBoxAdapter(child: _MotivationalCard()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _calculateTrend(List<int> scores) {
    if (scores.length < 2) return null;
    final recent = scores.take(3).fold(0, (a, b) => a + b) / 3;
    final older = scores.skip(3).take(3).fold(0, (a, b) => a + b) / 3;
    if (recent > older + 0.5) return '↗️ Improving';
    if (recent < older - 0.5) return '↘️ Declining';
    return '→ Stable';
  }
}

class _BeautifulStatCard extends StatelessWidget {
  const _BeautifulStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.trend,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient[0].withValues(alpha: 0.1),
            gradient[1].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gradient[0].withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: gradient[0],
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (trend != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend!,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressChartCard extends StatelessWidget {
  const _ProgressChartCard({required this.entries});
  final List<dynamic> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    'Your mood journey over time',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (entries.isEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No data yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Start tracking your mood to see insights',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Text(
                  'Chart visualization would go here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF43e97b).withValues(alpha: 0.1),
            const Color(0xFF38f9d7).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF43e97b).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43e97b).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Wellness Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _TipItem(
            icon: Icons.trending_up_rounded,
            title: 'Consistent Tracking',
            description:
                'Keep daily check-ins to build clear patterns and identify trends early.',
          ),
          const SizedBox(height: 16),
          const _TipItem(
            icon: Icons.edit_note_rounded,
            title: 'Journal Reflection',
            description:
                'Pair assessments with brief journal entries for better context and insights.',
          ),
          const SizedBox(height: 16),
          const _TipItem(
            icon: Icons.support_agent_rounded,
            title: 'Professional Support',
            description:
                'If scores consistently show higher severity, consider seeking professional help.',
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF43e97b).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF43e97b), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MotivationalCard extends StatelessWidget {
  const _MotivationalCard();

  @override
  Widget build(BuildContext context) {
    const quotes = [
      "Every step forward is progress, no matter how small.",
      "Your mental health journey is unique and valid.",
      "Small consistent actions lead to big transformations.",
      "You are stronger than you know, and braver than you believe.",
    ];

    final randomQuote = quotes[DateTime.now().day % quotes.length];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFf093fb).withValues(alpha: 0.1),
            const Color(0xFFf5576c).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFf093fb).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFf093fb).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Daily Inspiration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            randomQuote,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
