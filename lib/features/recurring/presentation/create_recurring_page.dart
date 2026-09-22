import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/recurring_donation.dart';
import 'create_recurring_cubit.dart';

/// Wizard to create a new recurring donation.
class CreateRecurringPage extends StatelessWidget {
  const CreateRecurringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateRecurringCubit()..load(),
      child: const _CreateRecurringView(),
    );
  }
}

class _CreateRecurringView extends StatelessWidget {
  const _CreateRecurringView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.newRecurringDonation)),
      body: BlocBuilder<CreateRecurringCubit, CreateRecurringState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error) {
            return StateView(
              icon: Icons.error_outline,
              title: s.somethingWrong,
              subtitle: s.somethingWrongHint,
              actionLabel: s.retry,
              onAction: () => context.read<CreateRecurringCubit>().load(),
            );
          }
          final cubit = context.read<CreateRecurringCubit>();
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(s.chooseCategory, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.md),
              _CampaignPicker(
                campaigns: state.campaigns,
                selectedId: state.campaign?.id,
                onSelected: cubit.selectCampaign,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(s.chooseAmount, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  for (final amount in kRecurringAmounts)
                    ChoiceChip(
                      label: Text('${Formatters.number(amount)} ${s.lyd}'),
                      selected: state.amount == amount,
                      onSelected: (_) => cubit.selectAmount(amount),
                      selectedColor: AppColors.primary,
                      labelStyle: AppTypography.body.copyWith(
                        color: state.amount == amount
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      showCheckmark: false,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(s.frequency, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<RecurringFrequency>(
                segments: [
                  ButtonSegment(
                    value: RecurringFrequency.daily,
                    label: Text(s.daily),
                  ),
                  ButtonSegment(
                    value: RecurringFrequency.weekly,
                    label: Text(s.weekly),
                  ),
                  ButtonSegment(
                    value: RecurringFrequency.monthly,
                    label: Text(s.monthly),
                  ),
                ],
                selected: {state.frequency},
                onSelectionChanged: (selection) =>
                    cubit.selectFrequency(selection.first),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(s.startDate, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                onTap: () => cubit.selectStartDate(context),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        _dateLabel(state.startDate ?? DateTime.now()),
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_left, color: AppColors.textMuted),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.canSubmit ? () => _submit(context) : null,
                  child: Text(s.confirm),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const DemoDataBanner(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final s = AppStrings.of(context);
    final cubit = context.read<CreateRecurringCubit>();
    final ok = await cubit.create();
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.recurringCreated)));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.somethingWrong)));
    }
  }

  static String _dateLabel(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

class _CampaignPicker extends StatelessWidget {
  const _CampaignPicker({
    required this.campaigns,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Campaign> campaigns;
  final String? selectedId;
  final ValueChanged<Campaign> onSelected;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    if (campaigns.isEmpty) {
      return Text(s.noCampaigns, style: AppTypography.bodySecondary);
    }
    return Column(
      children: [
        for (final c in campaigns.take(6))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              onTap: () => onSelected(c),
              child: Row(
                children: [
                  Icon(
                    selectedId == c.id
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selectedId == c.id
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.isAr ? c.titleAr : c.titleEn,
                          style: AppTypography.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(c.charityName, style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Fixed quick-amount options for recurring donations.
const List<double> kRecurringAmounts = [10, 25, 50, 100, 250];
