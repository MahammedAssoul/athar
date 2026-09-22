import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/recurring_donation.dart';
import 'create_recurring_page.dart';
import 'recurring_donations_cubit.dart';

/// Recurring donations management screen.
class RecurringDonationsPage extends StatelessWidget {
  const RecurringDonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecurringDonationsCubit()..load(),
      child: const _RecurringView(),
    );
  }
}

class _RecurringView extends StatelessWidget {
  const _RecurringView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.recurringDonations)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCampaigns(context),
        icon: const Icon(Icons.add),
        label: Text(s.newRecurringDonation),
      ),
      body: BlocBuilder<RecurringDonationsCubit, RecurringDonationsState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error) {
            return StateView(
              icon: Icons.error_outline,
              title: s.somethingWrong,
              subtitle: s.somethingWrongHint,
              actionLabel: s.retry,
              onAction: () => context.read<RecurringDonationsCubit>().load(),
            );
          }
          if (state.items.isEmpty) {
            return StateView(
              icon: Icons.autorenew,
              title: s.noRecurringDonations,
              subtitle: s.noRecurringDonationsHint,
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<RecurringDonationsCubit>().load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  s.recurringDonationsHint,
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final item in state.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _RecurringCard(
                      item: item,
                      busy: state.busyId == item.id,
                      onPause: () => _confirmPause(context, item),
                      onResume: () => _resume(context, item),
                      onCancel: () => _confirmCancel(context, item),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                const DemoDataBanner(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openCampaigns(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CreateRecurringPage()),
    );
  }

  Future<void> _confirmPause(
    BuildContext context,
    RecurringDonation item,
  ) async {
    final s = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.pause),
        content: Text(s.confirmPauseRecurring),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(s.pause),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<RecurringDonationsCubit>().pause(item.id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.recurringPaused)));
    }
  }

  Future<void> _resume(BuildContext context, RecurringDonation item) async {
    final s = AppStrings.of(context);
    await context.read<RecurringDonationsCubit>().resume(item.id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.recurringResumed)));
    }
  }

  Future<void> _confirmCancel(
    BuildContext context,
    RecurringDonation item,
  ) async {
    final s = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.cancelRecurring),
        content: Text(s.confirmCancelRecurring),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(s.close),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(s.cancelRecurring),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<RecurringDonationsCubit>().cancel(item.id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.recurringCancelled)));
    }
  }
}

class _RecurringCard extends StatelessWidget {
  const _RecurringCard({
    required this.item,
    required this.busy,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
  });

  final RecurringDonation item;
  final bool busy;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cancelled = item.status.isCancelled;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.autorenew, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.isAr ? item.campaignTitleAr : item.campaignTitleEn,
                      style: AppTypography.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.isAr ? item.charityNameAr : item.charityNameEn,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatusBadge(status: item.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Info(label: s.amount, value: Formatters.amount(item.amount)),
              _Info(
                label: s.frequency,
                value: _frequencyLabel(s, item.frequency),
              ),
              _Info(label: s.startDate, value: _dateLabel(item.startDate)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (!cancelled)
            Row(
              children: [
                if (item.status.isActive) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy ? null : onPause,
                      icon: const Icon(Icons.pause_circle_outline),
                      label: Text(s.pause),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ] else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy ? null : onResume,
                      icon: const Icon(Icons.play_circle_outline),
                      label: Text(s.resume),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: TextButton.icon(
                    onPressed: busy ? null : onCancel,
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.error,
                    ),
                    label: Text(
                      s.cancelRecurring,
                      style: AppTypography.button.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Text(s.statusCancelled, style: AppTypography.caption),
        ],
      ),
    );
  }

  static String _frequencyLabel(AppStrings s, RecurringFrequency frequency) {
    return switch (frequency) {
      RecurringFrequency.daily => s.daily,
      RecurringFrequency.weekly => s.weekly,
      RecurringFrequency.monthly => s.monthly,
    };
  }

  static String _dateLabel(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RecurringStatus status;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final (label, color) = switch (status) {
      RecurringStatus.active => (s.recurringStatusActive, AppColors.success),
      RecurringStatus.paused => (s.statusPaused, AppColors.warning),
      RecurringStatus.cancelled => (s.statusCancelled, AppColors.error),
    };
    return AppBadge(label: label, color: color);
  }
}
