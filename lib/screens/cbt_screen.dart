
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CbtScreen extends StatefulWidget {
  const CbtScreen({super.key});

  @override
  State<CbtScreen> createState() => _CbtScreenState();
}

class _CbtScreenState extends State<CbtScreen> {
  // Stats removed as per request

  @override
  Widget build(BuildContext context) {
    // Defined with both Light and Dark mode palettes
    final exercises = <_Exercise>[
      _Exercise(
        title: 'Box Breathing (4-4-4-4)',
        icon: Icons.crop_square_rounded,
        minutes: 2,
        tags: const ['calming', 'anxiety'],
        videoUrl: 'https://www.youtube.com/watch?v=tEmt1Znux58',
        description:
            'Learn the 4-4-4-4 box breathing technique through guided video instruction to reduce anxiety and promote calm.',
        // Light: Soft Green
        lightGradient: const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        lightAccent: const Color(0xFF43A047),
        // Dark: Deep Emerald
        darkGradient: const [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        darkAccent: const Color(0xFF81C784),
      ),
      _Exercise(
        title: '5-4-3-2-1 Grounding',
        icon: Icons.center_focus_strong_rounded,
        minutes: 3,
        tags: const ['grounding', 'panic'],
        videoUrl: 'https://www.youtube.com/watch?v=30VMIEmA114',
        description:
            'Follow along with this grounding exercise video to reconnect with your senses and reduce panic symptoms.',
        // Light: Warm Orange
        lightGradient: const [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
        lightAccent: const Color(0xFFFB8C00),
        // Dark: Burnt Sienna
        darkGradient: const [Color(0xFFE65100), Color(0xFFEF6C00)],
        darkAccent: const Color(0xFFFFB74D),
      ),
      _Exercise(
        title: 'Thought Reframing',
        icon: Icons.psychology_alt_rounded,
        minutes: 4,
        tags: const ['cognition', 'reframing'],
        videoUrl: 'https://www.youtube.com/watch?v=0_6164n6z3A',
        description:
            'Watch this guided session on identifying and reframing negative thought patterns using CBT techniques.',
        // Light: Calm Blue
        lightGradient: const [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        lightAccent: const Color(0xFF1E88E5),
        // Dark: Midnight Blue
        darkGradient: const [Color(0xFF0D47A1), Color(0xFF1565C0)],
        darkAccent: const Color(0xFF64B5F6),
      ),
      _Exercise(
        title: 'Progressive Muscle Relaxation',
        icon: Icons.self_improvement_rounded,
        minutes: 5,
        tags: const ['tension release', 'sleep'],
        videoUrl: 'https://www.youtube.com/watch?v=SNqHG81GbeM',
        description:
            'Experience deep relaxation with this guided progressive muscle relaxation video session.',
        // Light: Gentle Purple
        lightGradient: const [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
        lightAccent: const Color(0xFF8E24AA),
        // Dark: Deep Aubergine
        darkGradient: const [Color(0xFF4A148C), Color(0xFF6A1B9A)],
        darkAccent: const Color(0xFFBA68C8),
      ),
      _Exercise(
        title: 'Values-Aligned Action',
        icon: Icons.flag_rounded,
        minutes: 2,
        tags: const ['motivation', 'values'],
        videoUrl: 'https://www.youtube.com/watch?v=T-lRbuy4XtA',
        description:
            'Discover how to align your daily actions with your core values through this motivational video guide.',
        // Light: Soft Red/Pink
        lightGradient: const [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
        lightAccent: const Color(0xFFE53935),
        // Dark: Rich Maroon
        darkGradient: const [Color(0xFFB71C1C), Color(0xFFC62828)],
        darkAccent: const Color(0xFFE57373),
      ),
      _Exercise(
        title: 'Worry Time (Containment)',
        icon: Icons.schedule_rounded,
        minutes: 3,
        tags: const ['anxiety', 'boundaries'],
        videoUrl: 'https://www.youtube.com/watch?v=P_6vDLq64gE',
        description:
            'Learn the worry time technique through video instruction to better manage anxiety and set mental boundaries.',
        // Light: Cyan/Teal
        lightGradient: const [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
        lightAccent: const Color(0xFF00ACC1),
        // Dark: Deep Teal
        darkGradient: const [Color(0xFF006064), Color(0xFF00838F)],
        darkAccent: const Color(0xFF4DD0E1),
      ),
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            expandedHeight: 120, // Reduced height since stats are gone
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).maybePop();
                } else {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                'CBT Sessions',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1A1A2E), // Dark Navy
                            const Color(0xFF16213E),
                          ]
                        : [
                            const Color(0xFFE3F2FD), // Light Blue
                            const Color(0xFFF3E5F5), // Light Lavender
                          ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final e = exercises[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ExerciseCard(exercise: e),
                  );
                },
                childCount: exercises.length,
              ),
            ),
          ),
        ],
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
    required this.lightGradient,
    required this.lightAccent,
    required this.darkGradient,
    required this.darkAccent,
  });
  final String title;
  final IconData icon;
  final int minutes;
  final List<String> tags;
  final String videoUrl;
  final String description;
  final List<Color> lightGradient;
  final Color lightAccent;
  final List<Color> darkGradient;
  final Color darkAccent;
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

  Future<void> _openModal(BuildContext context, Color accentColor) async {
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VideoSessionModal(
        title: widget.exercise.title,
        videoUrl: widget.exercise.videoUrl,
        description: widget.exercise.description,
        accentColor: accentColor,
      ),
    );
    // Refresh stats when coming back - Removed stats refresh call
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gradient = isDark ? e.darkGradient : e.lightGradient;
    final accentColor = isDark ? e.darkAccent : e.lightAccent;
    final cardColor = isDark ? const Color(0xFF252A41) : Colors.white; // Nicer Dark Card Color
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? gradient // Use the full rich gradient in dark mode for pop
            : [Colors.white, Colors.white], // Keep white cards in light mode
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : accentColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: isDark 
          ? Border.all(color: Colors.white.withOpacity(0.05))
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(e.icon, color: isDark ? Colors.white : accentColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF2D3436),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 14, color: subTextColor),
                              const SizedBox(width: 4),
                              Text(
                                '${e.minutes} min',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (_favorite)
                                Icon(Icons.favorite, size: 14, color: Colors.red[400]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: subTextColor,
                      ),
                      onPressed: () => setState(() => _expanded = !_expanded),
                    ),
                  ],
                ),
                
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: _expanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Divider(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
                            const SizedBox(height: 16),
                            Text(
                              e.description,
                              style: TextStyle(
                                color: subTextColor,
                                height: 1.5,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _openModal(context, accentColor),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Start Session'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? Colors.white : accentColor,
                                  foregroundColor: isDark ? accentColor : Colors.white, // Invert for pop
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
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
    required this.accentColor,
  });

  final String title;
  final String videoUrl;
  final String description;
  final Color accentColor;

  Future<void> _launchPlayer(BuildContext context) async {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;

    if (videoId != null && !isDesktop) {
      // Close modal first
      Navigator.of(context).pop();
      // Navigate to player
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _VideoPlayerScreen(
            videoId: videoId,
            title: title,
            description: description,
          ),
        ),
      );
    } else {
      // Fallback
      final uri = Uri.parse(videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_circle_filled_rounded, color: accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Video Player Placeholder / Thumbnail
          InkWell(
            onTap: () => _launchPlayer(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // Decorative gradient
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accentColor.withOpacity(0.6),
                          accentColor.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  
                  // Play Button
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 40,
                      color: accentColor,
                    ),
                  ),
                  
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Tap to Start',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Description
          Text(
            'Session Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              height: 1.6,
              fontSize: 15,
            ),
          ),

          const Spacer(),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('Save for Later', style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[800])),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _launchPlayer(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Play Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String description;

  const _VideoPlayerScreen({
    required this.videoId,
    required this.title,
    required this.description,
  });

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true, // Auto-play only after user has clicked 'Play' in the modal
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black, // Cinematic feel
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: Colors.white),
            title: Text(widget.title, style: const TextStyle(color: Colors.white)),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  player,
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fallback
                        Center(
                          child: TextButton.icon(
                            onPressed: () async {
                              final url = 'https://www.youtube.com/watch?v=${widget.videoId}';
                              final uri = Uri.parse(url);
                               if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                            },
                            icon: const Icon(Icons.open_in_new_rounded, size: 16),
                            label: const Text('Issues? Open in App'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white54,
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.description,
                          style: const TextStyle(
                             color: Colors.white70,
                             height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
