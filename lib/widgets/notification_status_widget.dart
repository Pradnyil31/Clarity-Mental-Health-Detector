import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/notification_state.dart';
import '../models/notification_settings.dart';

class NotificationStatusWidget extends ConsumerWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const NotificationStatusWidget({
    super.key,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = ref.watch(notificationProvider);
    final summary = ref.watch(notificationSummaryProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: settings.enabled
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.outline.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: settings.enabled
                ? colorScheme.primary.withValues(alpha: 0.2)
                : colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: settings.enabled
                    ? colorScheme.primary.withValues(alpha: 0.1)
                    : colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                settings.enabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                color: settings.enabled
                    ? colorScheme.primary
                    : colorScheme.outline,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (showDetails && settings.enabled) ...[
                    const SizedBox(height: 8),
                    _buildNotificationTypeChips(context, settings),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTypeChips(
    BuildContext context,
    NotificationSettings settings,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final enabledTypes = NotificationType.values
        .where((type) => settings.typeSettings[type] ?? false)
        .take(3) // Show only first 3 to avoid overflow
        .toList();

    if (enabledTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...enabledTypes.map(
          (type) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: type.color.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              type.displayName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: type.color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (settings.typeSettings.values.where((enabled) => enabled).length > 3)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              '+${settings.typeSettings.values.where((enabled) => enabled).length - 3}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class NotificationQuickToggle extends ConsumerWidget {
  final NotificationType type;
  final bool compact;

  const NotificationQuickToggle({
    super.key,
    required this.type,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = ref.watch(notificationProvider);
    final isEnabled =
        settings.enabled && (settings.typeSettings[type] ?? false);

    return GestureDetector(
      onTap: () {
        ref
            .read(notificationProvider.notifier)
            .toggleNotificationType(type, !isEnabled);
      },
      child: Container(
        padding: EdgeInsets.all(compact ? 8 : 12),
        decoration: BoxDecoration(
          color: isEnabled
              ? type.color.withValues(alpha: 0.1)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(compact ? 8 : 12),
          border: Border.all(
            color: isEnabled
                ? type.color.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: compact
            ? Icon(
                type.icon,
                color: isEnabled ? type.color : colorScheme.outline,
                size: 20,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type.icon,
                    color: isEnabled ? type.color : colorScheme.outline,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.displayName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isEnabled
                          ? type.color
                          : colorScheme.onSurface.withValues(alpha: 0.6),
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

class NotificationReminder extends ConsumerWidget {
  final NotificationType type;
  final String? customMessage;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const NotificationReminder({
    super.key,
    required this.type,
    this.customMessage,
    this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = ref.watch(notificationProvider);

    if (!settings.enabled || !(settings.typeSettings[type] ?? false)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            type.color.withValues(alpha: 0.1),
            type.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: type.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(type.icon, color: type.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: type.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customMessage ?? type.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: type.color,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
              child: const Text('Open'),
            ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
