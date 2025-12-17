import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/user_state.dart';
import '../state/app_state.dart';
import '../state/mood_state.dart';
import '../state/theme_state.dart';
import '../services/auth_service.dart';
import '../widgets/data_sync_widget.dart';
import '../state/notification_state.dart';
import 'notification_settings_screen.dart';
import '../state/onboarding_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userState = ref.watch(userStateProvider);
    final journalEntries = ref.watch(journalProvider);
    final moodEntries = ref.watch(moodTrackerProvider);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
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
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/'),
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Profile Avatar with glow effect
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            child: userState.profile?.avatarId != null && 
                                   userState.profile!.avatarId!.isNotEmpty
                                ? Text(
                                    userState.profile!.avatarId!,
                                    style: const TextStyle(fontSize: 48),
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    size: 45,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // User Info
                        Text(
                          userState.profile?.displayName ??
                              'Welcome to Clarity',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userState.profile?.email ??
                              'Your mental health companion',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  onPressed: () => _showLogoutDialog(context, ref),
                ),
              ),
            ],
          ),
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Member Since Card
                  if (userState.profile != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 24),
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
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
                                  'Member Since',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? scheme.onSurfaceVariant
                                                  .withValues(alpha: 0.9)
                                            : scheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(userState.profile!.createdAt),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? scheme.onSurface.withValues(
                                                alpha: 0.95,
                                              )
                                            : null,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Progress Stats Section
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        color: scheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Progress',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? scheme.onSurface.withValues(alpha: 0.95)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Enhanced Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      _EnhancedStatCard(
                        title: 'Mood Entries',
                        value: '${moodEntries.length}',
                        icon: Icons.mood_rounded,
                        color: const Color(
                          0xFF4CAF50,
                        ), // Green for mood/wellness
                        gradient: [
                          const Color(0xFF4CAF50),
                          const Color(0xFF66BB6A),
                        ],
                      ),
                      _EnhancedStatCard(
                        title: 'Journal Entries',
                        value: '${journalEntries.length}',
                        icon: Icons.edit_note_rounded,
                        color: const Color(
                          0xFF2196F3,
                        ), // Blue for writing/creativity
                        gradient: [
                          const Color(0xFF2196F3),
                          const Color(0xFF42A5F5),
                        ],
                      ),
                      _EnhancedStatCard(
                        title: 'Current Streak',
                        value: '${_calculateStreak(moodEntries)}',
                        subtitle: 'days',
                        icon: Icons.local_fire_department_rounded,
                        color: const Color(
                          0xFFFF5722,
                        ), // Orange-red for fire/streak
                        gradient: [
                          const Color(0xFFFF5722),
                          const Color(0xFFFF7043),
                        ],
                      ),
                      _EnhancedStatCard(
                        title: 'Avg Mood',
                        value: moodEntries.isNotEmpty
                            ? (moodEntries
                                          .map((e) => e.score)
                                          .reduce((a, b) => a + b) /
                                      moodEntries.length)
                                  .toStringAsFixed(1)
                            : 'N/A',
                        icon: Icons.analytics_rounded,
                        color: const Color(
                          0xFF9C27B0,
                        ), // Purple for analytics/insights
                        gradient: [
                          const Color(0xFF9C27B0),
                          const Color(0xFFAB47BC),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Data Sync Widget
                  const DataSyncWidget(),

                  const SizedBox(height: 32),

                  // Settings Section
                  Row(
                    children: [
                      Icon(
                        Icons.settings_rounded,
                        color: scheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? scheme.onSurface.withValues(alpha: 0.95)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Enhanced Settings Tiles
                  _EnhancedSettingsTile(
                    icon: Icons.edit_rounded,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    color: scheme.primary,
                    onTap: () => _showEditProfileDialog(context, ref),
                  ),

                  Consumer(
                    builder: (context, ref, child) {
                      final notificationSummary = ref.watch(
                        notificationSummaryProvider,
                      );
                      return _EnhancedSettingsTile(
                        icon: Icons.notifications_rounded,
                        title: 'Notifications',
                        subtitle: notificationSummary,
                        color: Colors.blue,
                        onTap: () => _showNotificationsDialog(context),
                      );
                    },
                  ),

                  _EnhancedSettingsTile(
                    icon: Icons.palette_rounded,
                    title: 'Appearance',
                    subtitle: 'Theme and display settings',
                    color: Colors.purple,
                    onTap: () => _showAppearanceDialog(context),
                  ),

                  _EnhancedSettingsTile(
                    icon: Icons.privacy_tip_rounded,
                    title: 'Privacy',
                    subtitle: 'Data and privacy settings',
                    color: Colors.green,
                    onTap: () => _showPrivacyDialog(context),
                  ),

                  _EnhancedSettingsTile(
                    icon: Icons.storage_rounded,
                    title: 'Data Management',
                    subtitle: 'Export, import, and manage your data',
                    color: Colors.indigo,
                    onTap: () =>
                        Navigator.of(context).pushNamed('/data-management'),
                  ),

                  _EnhancedSettingsTile(
                    icon: Icons.help_rounded,
                    title: 'Help & Support',
                    subtitle: 'Get help and support',
                    color: Colors.orange,
                    onTap: () => Navigator.of(context).pushNamed('/help'),
                  ),

                  const SizedBox(height: 20),

                  // About Section
                  _EnhancedSettingsTile(
                    icon: Icons.info_rounded,
                    title: 'About Clarity',
                    subtitle: 'Learn more about our mission and features',
                    color: scheme.tertiary,
                    onTap: () => Navigator.of(context).pushNamed('/about'),
                  ),

                  const SizedBox(height: 32),

                  // Enhanced Disclaimer
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.errorContainer.withValues(alpha: 0.1),
                          scheme.errorContainer.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: scheme.error.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: scheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: 20,
                                color: scheme.error,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Important Notice',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: scheme.error,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This app does not provide medical advice. If you are in crisis, seek immediate help from a healthcare professional or emergency services.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isDark
                                    ? scheme.onSurfaceVariant.withValues(
                                        alpha: 0.9,
                                      )
                                    : scheme.onSurfaceVariant,
                                height: 1.4,
                              ),
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
}

class _EnhancedStatCard extends StatelessWidget {
  const _EnhancedStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradient,
    this.subtitle,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient[0].withValues(alpha: 0.15),
            gradient[1].withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? scheme.onSurfaceVariant.withValues(alpha: 0.9)
                    : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EnhancedSettingsTile extends StatelessWidget {
  const _EnhancedSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? scheme.onSurface.withValues(alpha: 0.95)
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? scheme.onSurfaceVariant.withValues(alpha: 0.9)
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                    size: 20,
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

// Helper methods for ProfileScreen
String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

int _calculateStreak(List<dynamic> moodEntries) {
  if (moodEntries.isEmpty) return 0;

  final today = DateTime.now();
  int streak = 0;

  for (int i = 0; i < 365; i++) {
    final checkDate = today.subtract(Duration(days: i));
    final hasEntry = moodEntries.any((entry) {
      final entryDate = entry.date;
      return entryDate.year == checkDate.year &&
          entryDate.month == checkDate.month &&
          entryDate.day == checkDate.day;
    });

    if (hasEntry) {
      streak++;
    } else {
      break;
    }
  }

  return streak;
}

void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);
            navigator.pop();
            try {
              // Reset onboarding state so next login starts fresh
              ref.read(onboardingProvider.notifier).reset();
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              }
            } catch (e) {
              if (context.mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to sign out: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );
}

void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _EditProfileDialog(ref: ref),
  );
}

void _showNotificationsDialog(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
  );
}

