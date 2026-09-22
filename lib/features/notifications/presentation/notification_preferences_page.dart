import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/notification_preferences.dart';
import 'notification_preferences_cubit.dart';

/// Notification preferences screen.
class NotificationPreferencesPage extends StatelessWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationPreferencesCubit()..load(),
      child: const _PreferencesView(),
    );
  }
}

class _PreferencesView extends StatelessWidget {
  const _PreferencesView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.notificationPreferences)),
      body:
          BlocBuilder<
            NotificationPreferencesCubit,
            NotificationPreferencesState
          >(
            builder: (context, state) {
              if (state.loading) return const LoadingView();
              if (state.error) {
                return StateView(
                  icon: Icons.error_outline,
                  title: s.somethingWrong,
                  subtitle: s.somethingWrongHint,
                  actionLabel: s.retry,
                  onAction: () =>
                      context.read<NotificationPreferencesCubit>().load(),
                );
              }
              final prefs = state.preferences;
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text(
                    s.notificationPreferencesHint,
                    style: AppTypography.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PreferenceTile(
                    icon: Icons.favorite,
                    label: s.prefDonationSuccess,
                    value: prefs.donationSuccess,
                    onChanged: (v) => context
                        .read<NotificationPreferencesCubit>()
                        .set(NotificationPreferenceKey.donationSuccess, v),
                  ),
                  _PreferenceTile(
                    icon: Icons.flag,
                    label: s.prefCampaignCompleted,
                    value: prefs.campaignCompleted,
                    onChanged: (v) => context
                        .read<NotificationPreferencesCubit>()
                        .set(NotificationPreferenceKey.campaignCompleted, v),
                  ),
                  _PreferenceTile(
                    icon: Icons.campaign,
                    label: s.prefCampaignUpdates,
                    value: prefs.campaignUpdates,
                    onChanged: (v) => context
                        .read<NotificationPreferencesCubit>()
                        .set(NotificationPreferenceKey.campaignUpdates, v),
                  ),
                  _PreferenceTile(
                    icon: Icons.autorenew,
                    label: s.prefRecurringDonation,
                    value: prefs.recurringDonation,
                    onChanged: (v) => context
                        .read<NotificationPreferencesCubit>()
                        .set(NotificationPreferenceKey.recurringDonation, v),
                  ),
                  _PreferenceTile(
                    icon: Icons.insights,
                    label: s.prefImpactUpdates,
                    value: prefs.impactUpdates,
                    onChanged: (v) => context
                        .read<NotificationPreferencesCubit>()
                        .set(NotificationPreferenceKey.impactUpdates, v),
                  ),
                  _PreferenceTile(
                    icon: Icons.settings,
                    label: s.prefSystemMessages,
                    value: prefs.systemMessages,
                    onChanged: (v) => context
                        .read<NotificationPreferencesCubit>()
                        .set(NotificationPreferenceKey.systemMessages, v),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const DemoDataBanner(),
                ],
              );
            },
          ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Switch(
              value: value,
              activeThumbColor: AppColors.primary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
