import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CbtScreen extends StatelessWidget {
  const CbtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = <_Exercise>[
      _Exercise(
        title: 'Box Breathing (4-4-4-4)',
        icon: Icons.crop_square_rounded,
        minutes: 2,
        tags: const ['calming', 'anxiety'],
        videoUrl: 'https://example.com/box-breathing-video',
        description:
            'Learn the 4-4-4-4 box breathing technique through guided video instruction to reduce anxiety and promote calm.',
        gradient: const [Color(0xFFB3C7FF), Color(0xFF5B8CFF)],
      ),
      _Exercise(
        title: '5-4-3-2-1 Grounding',
        icon: Icons.center_focus_strong_rounded,
        minutes: 3,
        tags: const ['grounding', 'panic'],
        videoUrl: 'https://example.com/grounding-video',
        description:
            'Follow along with this grounding exercise video to reconnect with your senses and reduce panic symptoms.',
        gradient: const [Color(0xFFA8E0FF), Color(0xFF6BCBFF)],
      ),
      _Exercise(
        title: 'Thought Reframing',
        icon: Icons.psychology_alt_rounded,
        minutes: 4,
        tags: const ['cognition', 'reframing'],
        videoUrl: 'https://example.com/thought-reframing-video',
        description:
            'Watch this guided session on identifying and reframing negative thought patterns using CBT techniques.',
        gradient: const [Color(0xFFFFCFDF), Color(0xFFB0F3F1)],
      ),
      _Exercise(
        title: 'Progressive Muscle Relaxation',
        icon: Icons.self_improvement_rounded,
        minutes: 5,
        tags: const ['tension release', 'sleep'],
        videoUrl: 'https://example.com/muscle-relaxation-video',
        description:
            'Experience deep relaxation with this guided progressive muscle relaxation video session.',
        gradient: const [Color(0xFFC3F8FF), Color(0xFFB9FFDF)],
      ),
      _Exercise(
        title: 'Values-Aligned Action (Tiny Step)',
        icon: Icons.flag_rounded,
        minutes: 2,
        tags: const ['motivation', 'values'],
        videoUrl: 'https://example.com/values-action-video',
        description:
            'Discover how to align your daily actions with your core values through this motivational video guide.',
        gradient: const [Color(0xFFFFE7A0), Color(0xFFFFC6A8)],
      ),
      _Exercise(
        title: 'Worry Time (Containment)',
        icon: Icons.schedule_rounded,
        minutes: 3,
        tags: const ['anxiety', 'boundaries'],
        videoUrl: 'https://example.com/worry-time-video',
        description:
            'Learn the worry time technique through video instruction to better manage anxiety and set mental boundaries.',
        gradient: const [Color(0xFFDAD4FF), Color(0xFFB8B1FF)],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CBT Video Sessions'),
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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final e = exercises[index];
          return _ExerciseCard(exercise: e);
        },
      ),
    );
  }
}

class _Exercise {
  _Exercise({
    required this.title,
    required this.icon,
    required this.minutes,
    required this.tags,
    required this.videoUrl,
    required this.description,
    required this.gradient,
  });
  final String title;
  final IconData icon;
  final int minutes;
  final List<String> tags;
  final String videoUrl;
  final String description;
  final List<Color> gradient;
}

class _ExerciseCard extends StatefulWidget {
  const _ExerciseCard({required this.exercise});
  final _Exercise exercise;
  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _expanded = false;
  bool _favorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('cbt_favorites') ?? <String>[];
    if (mounted) {
      setState(() => _favorite = favs.contains(widget.exercise.title));
    }
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('cbt_favorites') ?? <String>[];
    if (favs.contains(widget.exercise.title)) {
      favs.remove(widget.exercise.title);
      setState(() => _favorite = false);
    } else {
      favs.add(widget.exercise.title);
      setState(() => _favorite = true);
    }
    await prefs.setStringList('cbt_favorites', favs);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: e.gradient),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      e.icon,
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 14,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${e.minutes} min video',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Colors.black.withValues(alpha: 0.7),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: _favorite ? 'Unfavorite' : 'Favorite',
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      _favorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    color: _favorite
                        ? Colors.red.shade600
                        : Colors.black.withValues(alpha: 0.7),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in e.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: Text(
                            t,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: scheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(height: 0),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Spacer(),
                              FilledButton.icon(
                                onPressed: () =>
                                    _launchVideo(context, e.videoUrl),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Watch Video'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchVideo(BuildContext context, String videoUrl) async {
    _recordCompletion();
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _VideoSessionModal(
        title: widget.exercise.title,
        videoUrl: videoUrl,
        description: widget.exercise.description,
      ),
    );
  }
}

Future<void> _recordCompletion() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now();
  final lastStr = prefs.getString('cbt_last_done');
  int streak = prefs.getInt('cbt_streak') ?? 0;
  if (lastStr != null) {
    final last = DateTime.tryParse(lastStr);
    if (last != null) {
      final lastDate = DateTime(last.year, last.month, last.day);
      final todayDate = DateTime(today.year, today.month, today.day);
      if (todayDate.difference(lastDate).inDays == 1) {
        streak += 1;
      } else if (todayDate.difference(lastDate).inDays == 0) {
        // same day, keep streak
      } else {
        streak = 1;
      }
    } else {
      streak = 1;
    }
  } else {
    streak = 1;
  }
  await prefs.setString('cbt_last_done', today.toIso8601String());
  await prefs.setInt('cbt_streak', streak);
  await prefs.setInt(
    'cbt_total_completed',
    (prefs.getInt('cbt_total_completed') ?? 0) + 1,
  );
}

class _VideoSessionModal extends StatelessWidget {
  const _VideoSessionModal({
    required this.title,
    required this.videoUrl,
    required this.description,
  });

  final String title;
  final String videoUrl;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.play_circle_filled, color: scheme.primary, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Video Player Placeholder
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primaryContainer, scheme.secondaryContainer],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 48,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Video Session',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coming Soon',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            'About this session',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          const Spacer(),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Save for Later'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Video sessions coming soon! Stay tuned.',
                        ),
                        backgroundColor: scheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Session'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
