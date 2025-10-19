import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo_v2.png', height: 32, width: 32),
            const SizedBox(width: 12),
            const Text('Clarity'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Insights',
            onPressed: () => Navigator.of(context).pushNamed('/insights'),
            icon: const Icon(Icons.insights),
          ),
          IconButton(
            tooltip: 'Mood Tracker',
            onPressed: () => Navigator.of(context).pushNamed('/mood'),
            icon: const Icon(Icons.show_chart),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'cbt':
                  Navigator.of(context).pushNamed('/cbt');
                  break;
                case 'profile':
                  Navigator.of(context).pushNamed('/profile');
                  break;
                case 'settings':
                  Navigator.of(context).pushNamed('/settings');
                  break;
                case 'about':
                  Navigator.of(context).pushNamed('/about');
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'cbt', child: Text('CBT Exercises')),
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'about', child: Text('About')),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: SvgPicture.asset(
                      'assets/illustrations/header_wave.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome to Clarity',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Track your mental wellness with quick, validated self-checks (PHQ-9, GAD-7) and a reflective journal. Your daily results map into a simple mood tracker to help you notice trends early.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _NavCard(
                  title: 'PHQ-9 Depression Check',
                  subtitle: '9 questions • ~2 minutes',
                  icon: Icons.mood,
                  onTap: () => Navigator.of(context).pushNamed('/phq9'),
                ),
                _NavCard(
                  title: 'GAD-7 Anxiety Check',
                  subtitle: '7 questions • ~2 minutes',
                  icon: Icons.psychology,
                  onTap: () => Navigator.of(context).pushNamed('/gad7'),
                ),
                _NavCard(
                  title: 'Journal',
                  subtitle: 'Reflect and track mood',
                  icon: Icons.edit_note,
                  onTap: () => Navigator.of(context).pushNamed('/journal'),
                ),
                _NavCard(
                  title: 'Insights',
                  subtitle: 'Averages, trends, and streaks',
                  icon: Icons.insights,
                  onTap: () => Navigator.of(context).pushNamed('/insights'),
                ),
                _NavCard(
                  title: 'CBT Micro-exercises',
                  subtitle: 'Breathing, grounding, reframing',
                  icon: Icons.self_improvement,
                  onTap: () => Navigator.of(context).pushNamed('/cbt'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Disclaimer: This app does not provide medical advice. If you are in crisis, seek immediate help.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Define beautiful gradients for different cards
    final cardGradients = {
      'Mood Tracker': [const Color(0xFF667eea), const Color(0xFF764ba2)],
      'Journal': [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      'CBT Micro-exercises': [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      'Insights': [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      'Assessment': [const Color(0xFFfa709a), const Color(0xFFfee140)],
    };

    final gradient = cardGradients[title] ?? [scheme.primary, scheme.secondary];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient[0].withValues(alpha: 0.1),
            gradient[1].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gradient[0].withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gradient[0].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: gradient[0],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
