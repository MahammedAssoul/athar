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
import '../../../data/models/campaign.dart';
import 'donation_flow_cubit.dart';

/// Multi-step mock donation wizard.
class DonationFlowPage extends StatelessWidget {
  const DonationFlowPage({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DonationFlowCubit(campaignId)..loadCampaign(),
      child: const _FlowView(),
    );
  }
}

class _FlowView extends StatelessWidget {
  const _FlowView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.donateNow)),
      body: BlocBuilder<DonationFlowCubit, DonationFlowState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error) return const _ErrorView();
          if (state.campaign == null) return const SizedBox.shrink();
          final campaign = state.campaign!;
          return Column(
            children: [
              _StepHeader(step: state.step),
              Expanded(
                child: switch (state.step) {
                  DonationStep.amount => _AmountStep(campaign: campaign),
                  DonationStep.options => const _OptionsStep(),
                  DonationStep.summary => const _SummaryStep(),
                  DonationStep.payment => const _PaymentStep(),
                  DonationStep.result => const _ResultStep(),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});

  final DonationStep step;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final labels = [
      s.chooseAmount,
      s.recurringSadaqah,
      s.summary,
      s.payment,
      s.done,
    ];
    final index = step.index.clamp(0, labels.length - 1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: _StepDot(active: i == index, done: i < index),
            ),
          const SizedBox(width: AppSpacing.md),
          Text(labels[index], style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.active, required this.done});

  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done || active ? AppColors.primary : AppColors.border;
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
  }
}

// ── Step 1: Amount ───────────────────────────────────────
class _AmountStep extends StatelessWidget {
  const _AmountStep({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cubit = context.read<DonationFlowCubit>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          s.isAr ? campaign.titleAr : campaign.titleEn,
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(campaign.charityName, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.xl),
        Text(s.chooseAmount, style: AppTypography.headline),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final amount in kDonationAmounts)
              _AmountChip(
                label: '${Formatters.number(amount)} ${s.lyd}',
                selected: cubit.state.amount == amount,
                onTap: () => cubit.selectAmount(amount),
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
        const DemoDataBanner(),
      ],
    );
  }

  void _showCustomAmount(BuildContext context, DonationFlowCubit cubit) {
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
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: AppTypography.body.copyWith(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
    );
  }
}

// ── Step 2: Options ──────────────────────────────────────
class _OptionsStep extends StatelessWidget {
  const _OptionsStep();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cubit = context.read<DonationFlowCubit>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(s.recurringSadaqah, style: AppTypography.headline),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          onTap: () => cubit.toggleRecurring(!cubit.state.isRecurring),
          child: Row(
            children: [
              Icon(
                cubit.state.isRecurring
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: cubit.state.isRecurring
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.recurringSadaqah, style: AppTypography.title),
                    Text(
                      s.recurringSadaqahHint,
                      style: AppTypography.bodySecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _ContinueButton(label: s.next, onTap: () => cubit.continueToSummary()),
      ],
    );
  }
}

// ── Step 3: Summary ──────────────────────────────────────
class _SummaryStep extends StatelessWidget {
  const _SummaryStep();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cubit = context.read<DonationFlowCubit>();
    final campaign = cubit.state.campaign!;
    final amount = cubit.state.amount ?? 0;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(s.summary, style: AppTypography.headline),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              _SummaryRow(
                label: s.campaign,
                value: s.isAr ? campaign.titleAr : campaign.titleEn,
              ),
              _SummaryRow(label: s.charity, value: campaign.charityName),
              _SummaryRow(label: s.amount, value: Formatters.amount(amount)),
              _SummaryRow(
                label: s.recurringSadaqah,
                value: cubit.state.isRecurring ? s.recurring : s.oneTime,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _ContinueButton(label: s.next, onTap: () => cubit.continueToPayment()),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

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
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: onTap, child: Text(label)),
    );
  }
}

// ── Step 4: Payment ──────────────────────────────────────
class _PaymentStep extends StatelessWidget {
  const _PaymentStep();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cubit = context.read<DonationFlowCubit>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(s.paymentMethod, style: AppTypography.headline),
        const SizedBox(height: AppSpacing.md),
        for (final method in kPaymentMethods)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _PaymentMethodTile(
              method: method,
              selected: cubit.state.paymentMethod == method,
              onTap: () => cubit.selectPaymentMethod(method),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: AppColors.accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  s.mockPaymentNote,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final String method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final (label, icon) = switch (method) {
      'card' => (s.card, Icons.credit_card),
      'applePay' => (s.applePay, Icons.apple),
      _ => (s.bankTransfer, Icons.account_balance),
    };
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTypography.title)),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.primary : AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

// ── Step 5: Result ───────────────────────────────────────
class _ResultStep extends StatelessWidget {
  const _ResultStep();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cubit = context.read<DonationFlowCubit>();
    final state = cubit.state;

    if (state.processing) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.lg),
        ],
      );
    }

    if (state.paymentFailed) {
      return StateView(
        icon: Icons.error_outline,
        title: s.paymentFailed,
        subtitle: s.paymentFailedHint,
        actionLabel: s.retry,
        onAction: () => cubit.retryPayment(),
      );
    }

    if (state.result?.success == true && state.donationId != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 96, color: AppColors.success),
          const SizedBox(height: AppSpacing.lg),
          Text(s.donationSuccess, style: AppTypography.headline),
          const SizedBox(height: AppSpacing.sm),
          Text(s.donationSuccessHint, style: AppTypography.bodySecondary),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.receipt, arguments: state.donationId),
                    child: Text(s.viewReceipt),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(s.backHome),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return StateView(
      icon: Icons.error_outline,
      title: s.somethingWrong,
      subtitle: s.somethingWrongHint,
      actionLabel: s.retry,
      onAction: () => context.read<DonationFlowCubit>().loadCampaign(),
    );
  }
}
