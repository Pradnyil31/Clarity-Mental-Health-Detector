import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/user_state.dart';
import '../state/notification_state.dart';
import '../models/notification_settings.dart';
import '../widgets/notification_status_widget.dart';
import '../widgets/cards/action_card.dart';
import '../widgets/cards/wide_feature_card.dart';
import '../widgets/cards/compact_tool_card.dart';
import '../widgets/cards/assessment_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive_utils.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userState = ref.watch(userStateProvider);
    final displayName = userState.profile?.displayName ?? 'Friend';

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header
            Container(
              padding: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                      : [const Color(0xFF667eea), const Color(0xFF764ba2)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF764ba2).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Morning,',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.of(context).pushNamed('/profile'),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              child: userState.profile?.avatarId != null &&
                                     userState.profile!.avatarId!.isNotEmpty
                                  ? Text(
                                      userState.profile!.avatarId!,
                                      style: const TextStyle(fontSize: 24),
                                    )
                                  : Text(
                                      displayName.characters.first.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Streak Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.orangeAccent,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '3 Day Streak',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 1,
                              height: 20,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Keep it up!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Body
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assessments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        AssessmentCard(
                          title: 'Depression\nTest (PHQ-9)',
                          subtitle: '9 Questions',
                          color: AppColors.phq9,
                          icon: Icons.mood_bad_rounded,
                          onTap: () => Navigator.pushNamed(context, '/phq9'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AssessmentCard(
                          title: 'Anxiety\nTest (GAD-7)',
                          subtitle: '7 Questions',
                          color: AppColors.gad7,
                          icon: Icons.psychology_rounded,
                          onTap: () => Navigator.pushNamed(context, '/gad7'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AssessmentCard(
                          title: 'Happiness\nScale',
                          subtitle: 'Subjective',
                          color: AppColors.happiness,
                          icon: Icons.sentiment_very_satisfied_rounded,
                          onTap: () =>
                              Navigator.pushNamed(context, '/happiness'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AssessmentCard(
                          title: 'Self-Esteem\nCheck',
                          subtitle: 'Rosenberg',
                          color: AppColors.selfEsteem,
                          icon: Icons.person_rounded,
                          onTap: () =>
                              Navigator.pushNamed(context, '/self-esteem'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AssessmentCard(
                          title: 'Stress Check\n(PSS-10)',
                          subtitle: '10 Questions',
                          color: AppColors.pss10,
                          icon: Icons.thunderstorm_rounded,
                          onTap: () => Navigator.pushNamed(context, '/pss10'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AssessmentCard(
                          title: 'Sleep\nQuality',
                          subtitle: '7 Questions',
                          color: AppColors.sleep,
                          icon: Icons.bedtime_rounded,
                          onTap: () => Navigator.pushNamed(context, '/sleep'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'For You',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Featured Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: ActionCard(
                          title: 'Mood Check',
                          subtitle: 'How are you?',
                          icon: Icons.mood_rounded,
                          color: AppColors.moodTracking,
                          onTap: () => Navigator.of(context).pushNamed('/mood'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ActionCard(
                          title: 'Panic Relief',
                          subtitle: 'Breathe',
                          icon: Icons.air_rounded,
                          color: AppColors.panicRelief,
                          onTap: () =>
                              Navigator.of(context).pushNamed('/breathing'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Featured Assessment (Safety Plan or PHQ9)
                  WideFeatureCard(
                    title: 'Crisis Safety Plan',
                    subtitle: 'Be prepared for difficult moments',
                    icon: Icons.health_and_safety_rounded,
                    color: AppColors.safetyPlan,
                    onTap: () =>
                        Navigator.of(context).pushNamed('/safety-plan'),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Tools',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      CompactToolCard(
                        title: 'Journal',
                        icon: Icons.edit_note_rounded,
                        color: AppColors.journaling,
                        onTap: () =>
                            Navigator.of(context).pushNamed('/journal'),
                      ),
                      CompactToolCard(
                        title: 'Log Activity',
                        icon: Icons.directions_run_rounded,
                        color: AppColors.exercise,
                        onTap: () =>
                            Navigator.of(context).pushNamed('/exercise'),
                      ),
                      CompactToolCard(
                        title: 'Insights',
                        icon: Icons.insights_rounded,
                        color: AppColors.insights,
                        onTap: () =>
                            Navigator.of(context).pushNamed('/insights'),
                      ),
                      CompactToolCard(
                        title: 'CBT',
                        icon: Icons.psychology_rounded,
                        color: AppColors.cbt,
                        onTap: () => Navigator.of(context).pushNamed('/cbt'),
                      ),
                      CompactToolCard(
                        title: 'To-Do List',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.todo,
                        onTap: () => Navigator.of(context).pushNamed('/todo'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Inline widget classes have been moved to lib/widgets/cards/
// ActionCard -> lib/widgets/cards/action_card.dart
// WideFeatureCard -> lib/widgets/cards/wide_feature_card.dart
// CompactToolCard -> lib/widgets/cards/compact_tool_card.dart
// AssessmentCard -> lib/widgets/cards/assessment_card.dart
