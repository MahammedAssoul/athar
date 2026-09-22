import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/campaign_enums.dart';
import 'quick_donation_cubit.dart';

/// Universal "تبرع سريع" quick donation screen.
class QuickDonationPage extends StatelessWidget {
  const QuickDonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuickDonationCubit()..load(),
      child: const _QuickDonationView(),
    );
  }
}

class _QuickDonationView extends StatelessWidget {
  const _QuickDonationView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.quickDonation)),
      body: BlocBuilder<QuickDonationCubit, QuickDonationState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error) {
            return StateView(
              icon: Icons.error_outline,
              title: s.somethingWrong,
              subtitle: s.somethingWrongHint,
              actionLabel: s.retry,
              onAction: () => context.read<QuickDonationCubit>().load(),
            );
          }
          if (state.donation != null) return const _SuccessView();
          final cubit = context.read<QuickDonationCubit>();
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(s.quickDonationHint, style: AppTypography.bodySecondary),
              const SizedBox(height: AppSpacing.xl),
              Text(s.chooseCategory, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final entry in _categories)
                    _CategoryChip(
                      label: entry.$1,
                      icon: entry.$2,
                      category: entry.$3,
                      selected: state.category == entry.$3,
                      onTap: () => cubit.selectCategory(entry.$3),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(s.chooseQuickAmount, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  for (final amount in kQuickAmounts)
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
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => _showCustomAmount(context, cubit),
                icon: const Icon(Icons.edit),
                label: Text(s.otherAmount),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.canSubmit && !state.processing
                      ? () => _donate(context)
                      : null,
                  child: state.processing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(s.quickDonateNow),
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

  Future<void> _donate(BuildContext context) async {
    final s = AppStrings.of(context);
    final cubit = context.read<QuickDonationCubit>();
    final ok = await cubit.donate();
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.somethingWrong)));
    }
  }

  void _showCustomAmount(BuildContext context, QuickDonationCubit cubit) {
    final s = AppStrings.of(context);
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.otherAmount),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: s.enterAmount),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value != null && value > 0) {
                cubit.selectAmount(value);
              }
              Navigator.of(dialogContext).pop();
            },
            child: Text(s.confirm),
          ),
        ],
      ),
    );
  }

  static final List<(String, IconData, CampaignCategory)> _categories = [
    ('علاج', Icons.medical_services, CampaignCategory.treatment),
    ('غذاء', Icons.lunch_dining, CampaignCategory.food),
    ('سكن', Icons.home, CampaignCategory.housing),
    ('تعليم', Icons.school, CampaignCategory.education),
    ('أيتام', Icons.child_care, CampaignCategory.orphans),
    ('أسر محتاجة', Icons.family_restroom, CampaignCategory.families),
    ('تفريج كربة', Icons.volunteer_activism, CampaignCategory.relief),
    ('مساجد', Icons.mosque, CampaignCategory.mosques),
    ('مياه', Icons.water_drop, CampaignCategory.water),
    (
      'تسديد ديون',
      Icons.account_balance_wallet_outlined,
      CampaignCategory.debtRelief,
    ),
    ('طوارئ', Icons.priority_high, CampaignCategory.emergency),
    ('مشاريع عامة', Icons.volunteer_activism, CampaignCategory.general),
  ];
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final CampaignCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? Colors.white : AppColors.primary,
      ),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: AppTypography.bodySecondary.copyWith(
        color: selected ? Colors.white : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      side: const BorderSide(color: AppColors.border),
      showCheckmark: false,
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cubit = context.read<QuickDonationCubit>();
    final donation = cubit.state.donation!;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.xl),
        const Icon(Icons.check_circle, size: 96, color: AppColors.success),
        const SizedBox(height: AppSpacing.lg),
        Text(
          s.quickDonationSuccess,
          style: AppTypography.headline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          s.donationSuccessHint,
          style: AppTypography.bodySecondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppCard(
          child: Column(
            children: [
              _Row(
                label: s.campaign,
                value: s.isAr
                    ? donation.campaignTitleAr
                    : donation.campaignTitleEn,
              ),
              _Row(
                label: s.charity,
                value: s.isAr ? donation.charityNameAr : donation.charityNameEn,
              ),
              _Row(label: s.amount, value: Formatters.amount(donation.amount)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.receipt, arguments: donation.id),
            child: Text(s.viewReceipt),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.done),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTypography.bodySecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fixed quick-amount options for quick donations.
const List<double> kQuickAmounts = [10, 25, 50, 100, 250];
