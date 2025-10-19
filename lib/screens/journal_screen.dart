import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../state/app_state.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(journalProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFf093fb).withValues(alpha: 0.1),
              const Color(0xFFf5576c).withValues(alpha: 0.05),
              const Color(0xFF4facfe).withValues(alpha: 0.1),
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
                                const Color(0xFFf093fb).withValues(alpha: 0.2),
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
                                const Color(0xFF4facfe).withValues(alpha: 0.2),
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
                            Row(
                              children: [
                                Image.asset(
                                  'assets/logo_v2.png',
                                  height: 40,
                                  width: 40,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'My Journal',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Reflect on your thoughts and feelings',
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Add Entry Section
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
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
                                  colors: [
                                    Color(0xFFf093fb),
                                    Color(0xFFf5576c),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.edit_note_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'How are you feeling?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          minLines: 3,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText:
                                'Write about your day, thoughts, or feelings...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFf093fb),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFf093fb),
                                    Color(0xFFf5576c),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFf093fb,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final text = _controller.text.trim();
                                  if (text.isEmpty) return;
                                  ref
                                      .read(journalProvider.notifier)
                                      .addEntry(text);
                                  _controller.clear();
                                  _focusNode.unfocus();
                                },
                                icon: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Add Entry',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Journal Entries
              if (entries.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(40),
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
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            'assets/illustrations/empty_journal.svg',
                            width: 180,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Start Your Journey',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Begin documenting your thoughts and feelings.\nEvery entry helps you understand yourself better.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entry = entries[index];
                      final color = entry.sentimentScore >= 1
                          ? const Color(0xFF43e97b)
                          : entry.sentimentScore <= -1
                          ? const Color(0xFFf5576c)
                          : const Color(0xFF667eea);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
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
                          border: Border.all(
                            color: color.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.1),
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
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getSentimentIcon(
                                      entry.sentimentScore.toDouble(),
                                    ),
                                    color: color,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _formatDate(entry.timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    entry.sentimentScore.toString(),
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              entry.text,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade800,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }, childCount: entries.length),
                  ),
                ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSentimentIcon(double score) {
    if (score >= 1.0) return Icons.sentiment_very_satisfied_rounded;
    if (score <= -1.0) return Icons.sentiment_very_dissatisfied_rounded;
    return Icons.sentiment_neutral_rounded;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
