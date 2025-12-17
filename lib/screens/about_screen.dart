import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.only(left: 16, top: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1A1A2E),
                            const Color(0xFF16213E),
                            const Color(0xFF0F3460),
                          ]
                        : [
                            const Color(0xFF667eea),
                            const Color(0xFF764ba2),
                            const Color(0xFFf093fb),
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // App Logo with glow effect
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.15,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.1,
                                ),
                                backgroundImage: const AssetImage(
                                  'assets/logo.png',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // App Name and Tagline
                        const Text(
                          'Clarity',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your Mental Health Companion',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 06),
                        // Version Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mission Statement
                  _buildSectionCard(
                    context: context,
                    icon: Icons.favorite_rounded,
                    title: 'Our Mission',
                    color: Colors.red,
                    child: Text(
                      'Clarity is designed to support your mental health journey with evidence-based tools, personalized insights, and a compassionate approach to wellness. We believe everyone deserves access to mental health resources that are both effective and easy to use.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: isDark
                            ? scheme.onSurface.withValues(alpha: 0.9)
                            : scheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Key Features
                  _buildSectionCard(
                    context: context,
                    icon: Icons.star_rounded,
                    title: 'Key Features',
                    color: Colors.amber,
                    child: Column(
                      children: [
                        _buildFeatureItem(
                          context: context,
                          icon: Icons.mood_rounded,
                          title: 'Mood Tracking',
                          description:
                              'Monitor your emotional well-being with daily mood entries and insights.',
                          color: const Color(0xFF4CAF50),
                        ),
                        _buildFeatureItem(
                          context: context,
                          icon: Icons.edit_note_rounded,
                          title: 'Journal & Reflection',
                          description:
                              'Express your thoughts and feelings through guided journaling.',
                          color: const Color(0xFF2196F3),
                        ),
                        _buildFeatureItem(
                          context: context,
                          icon: Icons.assessment_rounded,
                          title: 'Mental Health Assessments',
                          description:
                              'Take validated assessments like PHQ-9 and GAD-7 to track your progress.',
                          color: const Color(0xFF9C27B0),
                        ),
                        _buildFeatureItem(
                          context: context,
                          icon: Icons.psychology_rounded,
                          title: 'CBT Tools',
                          description:
                              'Access cognitive behavioral therapy techniques and exercises.',
                          color: const Color(0xFFFF5722),
                        ),
                        _buildFeatureItem(
                          context: context,
                          icon: Icons.insights_rounded,
                          title: 'Personal Insights',
                          description:
                              'Get personalized insights based on your data and patterns.',
                          color: const Color(0xFF607D8B),
                        ),
                        _buildFeatureItem(
                          context: context,
                          icon: Icons.security_rounded,
                          title: 'Privacy First',
                          description:
                              'Your data is encrypted and stored securely with full privacy control.',
                          color: const Color(0xFF795548),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Privacy & Security
                  _buildSectionCard(
                    context: context,
                    icon: Icons.shield_rounded,
                    title: 'Privacy & Security',
                    color: Colors.green,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your privacy and security are our top priorities:',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? scheme.onSurface.withValues(alpha: 0.95)
                                    : scheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _buildPrivacyPoint(
                          context: context,
                          icon: Icons.lock_rounded,
                          text:
                              'End-to-end encryption for all your personal data',
                        ),
                        _buildPrivacyPoint(
                          context: context,
                          icon: Icons.visibility_off_rounded,
                          text:
                              'No data sharing with third parties without consent',
                        ),
                        _buildPrivacyPoint(
                          context: context,
                          icon: Icons.cloud_off_rounded,
                          text: 'Local data storage with optional cloud backup',
                        ),
                        _buildPrivacyPoint(
                          context: context,
                          icon: Icons.delete_forever_rounded,
                          text: 'Complete data deletion available anytime',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Development Team
                  _buildSectionCard(
                    context: context,
                    icon: Icons.group_rounded,
                    title: 'Development Team',
                    color: Colors.blue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clarity is developed by a passionate team of developers, designers, and mental health advocates committed to making mental wellness accessible to everyone.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                height: 1.6,
                                color: isDark
                                    ? scheme.onSurface.withValues(alpha: 0.9)
                                    : scheme.onSurface.withValues(alpha: 0.8),
                              ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.code_rounded,
                                color: scheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Built with Flutter',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? scheme.onSurface.withValues(
                                                  alpha: 0.95,
                                                )
                                              : scheme.onSurface,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cross-platform mobile application',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isDark
                                              ? scheme.onSurface.withValues(
                                                  alpha: 0.7,
                                                )
                                              : scheme.onSurface.withValues(
                                                  alpha: 0.6,
                                                ),
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

                  const SizedBox(height: 24),

                  // Contact & Support
                  _buildSectionCard(
                    context: context,
                    icon: Icons.support_agent_rounded,
                    title: 'Contact & Support',
                    color: Colors.orange,
                    child: Column(
                      children: [
                        _buildContactItem(
                          context: context,
                          icon: Icons.email_rounded,
                          title: 'Email Support',
                          subtitle: 'support@clarityapp.com',
                          onTap: () => _copyToClipboard(
                            context,
                            'support@clarityapp.com',
                          ),
                        ),
                        _buildContactItem(
                          context: context,
                          icon: Icons.bug_report_rounded,
                          title: 'Report Issues',
                          subtitle: 'Help us improve Clarity',
                          onTap: () =>
                              _copyToClipboard(context, 'bugs@clarityapp.com'),
                        ),
                        _buildContactItem(
                          context: context,
                          icon: Icons.feedback_rounded,
                          title: 'Feedback',
                          subtitle: 'Share your thoughts and suggestions',
                          onTap: () => _copyToClipboard(
                            context,
                            'feedback@clarityapp.com',
                          ),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Legal & Acknowledgments
                  _buildSectionCard(
                    context: context,
                    icon: Icons.gavel_rounded,
                    title: 'Legal & Acknowledgments',
                    color: Colors.indigo,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegalItem(
                          context: context,
                          title: 'Open Source Libraries',
                          subtitle:
                              'Built with Flutter, Riverpod, and other amazing open source projects',
                        ),
                        _buildLegalItem(
                          context: context,
                          title: 'Mental Health Resources',
                          subtitle:
                              'Assessment tools based on validated clinical instruments',
                        ),
                        _buildLegalItem(
                          context: context,
                          title: 'Copyright',
                          subtitle:
                              '© 2024 Clarity Mental Health. All rights reserved.',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Important Disclaimer
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.errorContainer.withValues(alpha: 0.15),
                          scheme.errorContainer.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: scheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: scheme.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.medical_services_rounded,
                                size: 24,
                                color: scheme.error,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Medical Disclaimer',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: scheme.error,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Clarity is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of qualified health providers with any questions you may have regarding a medical condition.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: isDark
                                    ? scheme.onSurface.withValues(alpha: 0.9)
                                    : scheme.onSurface.withValues(alpha: 0.8),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: scheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: scheme.error.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.emergency_rounded,
                                color: scheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'If you are in crisis, please contact emergency services or a crisis helpline immediately.',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: scheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Thank You Message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.primaryContainer.withValues(alpha: 0.3),
                          scheme.secondaryContainer.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: scheme.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Thank You',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? scheme.onSurface.withValues(alpha: 0.95)
                                    : scheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Thank you for choosing Clarity as your mental health companion. Your well-being matters, and we\'re honored to be part of your journey.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                height: 1.6,
                                color: isDark
                                    ? scheme.onSurface.withValues(alpha: 0.8)
                                    : scheme.onSurface.withValues(alpha: 0.7),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? scheme.onSurface.withValues(alpha: 0.95)
                        : scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    bool isLast = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? scheme.onSurface.withValues(alpha: 0.95)
                        : scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? scheme.onSurface.withValues(alpha: 0.7)
                        : scheme.onSurface.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPoint({
    required BuildContext context,
    required IconData icon,
    required String text,
    bool isLast = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? scheme.onSurface.withValues(alpha: 0.8)
                    : scheme.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? scheme.onSurface.withValues(alpha: 0.95)
                              : scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? scheme.onSurface.withValues(alpha: 0.7)
                              : scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.content_copy_rounded,
                  size: 18,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? scheme.onSurface.withValues(alpha: 0.95)
                  : scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? scheme.onSurface.withValues(alpha: 0.7)
                  : scheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $text to clipboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
