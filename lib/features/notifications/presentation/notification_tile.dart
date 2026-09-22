import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/app_notification.dart';

/// A notification tile with read/unread styling.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      color: notification.isRead ? AppColors.surface : AppColors.primaryLight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Icon(type: notification.type),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.isAr ? notification.titleAr : notification.titleEn,
                  style: AppTypography.title.copyWith(
                    fontWeight: notification.isRead
                        ? FontWeight.w600
                        : FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.isAr ? notification.bodyAr : notification.bodyEn,
                  style: AppTypography.bodySecondary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _dateLabel(notification.date),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(Icons.circle, size: 10, color: AppColors.primary),
            ),
        ],
      ),
    );
  }

  static String _dateLabel(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} $hour:$minute';
  }
}

class _Icon extends StatelessWidget {
  const _Icon({required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      NotificationType.donation => (Icons.favorite, AppColors.primary),
      NotificationType.campaign => (Icons.campaign, AppColors.accent),
      NotificationType.recurring => (Icons.autorenew, AppColors.primary),
      NotificationType.impact => (Icons.insights, AppColors.verified),
      NotificationType.system => (Icons.settings, AppColors.textMuted),
      NotificationType.general => (Icons.notifications, AppColors.verified),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }
}
