import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assessment.dart';
import '../state/mood_state.dart';
import '../state/assessment_state.dart';

import '../state/user_state.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key, required this.kind});
  final AssessmentKind kind;

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
                // Allow popping only if we are on the first question
                canPop: _currentQuestionIndex == 0,
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
    
    // Set submitting flag immediately to prevent multiple calls
    _isSubmitting = true;

    final answers = _answers.cast<int>();
    final result = AssessmentScoring.score(widget.kind, answers);
    final userId = ref.read(currentUserIdProvider);

    // Show dialog immediately for smooth UX
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => _buildResultDialog(ctx, result),
      ).then((_) {
        // Reset submitting flag when dialog is closed (if we want to allow re-submission or navigation)
        // Note: Usually we navigate away after this dialog, so it might not matter
      });
    }

    // Perform database operations in background
    try {
      if (userId != null) {
        await ref
            .read(assessmentStateProvider.notifier)
            .addAssessmentResult(result);
      }

      // Record mood using the normalized score from the assessment result
      await ref.read(moodTrackerProvider.notifier).recordToday(
        result.normalizedScore,
        factors: ['Assessment'],
      );
    } catch (e) {
      // If saving fails, we might want to notify user or retry silenty
      // key thing is not to block the UI transition
      debugPrint('Error saving assessment result: $e');
    } finally {
       // Optional: reset if you want to allow retry on error without closing dialog?
       // _isSubmitting = false; 
    }
  }

  Widget _buildResultDialog(BuildContext context, AssessmentResult result) {
    final scheme = Theme.of(context).colorScheme;

    Color severityColor;
    IconData severityIcon;

    if (result.normalizedScore >= 80) {
      severityColor = Colors.green;
      severityIcon = Icons.sentiment_very_satisfied_rounded;
    } else if (result.normalizedScore >= 60) {
      severityColor = Colors.lightGreen;
      severityIcon = Icons.sentiment_satisfied_rounded;
    } else if (result.normalizedScore >= 40) {
      severityColor = Colors.amber;
      severityIcon = Icons.sentiment_neutral_rounded;
    } else if (result.normalizedScore >= 20) {
      severityColor = Colors.orange;
      severityIcon = Icons.sentiment_dissatisfied_rounded;
    } else {
      severityColor = Colors.red;
      severityIcon = Icons.mood_bad_rounded;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              severityColor.withValues(alpha: 0.1),
              severityColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: severityColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: severityColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(severityIcon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assessment Complete',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your results are ready',
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
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Results Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      severityColor.withValues(alpha: 0.15),
                      severityColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: severityColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: severityColor.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Score Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Wellness Score',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${result.normalizedScore}/100',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: severityColor,
                            ),
                          ),
                          if (result.totalScore != result.normalizedScore) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Raw Score: ${result.totalScore}',
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Severity Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: severityColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(severityIcon, color: severityColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            result.severity,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: severityColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Suggested Activities Section
              _buildSuggestedActivities(context, result, scheme),

              const SizedBox(height: 20),
              // Disclaimer Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      scheme.surfaceContainerHighest.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: scheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Important Notice',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This is not a medical diagnosis. Please consult a healthcare professional for proper evaluation.',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close assessment screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              elevation: 4,
              shadowColor: scheme.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Got it',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedActivities(
    BuildContext context,
    AssessmentResult result,
    ColorScheme scheme,
  ) {
    final activities = _getRecommendedActivities(result);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                color: scheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Suggested Activities',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Based on your results, here are some activities that might help:',
          style: TextStyle(
            fontSize: 14,
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        ...activities.map(
          (activity) => _buildActivityCard(context, activity, scheme),
        ),
      ],
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    _SuggestedActivity activity,
    ColorScheme scheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            activity.color.withValues(alpha: 0.1),
            activity.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activity.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop(); // Close the dialog first
            activity.onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: activity.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(activity.icon, color: activity.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: activity.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: activity.color,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_SuggestedActivity> _getRecommendedActivities(AssessmentResult result) {
    final severity = result.severity.toLowerCase();
    final kind = result.kind;

    List<_SuggestedActivity> activities = [];

    // Base activities for all assessments
    activities.add(
      _SuggestedActivity(
        title: 'Journal Your Thoughts',
        description: 'Write down your feelings and reflect on your experiences',
        icon: Icons.edit_note_rounded,
        color: const Color(0xFF667eea),
        onTap: () => Navigator.of(context).pushNamed('/journal'),
      ),
    );

    // Assessment-specific recommendations
    switch (kind) {
      case AssessmentKind.phq9:
        if (severity == 'minimal' || severity == 'mild') {
          activities.addAll([
            _SuggestedActivity(
              title: 'Mood Tracking',
              description: 'Monitor your daily mood patterns and triggers',
              icon: Icons.show_chart_rounded,
              color: const Color(0xFF4facfe),
              onTap: () => Navigator.of(context).pushNamed('/mood'),
            ),
            _SuggestedActivity(
              title: 'CBT Exercises',
              description: 'Practice cognitive behavioral therapy techniques',
              icon: Icons.psychology_rounded,
              color: const Color(0xFFfa709a),
              onTap: () => Navigator.of(context).pushNamed('/cbt'),
            ),
          ]);
        } else {
          activities.addAll([
            _SuggestedActivity(
              title: 'CBT Exercises',
              description: 'Learn coping strategies and thought reframing',
              icon: Icons.psychology_rounded,
              color: const Color(0xFFfa709a),
              onTap: () => Navigator.of(context).pushNamed('/cbt'),
            ),
            _SuggestedActivity(
              title: 'Professional Support',
              description:
                  'Consider speaking with a mental health professional',
              icon: Icons.support_agent_rounded,
              color: const Color(0xFFFF6B6B),
              onTap: () => _showProfessionalSupportDialog(context),
            ),
          ]);
        }
        break;

      case AssessmentKind.gad7:
        if (severity == 'minimal' || severity == 'mild') {
          activities.addAll([
            _SuggestedActivity(
              title: 'Breathing Exercises',
              description:
                  'Practice relaxation and anxiety management techniques',
              icon: Icons.air_rounded,
              color: const Color(0xFF4ECDC4),
              onTap: () => Navigator.of(context).pushNamed('/breathing'),
            ),
            _SuggestedActivity(
              title: 'Mood Insights',
              description: 'Track patterns and identify anxiety triggers',
              icon: Icons.insights_rounded,
              color: const Color(0xFF43e97b),
              onTap: () => Navigator.of(context).pushNamed('/insights'),
            ),
          ]);
        } else {
          activities.addAll([
            _SuggestedActivity(
              title: 'Grounding Techniques',
              description: 'Learn 5-4-3-2-1 and other calming exercises',
              icon: Icons.center_focus_strong_rounded,
              color: const Color(0xFF4ECDC4),
              onTap: () => Navigator.of(context).pushNamed('/cbt'),
            ),
            _SuggestedActivity(
              title: 'Professional Support',
              description: 'Consider anxiety counseling or therapy',
              icon: Icons.support_agent_rounded,
              color: const Color(0xFFFF6B6B),
              onTap: () => _showProfessionalSupportDialog(context),
            ),
          ]);
        }
        break;

      case AssessmentKind.happiness:
        if (result.totalScore >= 24) {
          activities.addAll([
            _SuggestedActivity(
              title: 'Gratitude Practice',
              description: 'Continue building positive habits and mindfulness',
              icon: Icons.favorite_rounded,
              color: const Color(0xFFFECA57),
              onTap: () => Navigator.of(context).pushNamed('/journal'),
            ),
            _SuggestedActivity(
              title: 'Share Your Joy',
              description: 'Connect with others and spread positivity',
              icon: Icons.share_rounded,
              color: const Color(0xFF96CEB4),
              onTap: () => Navigator.of(context).pushNamed('/insights'),
            ),
          ]);
        } else {
          activities.addAll([
            _SuggestedActivity(
              title: 'Positive Activities',
              description: 'Engage in activities that bring you joy',
              icon: Icons.sentiment_very_satisfied_rounded,
              color: const Color(0xFFFECA57),
              onTap: () => Navigator.of(context).pushNamed('/cbt'),
            ),
            _SuggestedActivity(
              title: 'Mood Tracking',
              description: 'Identify what affects your happiness levels',
              icon: Icons.show_chart_rounded,
              color: const Color(0xFF4facfe),
              onTap: () => Navigator.of(context).pushNamed('/mood'),
            ),
          ]);
        }
        break;

      case AssessmentKind.selfEsteem:
        if (result.totalScore >= 24) {
          activities.addAll([
            _SuggestedActivity(
              title: 'Strengths Journal',
              description: 'Continue celebrating your achievements',
              icon: Icons.star_rounded,
              color: const Color(0xFF96CEB4),
              onTap: () => Navigator.of(context).pushNamed('/journal'),
            ),
            _SuggestedActivity(
              title: 'Goal Setting',
              description: 'Set new challenges to maintain growth',
              icon: Icons.flag_rounded,
              color: const Color(0xFF43e97b),
              onTap: () => Navigator.of(context).pushNamed('/insights'),
            ),
          ]);
        } else {
          activities.addAll([
            _SuggestedActivity(
              title: 'Self-Compassion',
              description: 'Practice being kind to yourself',
              icon: Icons.self_improvement_rounded,
              color: const Color(0xFF96CEB4),
              onTap: () => Navigator.of(context).pushNamed('/cbt'),
            ),
            _SuggestedActivity(
              title: 'Positive Affirmations',
              description: 'Build confidence through daily affirmations',
              icon: Icons.psychology_alt_rounded,
              color: const Color(0xFFfa709a),
              onTap: () => Navigator.of(context).pushNamed('/journal'),
            ),
          ]);
        }
        break;
      case AssessmentKind.pss10:
        if (result.totalScore >= 14) {
             activities.addAll([
            _SuggestedActivity(
              title: 'Breathing Exercises',
              description: 'Reduce stress with guided breathing',
              icon: Icons.air_rounded,
              color: const Color(0xFF4ECDC4),
              onTap: () => Navigator.of(context).pushNamed('/breathing'),
            ),
             _SuggestedActivity(
              title: 'CBT for Stress',
              description: 'Learn to manage stressful thoughts',
              icon: Icons.psychology_rounded,
              color: const Color(0xFFfa709a),
              onTap: () => Navigator.of(context).pushNamed('/cbt'),
            ),
          ]);
        } else {
             activities.addAll([
            _SuggestedActivity(
              title: 'Activity Log',
              description: 'Keep track of what helps you stay calm',
              icon: Icons.directions_run_rounded,
              color: const Color(0xFFFD79A8),
              onTap: () => Navigator.of(context).pushNamed('/exercise'),
            ),
            _SuggestedActivity(
              title: 'Journaling',
              description: 'Reflect on your day',
              icon: Icons.edit_note_rounded,
              color: const Color(0xFF667eea),
              onTap: () => Navigator.of(context).pushNamed('/journal'),
            ),
          ]);
        }
        break;

      case AssessmentKind.sleep:
         if (result.totalScore <= 14) {
             activities.addAll([
            _SuggestedActivity(
              title: 'Relaxation',
              description: 'Try 4-7-8 breathing before bed',
              icon: Icons.bedtime_rounded,
              color: const Color(0xFF5F27CD),
              onTap: () => Navigator.of(context).pushNamed('/breathing'),
            ),
            _SuggestedActivity(
              title: 'Sleep Hygiene',
              description: 'Review healthy sleep habits',
              icon: Icons.lightbulb_outline_rounded,
              color: const Color(0xFFFECA57),
              onTap: () => Navigator.of(context).pushNamed('/cbt'),
            ),
          ]);
        } else {
             activities.addAll([
            _SuggestedActivity(
              title: 'Morning Check-in',
              description: 'Start your day with a mood check',
              icon: Icons.wb_sunny_rounded,
              color: const Color(0xFFFF9F43),
              onTap: () => Navigator.of(context).pushNamed('/mood'),
            ),
             _SuggestedActivity(
              title: 'Activity',
              description: 'Regular exercise improves sleep',
              icon: Icons.directions_run_rounded,
              color: const Color(0xFFFD79A8),
              onTap: () => Navigator.of(context).pushNamed('/exercise'),
            ),
          ]);
        }
        break;
    }

    return activities.take(3).toList(); // Limit to 3 suggestions
  }

  void _showProfessionalSupportDialog(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: scheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Professional Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consider reaching out to:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              context,
              'Mental Health Professional',
              'Therapist, counselor, or psychologist',
              Icons.psychology_rounded,
              scheme.primary,
            ),
            const SizedBox(height: 12),
            _buildSupportOption(
              context,
              'Your Doctor',
              'Primary care physician or psychiatrist',
              Icons.medical_services_rounded,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildSupportOption(
              context,
              'Crisis Hotline',
              'If you\'re in immediate distress',
              Icons.phone_rounded,
              Colors.red,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scheme.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.emergency_rounded, color: scheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'If you\'re having thoughts of self-harm, please seek immediate help.',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedActivity {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _SuggestedActivity({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
