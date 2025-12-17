import 'package:flutter/material.dart';
import '../../widgets/onboarding_page_indicator.dart';

class OnboardingCarouselScreen extends StatefulWidget {
  const OnboardingCarouselScreen({super.key});

  @override
  State<OnboardingCarouselScreen> createState() =>
      _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState extends State<OnboardingCarouselScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Find Your Inner Peace',
      'description':
          'Discover customized tools and techniques to help you manage specific mental health challenges in your daily life.',
      'icon': Icons.self_improvement,
      'color': const Color(0xFF64B5F6),
    },
    {
      'title': 'Guided Breathing',
      'description':
          'Access quick, effective breathing exercises designed to calm your mind and reduce anxiety in moments of stress.',
      'icon': Icons.air,
      'color': const Color(0xFF81C784),
    },
    {
      'title': 'Track Your Wellness',
      'description':
          'Monitor your mood and progress over time with intuitive tracking tools and visualized insights.',
      'icon': Icons.insights,
      'color': const Color(0xFFBA68C8),
    },
    {
      'title': 'Evidence-Based',
      'description':
          'Utilize professional assessments like PHQ-9 and GAD-7 to better understand your mental health status.',
      'icon': Icons.psychology_alt,
      'color': const Color(0xFFFFB74D),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/signup');
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed('/signup');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Content
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (page['color'] as Color).withValues(alpha: 0.1),
                      scheme.surface,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: (page['color'] as Color).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        page['icon'] as IconData,
                        size: 80,
                        color: page['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      page['title'] as String,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page['description'] as String,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Skip Button
          Positioned(
            top: 50,
            right: 24,
            child: TextButton(
              onPressed: _skip,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                OnboardingPageIndicator(
                  currentPage: _currentPage,
                  pageCount: _pages.length,
                  activeColor: scheme.primary,
                  inactiveColor: scheme.outlineVariant,
                ),

                // Next Button
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
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
