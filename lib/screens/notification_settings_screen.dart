import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';
import '../state/notification_state.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final settings = ref.watch(notificationProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, settings)),
        SliverToBoxAdapter(child: _buildMasterToggle(context, settings)),
        if (settings.enabled) ...[
          SliverToBoxAdapter(child: _buildNotificationTypes(context, settings)),
          SliverToBoxAdapter(child: _buildGeneralSettings(context, settings)),
          SliverToBoxAdapter(child: _buildAdvancedSettings(context, settings)),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, NotificationSettings settings) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_rounded,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stay Connected',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gentle reminders to support your mental wellness journey',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMasterToggle(
    BuildContext context,
    NotificationSettings settings,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: settings.enabled
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.outline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              settings.enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: settings.enabled
                  ? colorScheme.primary
                  : colorScheme.outline,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Notifications',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  settings.enabled
                      ? 'Notifications are active'
                      : 'All notifications are disabled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: settings.enabled,
            onChanged: (value) {
              ref
                  .read(notificationProvider.notifier)
                  .toggleNotifications(value);
            },
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypes(
    BuildContext context,
    NotificationSettings settings,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Notification Types',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...NotificationType.values.map(
            (type) => _buildNotificationTypeTile(context, type, settings),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeTile(
    BuildContext context,
    NotificationType type,
    NotificationSettings settings,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = settings.typeSettings[type] ?? false;
    final frequency = settings.frequencies[type] ?? NotificationFrequency.never;
    final time =
        settings.scheduledTimes[type] ?? const TimeOfDay(hour: 9, minute: 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isEnabled
            ? type.color.withValues(alpha: 0.05)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? type.color.withValues(alpha: 0.2)
              : colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isEnabled
                ? type.color.withValues(alpha: 0.1)
                : colorScheme.outline.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            type.icon,
            color: isEnabled ? type.color : colorScheme.outline,
            size: 20,
          ),
        ),
        title: Text(
          type.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isEnabled
                ? colorScheme.onSurface
                : colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        subtitle: Text(
          isEnabled
              ? '${frequency.displayName} • ${NotificationService.instance.formatTimeOfDay(time)}'
              : type.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Switch.adaptive(
          value: isEnabled,
          onChanged: (value) {
            ref
                .read(notificationProvider.notifier)
                .toggleNotificationType(type, value);
          },
          activeColor: type.color,
        ),
        children: isEnabled
            ? [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      _buildFrequencySelector(context, type, frequency),
                      const SizedBox(height: 12),
                      _buildTimeSelector(context, type, time),
                    ],
                  ),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildFrequencySelector(
    BuildContext context,
    NotificationType type,
    NotificationFrequency currentFrequency,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NotificationFrequency.values
              .where((freq) => freq != NotificationFrequency.never)
              .map((frequency) {
                final isSelected = frequency == currentFrequency;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(notificationProvider.notifier)
                        .updateNotificationFrequency(type, frequency);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? type.color.withValues(alpha: 0.1)
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? type.color
                            : colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      frequency.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? type.color
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              })
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    NotificationType type,
    TimeOfDay currentTime,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: currentTime,
            );
            if (time != null) {
              ref
                  .read(notificationProvider.notifier)
                  .updateNotificationTime(type, time);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: type.color.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded, color: type.color, size: 18),
                const SizedBox(width: 8),
                Text(
                  NotificationService.instance.formatTimeOfDay(currentTime),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: type.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralSettings(
    BuildContext context,
    NotificationSettings settings,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'General Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.volume_up_rounded,
            title: 'Sound',
            subtitle: 'Play notification sounds',
            value: settings.soundEnabled,
            onChanged: (value) =>
                ref.read(notificationProvider.notifier).toggleSound(value),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.vibration_rounded,
            title: 'Vibration',
            subtitle: 'Vibrate on notifications',
            value: settings.vibrationEnabled,
            onChanged: (value) =>
                ref.read(notificationProvider.notifier).toggleVibration(value),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_rounded,
            title: 'Show on Lock Screen',
            subtitle: 'Display notifications when locked',
            value: settings.showOnLockScreen,
            onChanged: (value) => ref
                .read(notificationProvider.notifier)
                .toggleShowOnLockScreen(value),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings(
    BuildContext context,
    NotificationSettings settings,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Advanced Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.bedtime_rounded,
            title: 'Quiet Hours',
            subtitle: settings.quietHoursEnabled
                ? '${NotificationService.instance.formatTimeOfDay(settings.quietHoursStart)} - ${NotificationService.instance.formatTimeOfDay(settings.quietHoursEnd)}'
                : 'Disable notifications during specific hours',
            value: settings.quietHoursEnabled,
            onChanged: (value) =>
                ref.read(notificationProvider.notifier).toggleQuietHours(value),
            onTap: settings.quietHoursEnabled
                ? () => _showQuietHoursDialog(context, settings)
                : null,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.weekend_rounded,
            title: 'Weekend Schedule',
            subtitle: 'Different notification times for weekends',
            value: settings.weekendDifferentSchedule,
            onChanged: (value) => ref
                .read(notificationProvider.notifier)
                .toggleWeekendSchedule(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.outline.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: value ? colorScheme.primary : colorScheme.outline,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.primary,
      ),
      onTap: onTap,
    );
  }

  void _showQuietHoursDialog(
    BuildContext context,
    NotificationSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => _QuietHoursDialog(
        startTime: settings.quietHoursStart,
        endTime: settings.quietHoursEnd,
        onSave: (start, end) {
          ref.read(notificationProvider.notifier).updateQuietHours(start, end);
        },
      ),
    );
  }
}

class _QuietHoursDialog extends StatefulWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function(TimeOfDay start, TimeOfDay end) onSave;

  const _QuietHoursDialog({
    required this.startTime,
    required this.endTime,
    required this.onSave,
  });

  @override
  State<_QuietHoursDialog> createState() => _QuietHoursDialogState();
}

class _QuietHoursDialogState extends State<_QuietHoursDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.startTime;
    _endTime = widget.endTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Quiet Hours'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Set the hours when you don\'t want to receive notifications.',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (time != null) {
                          setState(() {
                            _startTime = time;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          NotificationService.instance.formatTimeOfDay(
                            _startTime,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Time',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                        );
                        if (time != null) {
                          setState(() {
                            _endTime = time;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          NotificationService.instance.formatTimeOfDay(
                            _endTime,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSave(_startTime, _endTime);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
