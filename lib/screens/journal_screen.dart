import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _animationController;
  late AnimationController _fabController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fabAnimation;
  late Animation<double> _pulseAnimation;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _isInitialized = true;

    _animationController.forward();
    _fabController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _fabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(journalProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.1),
              scheme.secondaryContainer.withValues(alpha: 0.05),
              scheme.tertiaryContainer.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Beautiful Header
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.only(left: 16, top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        // If can't pop, navigate to home
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/', (route) => false);
                      }
                    },
                  ),
                ),

                flexibleSpace: FlexibleSpaceBar(
                  title: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'My Journal',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary.withValues(alpha: 0.1),
                          scheme.secondary.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Quick Stats Card
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildStatsCard(entries, scheme),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Journal Entries
              if (entries.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildEmptyState(scheme),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entry = entries[index];
                      return AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              _slideAnimation.value * (index + 1) * 0.1,
                            ),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildJournalEntry(entry, scheme, index),
                            ),
                          );
                        },
                      );
                    }, childCount: entries.length),
                  ),
                ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: _isInitialized
          ? AnimatedBuilder(
              animation: Listenable.merge([_fabAnimation, _pulseAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimation.value * _pulseAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF667eea),
                          Color(0xFF764ba2),
                          Color(0xFFf093fb),
                          Color(0xFFf5576c),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withValues(alpha: 0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: const Color(0xFFf093fb).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Add a small scale animation on tap
                          _fabController.reverse().then((_) {
                            _fabController.forward();
                          });
                          _showWriteDialog(scheme);
                        },
                        borderRadius: BorderRadius.circular(32),
                        splashColor: Colors.white.withValues(alpha: 0.2),
                        highlightColor: Colors.white.withValues(alpha: 0.1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 18,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.auto_stories_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Write Entry',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  Text(
                                    'Capture your thoughts',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          : null,
      floatingActionButtonLocation: const _CustomFabLocation(),
    );
  }

  Widget _buildStatsCard(List<JournalEntry> entries, ColorScheme scheme) {
    final today = DateTime.now();
    final thisWeek = entries
        .where((e) => today.difference(e.timestamp).inDays < 7)
        .length;
    final totalWords = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.text.split(' ').length,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.book_outlined,
              label: 'Total Entries',
              value: '${entries.length}',
              scheme: scheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: scheme.onPrimaryContainer.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.calendar_today_outlined,
              label: 'This Week',
              value: '$thisWeek',
              scheme: scheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: scheme.onPrimaryContainer.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.text_fields_outlined,
              label: 'Total Words',
              value: '$totalWords',
              scheme: scheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme scheme,
  }) {
    return Column(
      children: [
        Icon(icon, color: scheme.onPrimaryContainer, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: scheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.secondaryContainer,
                  scheme.secondaryContainer.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: scheme.secondary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.auto_stories_outlined,
              size: 60,
              color: scheme.secondary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Start Your Journey',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? scheme.onSurface.withValues(alpha: 0.95)
                  : scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Capture your thoughts, feelings, and experiences. Your journal is a safe space for reflection and growth.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? scheme.onSurface.withValues(alpha: 0.85)
                  : scheme.onSurface.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
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
                      'Writing Tips',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? scheme.onSurface.withValues(alpha: 0.95)
                            : scheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTipItem(
                  '✨',
                  'Write about your daily experiences',
                  scheme,
                ),
                _buildTipItem(
                  '💭',
                  'Express your thoughts and feelings',
                  scheme,
                ),
                _buildTipItem(
                  '🎯',
                  'Set goals and track your progress',
                  scheme,
                ),
                _buildTipItem(
                  '🙏',
                  'Practice gratitude and mindfulness',
                  scheme,
                ),
              ],
            ),
          ),
        ],
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? scheme.onSurface.withValues(alpha: 0.9)
                    : scheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalEntry(JournalEntry entry, ColorScheme scheme, int index) {
    final isEven = index % 2 == 0;
    final sentimentColor = _getSentimentColor(
      entry.sentimentScore.toDouble(),
      scheme,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEntryDetails(entry, scheme),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEven
                    ? [
                        scheme.surfaceContainerHighest,
                        scheme.surfaceContainerHigh,
                      ]
                    : [
                        scheme.surfaceContainerHigh,
                        scheme.surfaceContainerHighest,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sentimentColor.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 10,
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: sentimentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getSentimentIcon(entry.sentimentScore.toDouble()),
                        color: sentimentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(entry.timestamp),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? scheme.onSurface.withValues(alpha: 0.95)
                                  : scheme.onSurface,
                            ),
                          ),
                          Text(
                            _formatTime(entry.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? scheme.onSurface.withValues(alpha: 0.75)
                                  : scheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: scheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  entry.text.length > 150
                      ? '${entry.text.substring(0, 150)}...'
                      : entry.text,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? scheme.onSurface.withValues(alpha: 0.9)
                        : scheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: sentimentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getSentimentLabel(entry.sentimentScore.toDouble()),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: sentimentColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${entry.text.split(' ').length} words',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? scheme.onSurface.withValues(alpha: 0.65)
                            : scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatFullDate(DateTime date) {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
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
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getSentimentColor(double score, ColorScheme scheme) {
    if (score > 0.3) return const Color(0xFF4CAF50); // Positive - Green
    if (score < -0.3) return const Color(0xFFF44336); // Negative - Red
    return scheme.primary; // Neutral - Primary color
  }

  IconData _getSentimentIcon(double score) {
    if (score > 0.3) return Icons.sentiment_very_satisfied;
    if (score > 0.1) return Icons.sentiment_satisfied;
    if (score < -0.3) return Icons.sentiment_very_dissatisfied;
    if (score < -0.1) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_neutral;
  }

  String _getSentimentLabel(double score) {
    if (score > 0.3) return 'Very Positive';
    if (score > 0.1) return 'Positive';
    if (score < -0.3) return 'Very Negative';
    if (score < -0.1) return 'Negative';
    return 'Neutral';
  }

  void _showEntryDetails(JournalEntry entry, ColorScheme scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EntryDetailsSheet(entry: entry),
    );
  }

  void _showWriteDialog(ColorScheme scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WriteEntrySheet(
        onSave: (text) {
          ref.read(journalProvider.notifier).addEntry(text);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Journal entry saved!'),
              backgroundColor: scheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}

class _EntryDetailsSheet extends StatelessWidget {
  final JournalEntry entry;

  const _EntryDetailsSheet({required this.entry});

  static String _formatFullDate(DateTime date) {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
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
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(bottom: 24),
          ),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: scheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _formatFullDate(entry.timestamp),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? scheme.onSurface.withValues(alpha: 0.95)
                      : scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(entry.timestamp),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? scheme.onSurface.withValues(alpha: 0.75)
                  : scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              entry.text,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Theme.of(context).brightness == Brightness.dark
                    ? scheme.onSurface.withValues(alpha: 0.95)
                    : scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${entry.text.split(' ').length} words',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? scheme.onSurface.withValues(alpha: 0.75)
                      : scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

class _WriteEntrySheet extends StatefulWidget {
  final Function(String) onSave;

  const _WriteEntrySheet({required this.onSave});

  @override
  State<_WriteEntrySheet> createState() => _WriteEntrySheetState();
}

class _WriteEntrySheetState extends State<_WriteEntrySheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  static String _formatFullDate(DateTime date) {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
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
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(bottom: 24),
          ),
          Row(
            children: [
              Icon(Icons.edit_outlined, color: scheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'New Journal Entry',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? scheme.onSurface.withValues(alpha: 0.95)
                      : scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatFullDate(DateTime.now()),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? scheme.onSurface.withValues(alpha: 0.75)
                  : scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? scheme.onSurface.withValues(alpha: 0.95)
                      : scheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText:
                      'What\'s on your mind today?\n\nShare your thoughts, feelings, experiences, or anything you\'d like to remember...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? scheme.onSurface.withValues(alpha: 0.65)
                        : scheme.onSurface.withValues(alpha: 0.5),
                    height: 1.6,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, value, child) {
                  final wordCount = value.text.trim().isEmpty
                      ? 0
                      : value.text.trim().split(' ').length;
                  return Text(
                    '$wordCount words',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? scheme.onSurface.withValues(alpha: 0.75)
                          : scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  );
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, value, child) {
                  return ElevatedButton(
                    onPressed: value.text.trim().isEmpty
                        ? null
                        : () {
                            widget.onSave(value.text.trim());
                            Navigator.of(context).pop();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Entry',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

class _CustomFabLocation extends FloatingActionButtonLocation {
  const _CustomFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Position the FAB in the center horizontally, but higher up to avoid bottom navigation
    final double fabX =
        (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2.0;
    final double fabY =
        scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        120.0; // Slightly lower position

    return Offset(fabX, fabY);
  }
}