void _showAppearanceDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const _AppearanceSettingsDialog(),
  );
}

void _showPrivacyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const _PrivacySettingsDialog(),
  );
}

void _showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Help & Support'),
      content: const Text(
        'For support, please contact us at support@clarityapp.com or visit our help center.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class _EditProfileDialog extends ConsumerStatefulWidget {
  const _EditProfileDialog({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  bool _isLoading = false;
  String? _selectedAvatar;

  // Matching PersonalizationScreen emojis
  final List<String> _avatarOptions = [
    '🦊', '🐼', '🐯', '🦁', '🐷', '🦄', '🐙', '🦋'
  ];

  @override
  void initState() {
    super.initState();
    final userState = widget.ref.watch(userStateProvider);
    final preferences = userState.profile?.preferences ?? {};

    _nameController = TextEditingController(
      text: userState.profile?.displayName ?? '',
    );
    _emailController = TextEditingController(
      text: userState.profile?.email ?? '',
    );
    _bioController = TextEditingController(
      text: preferences['bio']?.toString() ?? '',
    );
    _phoneController = TextEditingController(
      text: userState.profile?.phoneNumber ?? preferences['phone']?.toString() ?? '',
    );
    _locationController = TextEditingController(
      text: preferences['location']?.toString() ?? '',
    );
    _selectedAvatar = userState.profile?.avatarId ?? preferences['avatar']?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withValues(alpha: 0.1),
                    scheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
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
                          'Edit Profile',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? scheme.onSurface.withValues(alpha: 0.95)
                                    : scheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update your personal information',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isDark
                                    ? scheme.onSurface.withValues(alpha: 0.7)
                                    : scheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar Selection Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: scheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.face_rounded,
                                  color: scheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Choose Avatar',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? scheme.onSurface.withValues(
                                                alpha: 0.95,
                                              )
                                            : scheme.onSurface,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Current avatar preview
                            if (_selectedAvatar != null)
                              Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: scheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(
                                      color: scheme.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: scheme.primary.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _selectedAvatar!,
                                      style: const TextStyle(fontSize: 36),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            // Avatar options grid
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: _avatarOptions.map((avatar) {
                                final isSelected = _selectedAvatar == avatar;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedAvatar = avatar),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? scheme.primary.withValues(
                                              alpha: 0.15,
                                            )
                                          : scheme.surfaceContainerHighest
                                                .withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? scheme.primary
                                            : scheme.outline.withValues(
                                                alpha: 0.3,
                                              ),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        avatar,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Form Fields
                      _buildFormField(
                        controller: _nameController,
                        label: 'Display Name',
                        icon: Icons.person_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a display name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildFormField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_rounded,
                        enabled: false,
                        helperText: 'Email cannot be changed',
                      ),

                      const SizedBox(height: 16),

                      _buildFormField(
                        controller: _bioController,
                        label: 'Bio',
                        icon: Icons.description_rounded,
                        maxLines: 3,
                        helperText: 'Tell us about yourself (optional)',
                      ),

                      const SizedBox(height: 16),

                      _buildFormField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        helperText: 'Your contact number (optional)',
                      ),

                      const SizedBox(height: 16),

                      _buildFormField(
                        controller: _locationController,
                        label: 'Location',
                        icon: Icons.location_on_rounded,
                        helperText: 'Where are you based? (optional)',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.save_rounded, size: 18),
                                const SizedBox(width: 8),
                                const Text('Save Changes'),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    String? helperText,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? scheme.onSurface.withValues(alpha: 0.9)
                    : scheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          style: TextStyle(
            color: enabled
                ? (isDark
                      ? scheme.onSurface.withValues(alpha: 0.95)
                      : scheme.onSurface)
                : scheme.onSurface.withValues(alpha: 0.6),
          ),
          decoration: InputDecoration(
            hintText: 'Enter your $label',
            helperText: helperText,
            helperStyle: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            filled: true,
            fillColor: enabled
                ? scheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: scheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: scheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.error),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: scheme.outline.withValues(alpha: 0.2),
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userNotifier = ref.read(userStateProvider.notifier);
      final currentProfile = ref.read(userStateProvider).profile;

      if (currentProfile == null) return;

      // Create updated preferences map
      final updatedPreferences = Map<String, dynamic>.from(
        currentProfile.preferences,
      );

      // We still update preferences for backward compatibility if needed,
      // but primary source of truth is now the top-level fields.
      if (_selectedAvatar != null) {
        updatedPreferences['avatar'] = _selectedAvatar;
      }
      if (_phoneController.text.trim().isNotEmpty) {
        updatedPreferences['phone'] = _phoneController.text.trim();
      }

      if (_bioController.text.trim().isNotEmpty) {
        updatedPreferences['bio'] = _bioController.text.trim();
      } else {
        updatedPreferences.remove('bio');
      }

      if (_locationController.text.trim().isNotEmpty) {
        updatedPreferences['location'] = _locationController.text.trim();
      } else {
        updatedPreferences.remove('location');
      }

      // Create updated profile
      final updatedProfile = currentProfile.copyWith(
        displayName: _nameController.text.trim(),
        preferences: updatedPreferences,
        // Crucial updates for new fields
        avatarId: _selectedAvatar,
        phoneNumber: _phoneController.text.trim(),
      );

      await userNotifier.updateProfile(updatedProfile);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

class _AppearanceSettingsDialog extends ConsumerWidget {
  const _AppearanceSettingsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final themeSettings = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withValues(alpha: 0.1),
              Colors.purple.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.palette_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Appearance Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
              // Theme Mode Section
              _buildSectionHeader(
                context,
                'Theme Mode',
                Icons.brightness_6_rounded,
              ),
              const SizedBox(height: 12),
              _buildThemeModeOptions(context, themeSettings, themeNotifier),

              const SizedBox(height: 24),

              // Color Scheme Section
              _buildSectionHeader(
                context,
                'Color Scheme',
                Icons.color_lens_rounded,
              ),
              const SizedBox(height: 12),
              _buildColorSchemeOptions(context, themeSettings, themeNotifier),

              const SizedBox(height: 24),


            ],
          ),
        ),
      ),
      actions: [
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: scheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeOptions(
    BuildContext context,
    ThemeSettings settings,
    ThemeNotifier notifier,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: AppThemeMode.values.map((mode) {
        final isSelected = settings.themeMode == mode;
        String title;
        String subtitle;
        IconData icon;

        switch (mode) {
          case AppThemeMode.system:
            title = 'System';
            subtitle = 'Follow system setting';
            icon = Icons.brightness_auto_rounded;
            break;
          case AppThemeMode.light:
            title = 'Light';
            subtitle = 'Light theme';
            icon = Icons.brightness_high_rounded;
            break;
          case AppThemeMode.dark:
            title = 'Dark';
            subtitle = 'Dark theme';
            icon = Icons.brightness_2_rounded;
            break;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? scheme.primaryContainer.withValues(alpha: 0.3)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? scheme.primary.withValues(alpha: 0.5)
                  : scheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => notifier.updateThemeMode(mode),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? scheme.primary.withValues(alpha: 0.2)
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        size: 18,
                      ),
                    ),
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
                              color: scheme.onSurface,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: scheme.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSchemeOptions(
    BuildContext context,
    ThemeSettings settings,
    ThemeNotifier notifier,
  ) {
    final scheme = Theme.of(context).colorScheme;

    final colorOptions = [
      (AppColorScheme.blue, 'Blue', const Color(0xFF667eea)),
      (AppColorScheme.purple, 'Purple', const Color(0xFF9C27B0)),
      (AppColorScheme.green, 'Green', const Color(0xFF4CAF50)),
      (AppColorScheme.orange, 'Orange', const Color(0xFFFF9800)),
      (AppColorScheme.pink, 'Pink', const Color(0xFFE91E63)),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colorOptions.map((option) {
        final colorScheme = option.$1;
        final name = option.$2;
        final color = option.$3;
        final isSelected = settings.colorScheme == colorScheme;

        return GestureDetector(
          onTap: () => notifier.updateColorScheme(colorScheme),
          child: Container(
            width: 80,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.1)
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.5)
                    : scheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }


}

class _PrivacySettingsDialog extends ConsumerStatefulWidget {
  const _PrivacySettingsDialog();

  @override
  ConsumerState<_PrivacySettingsDialog> createState() =>
      _PrivacySettingsDialogState();
}

class _PrivacySettingsDialogState
    extends ConsumerState<_PrivacySettingsDialog> {
  bool _analyticsEnabled = true;
  bool _crashReportingEnabled = true;
  bool _dataBackupEnabled = true;
  bool _localDataOnly = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_rounded,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Privacy & Data Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data Security Section
                    _buildSectionHeader(
                      context,
                      'Data Security',
                      Icons.security_rounded,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      context,
                      'End-to-End Encryption',
                      'Your personal data is encrypted both in transit and at rest using industry-standard AES-256 encryption.',
                      Icons.lock_rounded,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context,
                      'Secure Cloud Storage',
                      'Data is stored securely in Firebase with enterprise-grade security measures and regular security audits.',
                      Icons.cloud_done_rounded,
                      Colors.blue,
                    ),

                    const SizedBox(height: 32),

                    // Data Collection Section
                    _buildSectionHeader(
                      context,
                      'Data Collection',
                      Icons.data_usage_rounded,
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),

                    _buildToggleCard(
                      context,
                      'Anonymous Analytics',
                      'Help improve the app by sharing anonymous usage statistics. No personal data is included.',
                      Icons.analytics_rounded,
                      Colors.orange,
                      _analyticsEnabled,
                      (value) => setState(() => _analyticsEnabled = value),
                    ),
                    const SizedBox(height: 12),

                    _buildToggleCard(
                      context,
                      'Crash Reporting',
                      'Automatically send crash reports to help us fix bugs and improve stability.',
                      Icons.bug_report_rounded,
                      Colors.orange,
                      _crashReportingEnabled,
                      (value) => setState(() => _crashReportingEnabled = value),
                    ),

                    const SizedBox(height: 32),

                    // Data Management Section
                    _buildSectionHeader(
                      context,
                      'Data Management',
                      Icons.storage_rounded,
                      Colors.purple,
                    ),
                    const SizedBox(height: 16),

                    _buildToggleCard(
                      context,
                      'Cloud Backup',
                      'Automatically backup your data to the cloud for recovery across devices.',
                      Icons.backup_rounded,
                      Colors.purple,
                      _dataBackupEnabled,
                      (value) => setState(() => _dataBackupEnabled = value),
                    ),
                    const SizedBox(height: 12),

                    _buildToggleCard(
                      context,
                      'Local Storage Only',
                      'Keep all data on this device only. Disables cloud sync and backup features.',
                      Icons.phone_android_rounded,
                      Colors.purple,
                      _localDataOnly,
                      (value) => setState(() => _localDataOnly = value),
                    ),

                    const SizedBox(height: 32),

                    // Privacy Rights Section
                    _buildSectionHeader(
                      context,
                      'Your Privacy Rights',
                      Icons.gavel_rounded,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),

                    _buildActionCard(
                      context,
                      'Export Your Data',
                      'Download a copy of all your personal data in a portable format.',
                      Icons.download_rounded,
                      Colors.green,
                      () => _showExportDialog(context),
                    ),
                    const SizedBox(height: 12),

                    _buildActionCard(
                      context,
                      'Delete Account',
                      'Permanently delete your account and all associated data.',
                      Icons.delete_forever_rounded,
                      Colors.red,
                      () => _showDeleteAccountDialog(context),
                    ),

                    const SizedBox(height: 32),

                    // Data Usage Information
                    _buildSectionHeader(
                      context,
                      'What Data We Collect',
                      Icons.info_outline_rounded,
                      Colors.indigo,
                    ),
                    const SizedBox(height: 16),

                    _buildDataTypeCard(
                      context,
                      'Mood Entries',
                      'Your daily mood ratings and notes',
                      Icons.mood_rounded,
                    ),
                    const SizedBox(height: 8),
                    _buildDataTypeCard(
                      context,
                      'Journal Entries',
                      'Your personal journal entries and reflections',
                      Icons.edit_note_rounded,
                    ),
                    const SizedBox(height: 8),
                    _buildDataTypeCard(
                      context,
                      'Profile Information',
                      'Display name, email, and preferences',
                      Icons.person_rounded,
                    ),
                    const SizedBox(height: 8),
                    _buildDataTypeCard(
                      context,
                      'Usage Statistics',
                      'App usage patterns (anonymous)',
                      Icons.bar_chart_rounded,
                    ),

                    const SizedBox(height: 32),

                    // Important Notice
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.errorContainer.withValues(alpha: 0.1),
                            scheme.errorContainer.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: scheme.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: scheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Important',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We never sell your personal data to third parties. Your mental health information is private and confidential. For medical emergencies, please contact emergency services immediately.',
                            style: TextStyle(
                              fontSize: 14,
                              color: scheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Privacy Policy Link
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _showPrivacyPolicyDialog(context),
                        icon: const Icon(Icons.article_rounded),
                        label: const Text('Read Full Privacy Policy'),
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Save privacy settings
                        _savePrivacySettings();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Privacy settings saved'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: color.withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return color;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTypeCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _savePrivacySettings() {
    // Here you would save the privacy settings to your preferred storage
    // For example, using SharedPreferences or your app's state management
    // TODO: Implement actual privacy settings persistence

    // For now, we'll just show that settings would be saved
    // In a real implementation, you would:
    // 1. Save to SharedPreferences or secure storage
    // 2. Update your app's privacy state
    // 3. Apply the settings to analytics/crash reporting services
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Export Your Data'),
          ],
        ),
        content: const Text(
          'Your data will be exported as a JSON file containing all your mood entries, journal entries, and profile information. This may take a few moments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement data export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Data export started. You will be notified when complete.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Export', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This action cannot be undone. All your data including mood entries, journal entries, and profile information will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Show confirmation dialog
              _showFinalDeleteConfirmation(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context) {
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type "DELETE" to confirm account deletion:'),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                hintText: 'Type DELETE here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (confirmController.text == 'DELETE') {
                Navigator.of(context).pop();
                // Implement account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Account deletion initiated. You will be signed out shortly.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please type "DELETE" to confirm'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Confirm Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.article_rounded, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: SingleChildScrollView(
                  child: Text('''
CLARITY MENTAL HEALTH APP - PRIVACY POLICY

Last Updated: October 2025

1. INFORMATION WE COLLECT
We collect information you provide directly to us, such as:
• Account information (email, display name)
• Mood tracking data and ratings
• Journal entries and personal reflections
• App usage statistics (anonymous)

2. HOW WE USE YOUR INFORMATION
• To provide and maintain our services
• To improve app functionality and user experience
• To send important updates about the service
• To provide customer support

3. DATA SECURITY
• All data is encrypted in transit and at rest
• We use industry-standard security measures
• Regular security audits and updates
• No data is shared with third parties without consent

4. YOUR RIGHTS
• Access your personal data
• Correct inaccurate information
• Delete your account and data
• Export your data in a portable format
• Opt-out of analytics and crash reporting

5. DATA RETENTION
• Account data is retained while your account is active
• Deleted accounts are permanently removed within 30 days
• Backup data is securely deleted within 90 days

6. CONTACT US
For privacy questions or concerns, contact us at:
privacy@clarityapp.com

This policy may be updated periodically. We will notify you of significant changes.
                    ''', style: TextStyle(fontSize: 14, height: 1.5)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
