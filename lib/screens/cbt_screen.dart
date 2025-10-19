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
        steps: const [
          'Inhale through the nose for 4 seconds',
          'Hold gently for 4 seconds',
          'Exhale through the mouth for 4 seconds',
          'Hold with lungs empty for 4 seconds',
          'Repeat 4–6 cycles',
        ],
        gradient: const [Color(0xFFB3C7FF), Color(0xFF5B8CFF)],
      ),
      _Exercise(
        title: '5-4-3-2-1 Grounding',
        icon: Icons.center_focus_strong_rounded,
        minutes: 3,
        tags: const ['grounding', 'panic'],
        steps: const [
          'Name 5 things you can see',
          'Notice 4 things you can feel',
          'Listen for 3 things you can hear',
          'Identify 2 things you can smell',
          'Savor 1 thing you can taste',
        ],
        gradient: const [Color(0xFFA8E0FF), Color(0xFF6BCBFF)],
      ),
      _Exercise(
        title: 'Thought Reframing',
        icon: Icons.psychology_alt_rounded,
        minutes: 4,
        tags: const ['cognition', 'reframing'],
        steps: const [
          'Notice the automatic thought',
          'Name the distortion (e.g., all-or-nothing, mind reading)',
          'Find a balanced, specific alternative',
        ],
        gradient: const [Color(0xFFFFCFDF), Color(0xFFB0F3F1)],
      ),
      _Exercise(
        title: 'Progressive Muscle Relaxation',
        icon: Icons.self_improvement_rounded,
        minutes: 5,
        tags: const ['tension release', 'sleep'],
        steps: const [
          'From toes to head, tense each muscle group for ~5 seconds',
          'Release for ~10 seconds and notice the contrast',
          'Move slowly up the body until the face/scalp',
        ],
        gradient: const [Color(0xFFC3F8FF), Color(0xFFB9FFDF)],
      ),
      _Exercise(
        title: 'Values-Aligned Action (Tiny Step)',
        icon: Icons.flag_rounded,
        minutes: 2,
        tags: const ['motivation', 'values'],
        steps: const [
          'Pick one value (e.g., kindness, learning, health)',
          'Define a 2-minute action that expresses it',
          'Schedule or do it now; notice how it feels',
        ],
        gradient: const [Color(0xFFFFE7A0), Color(0xFFFFC6A8)],
      ),
      _Exercise(
        title: 'Worry Time (Containment)',
        icon: Icons.schedule_rounded,
        minutes: 3,
        tags: const ['anxiety', 'boundaries'],
        steps: const [
          'Note the worry and park it on paper',
          'Set a 10–15 min “worry time” later today',
          'Return attention to the present task',
        ],
        gradient: const [Color(0xFFDAD4FF), Color(0xFFB8B1FF)],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CBT Micro-exercises'),
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
    required this.steps,
    required this.gradient,
  });
  final String title;
  final IconData icon;
  final int minutes;
  final List<String> tags;
  final List<String> steps;
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
    if (mounted)
      setState(() => _favorite = favs.contains(widget.exercise.title));
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
                    child: Icon(e.icon, color: scheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${e.minutes} min',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
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
                    color: _favorite ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
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
                          for (final s in e.steps)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(child: Text(s)),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              const Spacer(),
                              FilledButton.icon(
                                onPressed: () => _openGuide(context, e),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Start'),
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

  void _openGuide(BuildContext context, _Exercise e) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _ExerciseGuide(exercise: e),
    );
  }
}

class _ExerciseGuide extends StatefulWidget {
  const _ExerciseGuide({required this.exercise});
  final _Exercise exercise;
  @override
  State<_ExerciseGuide> createState() => _ExerciseGuideState();
}

class _ExerciseGuideState extends State<_ExerciseGuide> {
  int _index = 0;
  int _seconds = 0;
  bool _running = false;
  late final List<String> _steps = widget.exercise.steps;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer([int seconds = 0]) {
    _timer?.cancel();
    setState(() {
      _seconds = seconds;
      _running = seconds > 0;
    });
    if (seconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) {
        t.cancel();
        setState(() {
          _seconds = 0;
          _running = false;
        });
        HapticFeedback.mediumImpact();
      } else {
        setState(() => _seconds -= 1);
      }
    });
  }

  int _inferSeconds(String step) {
    final match = RegExp(r'(\d{1,2})\s*(sec|second|seconds)?').firstMatch(step);
    if (match == null) return 0;
    return int.tryParse(match.group(1)!) ?? 0;
  }

  void _next() {
    if (_index < _steps.length - 1) {
      setState(() => _index += 1);
      HapticFeedback.selectionClick();
      final secs = _inferSeconds(_steps[_index]);
      if (secs > 0) _startTimer(secs);
    } else {
      _recordCompletion();
      SystemSound.play(SystemSoundType.click);
      Navigator.of(context).maybePop();
    }
  }

  void _prev() {
    if (_index == 0) return;
    setState(() => _index -= 1);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final step = _steps[_index];
    final secsHint = _inferSeconds(step);
    final mode = step.toLowerCase().contains('inhale')
        ? 'inhale'
        : step.toLowerCase().contains('exhale')
        ? 'exhale'
        : step.toLowerCase().contains('hold')
        ? 'hold'
        : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.exercise.icon, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.exercise.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${_index + 1}/${_steps.length}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(step, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          if (mode != null)
            _BreathingVisual(
              mode: mode,
              seconds: _running ? _seconds : (secsHint > 0 ? secsHint : 4),
            ),
          if (mode != null) const SizedBox(height: 12),
          if (_running || _inferSeconds(step) > 0)
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _running
                      ? null
                      : () => _startTimer(_inferSeconds(step).clamp(1, 60)),
                  icon: const Icon(Icons.timer),
                  label: Text(_running ? '$_seconds s' : 'Start timer'),
                ),
                const SizedBox(width: 8),
                if (_running)
                  OutlinedButton(
                    onPressed: () => _startTimer(0),
                    child: const Text('Cancel'),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _index == 0 ? null : _prev,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Back'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _next,
                icon: Icon(
                  _index == _steps.length - 1
                      ? Icons.check
                      : Icons.chevron_right,
                ),
                label: Text(_index == _steps.length - 1 ? 'Done' : 'Next'),
              ),
            ],
          ),
        ],
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

class _BreathingVisual extends StatefulWidget {
  const _BreathingVisual({required this.mode, required this.seconds});
  final String mode; // inhale | exhale | hold
  final int seconds;
  @override
  State<_BreathingVisual> createState() => _BreathingVisualState();
}

class _BreathingVisualState extends State<_BreathingVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds > 0 ? widget.seconds : 4),
    )..repeat(reverse: widget.mode != 'hold');
  }

  @override
  void didUpdateWidget(covariant _BreathingVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seconds != widget.seconds || oldWidget.mode != widget.mode) {
      _controller.duration = Duration(
        seconds: widget.seconds > 0 ? widget.seconds : 4,
      );
      if (widget.mode == 'hold') {
        _controller.stop();
      } else if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 120,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final scale = widget.mode == 'hold'
                ? 1.0
                : (0.8 + 0.4 * _controller.value);
            final label =
                widget.mode[0].toUpperCase() + widget.mode.substring(1);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withValues(alpha: 0.2),
                      border: Border.all(color: scheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$label ${widget.seconds > 0 ? '· ${widget.seconds}s' : ''}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
