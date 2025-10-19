import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assessment.dart';
import '../state/mood_state.dart';

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
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
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

  void _updateProgress() {
    final answeredCount = _answers.where((answer) => answer != null).length;
    final progress = answeredCount / _answers.length;
    _progressController.animateTo(progress);
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
              return Column(
                children: [
                  _buildHeader(scheme, questions.length),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: questions.length + 1,
                      itemBuilder: (context, index) {
                        if (index == questions.length) {
                          return _buildSubmitButton(scheme, questions.length);
                        }
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
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop();
            } else {
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
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
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${_answers.where((a) => a != null).length}/$totalQuestions',
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
                      value: _progressAnimation.value,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF667eea),
                      ),
                      minHeight: 10,
                    ),
                  ),
                ],
              );
            },
          ),
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
                          _updateProgress();
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
                                      color: Colors.grey.withValues(alpha: 0.1),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ColorScheme scheme, int totalQuestions) {
    final allAnswered = _answers.every((e) => e != null);

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 40),
      child: Column(
        children: [
          if (!allAnswered) ...[
            Container(
            padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: scheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please answer all $totalQuestions questions to see your results',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          Container(
            width: double.infinity,
            height: 56,
            decoration: allAnswered
                ? BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF667eea),
                        Color(0xFF764ba2),
                        Color(0xFFf093fb),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  )
                : BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(28),
                  ),
            child: ElevatedButton(
              onPressed: allAnswered ? _submitAssessment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: allAnswered
                    ? Colors.white
                    : Colors.grey.shade600,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    allAnswered ? Icons.analytics_rounded : Icons.lock_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    allAnswered ? 'View Results' : 'Complete Assessment',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
                                  ),
                                ],
                              ),
                            );
                          }

  void _submitAssessment() {
    final answers = _answers.cast<int>();
    final result = AssessmentScoring.score(widget.kind, answers);

    // Record mood (use PHQ scale 0..27; map GAD (0..21) to 0..27 via factor 27/21)
    final raw = result.totalScore;
    final normalized = widget.kind == AssessmentKind.phq9
        ? raw
        : (raw * 27 / 21).round();

    ref.read(moodTrackerProvider.notifier).recordToday(normalized);

    showDialog(
      context: context,
      builder: (ctx) => _buildResultDialog(ctx, result),
    );
  }

  Widget _buildResultDialog(BuildContext context, AssessmentResult result) {
    final scheme = Theme.of(context).colorScheme;
    final severity = result.severity.toLowerCase();

    Color severityColor;
    IconData severityIcon;

    switch (severity) {
      case 'minimal':
        severityColor = Colors.green;
        severityIcon = Icons.check_circle_rounded;
        break;
      case 'mild':
        severityColor = Colors.orange;
        severityIcon = Icons.info_rounded;
        break;
      case 'moderate':
        severityColor = Colors.deepOrange;
        severityIcon = Icons.warning_rounded;
        break;
      case 'moderately severe':
      case 'severe':
        severityColor = Colors.red;
        severityIcon = Icons.error_rounded;
        break;
      default:
        severityColor = scheme.primary;
        severityIcon = Icons.analytics_rounded;
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
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
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
                          'Your Score',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${result.totalScore}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: severityColor,
                          ),
                        ),
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
                          '${result.severity}',
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
            const SizedBox(height: 20),
            // Disclaimer Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.surfaceVariant.withValues(alpha: 0.3),
                    scheme.surfaceVariant.withValues(alpha: 0.1),
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
      actions: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
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
}
