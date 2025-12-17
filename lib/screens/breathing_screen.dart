import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  // 4-7-8 Breathing Technique
  static const int _inhaleDuration = 4000;
  static const int _holdDuration = 7000;
  static const int _exhaleDuration = 8000;
  
  String _instructionText = 'Press Start';
  bool _isPlaying = false;
  Timer? _breathingTimer;
  Timer? _countdownTimer;

  // Timer Settings
  int _selectedDurationMinutes = 1;
  int _remainingSeconds = 60;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _inhaleDuration),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _breathingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startBreathingCycle() {
    if (!mounted) return;
    
    // Inhale (4s)
    setState(() => _instructionText = 'Inhale...');
    _controller.duration = const Duration(milliseconds: _inhaleDuration);
    _controller.forward();
    HapticFeedback.mediumImpact();

    _breathingTimer = Timer(const Duration(milliseconds: _inhaleDuration), () {
      if (!mounted || !_isPlaying) return;
      
      // Hold (7s)
      setState(() => _instructionText = 'Hold...');
      HapticFeedback.lightImpact();
      
      _breathingTimer = Timer(const Duration(milliseconds: _holdDuration), () {
        if (!mounted || !_isPlaying) return;
        
        // Exhale (8s)
        setState(() => _instructionText = 'Exhale...');
        HapticFeedback.mediumImpact();
        _controller.duration = const Duration(milliseconds: _exhaleDuration);
        _controller.reverse();
        
        _breathingTimer = Timer(const Duration(milliseconds: _exhaleDuration), () {
          if (!mounted || !_isPlaying) return;
          _startBreathingCycle();
        });
      });
    });
  }

  void _startCountdown() {
    _remainingSeconds = _selectedDurationMinutes * 60;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _stopExercise();
        }
      });
    });
  }

  void _stopExercise() {
    _breathingTimer?.cancel();
    _countdownTimer?.cancel();
    _controller.stop();
    _controller.reset();
    setState(() {
      _isPlaying = false;
      _instructionText = 'Press Start';
      _remainingSeconds = _selectedDurationMinutes * 60;
    });
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startCountdown();
      _startBreathingCycle();
    } else {
      _stopExercise();
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: scheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    const Color(0xFFE3F2FD),
                    const Color(0xFFBBDEFB),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '4-7-8 Breathing',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              if (!_isPlaying) ...[
                Text(
                  'Set Duration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ToggleButtons(
                  isSelected: [1, 2, 5].map((d) => _selectedDurationMinutes == d).toList(),
                  onPressed: (index) {
                    setState(() {
                      _selectedDurationMinutes = [1, 2, 5][index];
                      _remainingSeconds = _selectedDurationMinutes * 60;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  constraints: const BoxConstraints(minWidth: 60, minHeight: 40),
                  fillColor: scheme.primary.withValues(alpha: 0.2),
                  selectedColor: scheme.primary,
                  children: const [
                    Text('1 min'),
                    Text('2 min'),
                    Text('5 min'),
                  ],
                ),
              ] else ...[
                 Text(
                  'Time Remaining: ${_formatTime(_remainingSeconds)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Breathing Circle Animation
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            scheme.primary.withValues(alpha: 0.6),
                            scheme.primary.withValues(alpha: 0.2),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.surface.withValues(alpha: 0.9),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.shadow.withValues(alpha: 0.1),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _instructionText,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.primary,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const Spacer(),
              
              // Control Button
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: IconButton.filled(
                  onPressed: _togglePlay,
                  iconSize: 48,
                  padding: const EdgeInsets.all(24),
                  icon: Icon(_isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
