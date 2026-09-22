import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/common_widgets.dart';
import 'notification_tile.dart';
import 'notifications_cubit.dart';

/// Notifications screen.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit()..load(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.notifications),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.notificationPreferences),
            tooltip: s.notificationPreferences,
            icon: const Icon(Icons.tune),
          ),
          TextButton(
            onPressed: () => context.read<NotificationsCubit>().markAllAsRead(),
            child: Text(s.markAllRead),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error) {
            return StateView(
              icon: Icons.error_outline,
              title: s.somethingWrong,
              subtitle: s.somethingWrongHint,
              actionLabel: s.retry,
              onAction: () => context.read<NotificationsCubit>().load(),
            );
          }
          if (state.notifications.isEmpty) {
            return StateView(
              icon: Icons.notifications_none,
              title: s.noNotifications,
              subtitle: s.noNotificationsHint,
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<NotificationsCubit>().load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final n in state.notifications)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: NotificationTile(
                      notification: n,
                      onTap: () =>
                          context.read<NotificationsCubit>().markAsRead(n.id),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
