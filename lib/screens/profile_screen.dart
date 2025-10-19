import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: scheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Clarity',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your mental health companion',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Quick Stats
            Text(
              'Your Progress',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Mood Entries',
                    value: '0',
                    icon: Icons.mood_rounded,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Journal Entries',
                    value: '0',
                    icon: Icons.edit_note_rounded,
                    color: scheme.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'CBT Sessions',
                    value: '0',
                    icon: Icons.self_improvement_rounded,
                    color: scheme.tertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Streak',
                    value: '0 days',
                    icon: Icons.local_fire_department_rounded,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Settings Section
            Text(
              'Settings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            _SettingsTile(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              subtitle: 'Manage your reminders',
              onTap: () {
                // TODO: Navigate to notifications settings
              },
            ),

            _SettingsTile(
              icon: Icons.palette_rounded,
              title: 'Appearance',
              subtitle: 'Theme and display settings',
              onTap: () {
                // TODO: Navigate to appearance settings
              },
            ),

            _SettingsTile(
              icon: Icons.privacy_tip_rounded,
              title: 'Privacy',
              subtitle: 'Data and privacy settings',
              onTap: () {
                // TODO: Navigate to privacy settings
              },
            ),

            _SettingsTile(
              icon: Icons.help_rounded,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () {
                // TODO: Navigate to help screen
              },
            ),

            const SizedBox(height: 24),

            // About Section
            _SettingsTile(
              icon: Icons.info_rounded,
              title: 'About Clarity',
              subtitle: 'Version 1.0.0',
              onTap: () {
                // TODO: Navigate to about screen
              },
            ),

            const SizedBox(height: 32),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Important',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This app does not provide medical advice. If you are in crisis, seek immediate help from a healthcare professional or emergency services.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
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
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: scheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: scheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}
