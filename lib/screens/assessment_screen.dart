import 'dart:convert';
import 'assessment_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assessment.dart';
import '../state/mood_state.dart';
import '../state/assessment_state.dart';

import '../state/user_state.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key, required this.kind, this.returnResult = false});
  final AssessmentKind kind;
  final bool returnResult;

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen>
    with TickerProviderStateMixin {
  late Future<List<AssessmentQuestion>> _questionsFuture;
  late List<int?> _answers;
  late PageController _pageController;
  int _currentQuestionIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions();
    _pageController = PageController();

    _isInitialized = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<AssessmentQuestion>> _loadQuestions() async {
    final data = await rootBundle.loadString(widget.kind.assetPath);
    final list = (json.decode(data) as List)
        .map((e) => AssessmentQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    _answers = List<int?>.filled(list.length, null);
    return list;
  }

  bool _isSubmitting = false;

  void _nextQuestion() {
    if (_isSubmitting) return;
    
    if (_currentQuestionIndex < _answers.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitAssessment();
    }
  }

  void _previousQuestion() {
    if (_isSubmitting) return;

    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                    const Color(0xFF533A7B),
                  ]
                : [
                    const Color(0xFFE3F2FD),
                    const Color(0xFFBBDEFB),
                    const Color(0xFF90CAF9),
                    const Color(0xFF64B5F6),
                  ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<AssessmentQuestion>>(
            future: _questionsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return _buildLoadingState(scheme);
              }
              final questions = snapshot.data!;
              return PopScope(
                // Allow popping if on first question OR if we are submitting (finished)
                canPop: _currentQuestionIndex == 0 || _isSubmitting,
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop || _isSubmitting) return;
                  // If we didn't pop (meaning index > 0), go to previous question
                  _previousQuestion();
                },
                child: Column(
                  children: [
                    _buildHeader(scheme, questions.length),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _currentQuestionIndex = index;
                          });
                        },
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          return _buildQuestionCard(
                            context,
                            scheme,
                            questions[index],
                            index,
                            questions.length,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: scheme.primary, strokeWidth: 3),
          const SizedBox(height: 24),
          Text(
            'Loading assessment...',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme scheme, int totalQuestions) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Back button and title
          Row(
            children: [
              IconButton(
                onPressed: _previousQuestion,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: scheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.kind.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Take a moment to reflect on your experiences',
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress indicator
          _isInitialized
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${((_currentQuestionIndex + 1) / totalQuestions * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (_currentQuestionIndex + 1) / totalQuestions,
                          backgroundColor: Colors.white.withValues(
                            alpha: 0.3,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF667eea),
                          ),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  )
                : Container(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    ColorScheme scheme,
    AssessmentQuestion question,
    int index,
    int totalQuestions,
  ) {
    final isAnswered = _answers[index] != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colorful gradients for each question
    final cardColors = [
      [
        const Color(0xFFFF6B6B),
        const Color(0xFFFF8E8E),
        const Color(0xFFFFB3B3),
      ],
      [
        const Color(0xFF4ECDC4),
        const Color(0xFF7EDDD6),
        const Color(0xFFA8E6E0),
      ],
      [
        const Color(0xFF45B7D1),
        const Color(0xFF6BC5D1),
        const Color(0xFF8DD3E0),
      ],
      [
        const Color(0xFF96CEB4),
        const Color(0xFFA8D5BA),
        const Color(0xFFB8DCC6),
      ],
      [
        const Color(0xFFFECA57),
        const Color(0xFFFFD93D),
        const Color(0xFFFFE066),
      ],
      [
        const Color(0xFFFF9FF3),
        const Color(0xFFFFB3F5),
        const Color(0xFFFFC7F7),
      ],
      [
        const Color(0xFF54A0FF),
        const Color(0xFF74B9FF),
        const Color(0xFF94C9FF),
      ],
      [
        const Color(0xFF5F27CD),
        const Color(0xFF7B4CDF),
        const Color(0xFF9771F0),
      ],
      [
        const Color(0xFF00D2D3),
        const Color(0xFF26E0E1),
        const Color(0xFF4CEEEF),
      ],
    ];

    final questionColors = cardColors[index % cardColors.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: isAnswered ? 8 : 2,
        shadowColor: isAnswered
            ? questionColors[0].withValues(alpha: 0.3)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isAnswered
                ? questionColors[0].withValues(alpha: 0.6)
                : isDark
                ? scheme.outline.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.2),
            width: isAnswered ? 3 : 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isAnswered
                  ? [
                      questionColors[0].withValues(alpha: 0.9),
                      questionColors[1].withValues(alpha: 0.7),
                      questionColors[2].withValues(alpha: 0.5),
                    ]
                  : isDark
                  ? [
                      scheme.surface.withValues(alpha: 0.9),
                      scheme.surface.withValues(alpha: 0.7),
                      scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.7),
                      Colors.white.withValues(alpha: 0.5),
                    ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question number and text
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isAnswered
                              ? [questionColors[0], questionColors[1]]
                              : isDark
                              ? [
                                  scheme.surfaceContainerHighest,
                                  scheme.outline.withValues(alpha: 0.6),
                                ]
                              : [Colors.grey.shade300, Colors.grey.shade400],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isAnswered
                            ? [
                                BoxShadow(
                                  color: questionColors[0].withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isAnswered
                                ? Colors.white
                                : isDark
                                ? scheme.onSurface
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        question.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                          height: 1.4,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Answer options
                Column(
                  children: question.options.asMap().entries.map((entry) {
                    final optionIndex = entry.key;
                    final option = entry.value;
                    final isSelected =
                        _answers[index] == question.weights[optionIndex];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _answers[index] = question.weights[optionIndex];
                          });
                          Future.delayed(
                            const Duration(milliseconds: 150),
                            _nextQuestion,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      questionColors[0],
                                      questionColors[1],
                                    ],
                                  )
                                : isDark
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      scheme.surfaceContainerHighest.withValues(
                                        alpha: 0.8,
                                      ),
                                      scheme.surfaceContainerHighest.withValues(
                                        alpha: 0.6,
                                      ),
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.8),
                                      Colors.grey.shade100,
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? questionColors[0].withValues(alpha: 0.8)
                                  : isDark
                                  ? scheme.outline.withValues(alpha: 0.4)
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: questionColors[0].withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withValues(alpha: 0.2)
                                          : Colors.grey.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Text(
                            option,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isDark
                                  ? scheme.onSurface
                                  : Colors.grey.shade700,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (index > 0) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: _previousQuestion,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                      label: Text(
                        'Previous Question',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _submitAssessment() async {
    if (_isSubmitting) return;
    
    // Update state first
    setState(() {
      _isSubmitting = true;
    });

    final answers = _answers.cast<int>();
    final result = AssessmentScoring.score(widget.kind, answers);
    final userId = ref.read(currentUserIdProvider);

    // Perform database operations
    try {
      if (userId != null) {
        await ref
            .read(assessmentStateProvider.notifier)
            .addAssessmentResult(result);
      }

      await ref.read(moodTrackerProvider.notifier).recordToday(
        result.normalizedScore,
        factors: ['Assessment'],
      );
    } catch (e) {
      debugPrint('Error saving assessment result: $e');
    }

    if (mounted) {
      if (widget.returnResult) {
        Navigator.of(context).pop(result);
      } else {
        // Use popAndPushNamed or pushReplacement. 
        // We use pushReplacement to ensure the current screen is removed.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AssessmentResultScreen(result: result),
          ),
        );
      }
    }
  }

}
