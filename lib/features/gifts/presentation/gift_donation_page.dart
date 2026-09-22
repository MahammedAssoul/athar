import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/campaign.dart';
import 'gift_donation_cubit.dart';

/// Multi-step gift donation wizard.
class GiftDonationPage extends StatelessWidget {
  const GiftDonationPage({super.key, this.campaignId});

  final String? campaignId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GiftDonationCubit(campaignId: campaignId)..load(),
      child: const _GiftView(),
    );
  }
}

class _GiftView extends StatelessWidget {
  const _GiftView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.giftDonation)),
      body: BlocBuilder<GiftDonationCubit, GiftDonationState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error) return const _ErrorView();
          return switch (state.step) {
            GiftStep.campaign => _CampaignStep(campaigns: state.campaigns),
            GiftStep.amount => _AmountStep(campaign: state.campaign!),
            GiftStep.recipient => const _RecipientStep(),
            GiftStep.preview => const _PreviewStep(),
            GiftStep.result => const _ResultStep(),
          };
        },
      ),
    );
  }
}

// ── Step 1: Campaign ────────────────────────────────────
class _CampaignStep extends StatelessWidget {
  const _CampaignStep({required this.campaigns});

  final List<Campaign> campaigns;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    if (campaigns.isEmpty) {
      return StateView(
        icon: Icons.card_giftcard,
        title: s.noCampaigns,
        subtitle: s.noResultsHint,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(s.giftDonationHint, style: AppTypography.bodySecondary),
        const SizedBox(height: AppSpacing.lg),
        Text(s.chooseCategory, style: AppTypography.headline),
        const SizedBox(height: AppSpacing.md),
        for (final c in campaigns.take(8))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              onTap: () => context.read<GiftDonationCubit>().selectCampaign(c),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: AppColors.primary,
                    ),
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
                  const Icon(Icons.chevron_left, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Step 2: Amount ──────────────────────────────────────
class _AmountStep extends StatelessWidget {
  const _AmountStep({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cubit = context.read<GiftDonationCubit>();
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
            for (final amount in kGiftAmounts)
              ChoiceChip(
                label: Text('${Formatters.number(amount)} ${s.lyd}'),
                selected: cubit.state.amount == amount,
                onSelected: (_) => cubit.selectAmount(amount),
                selectedColor: AppColors.primary,
                labelStyle: AppTypography.body.copyWith(
                  color: cubit.state.amount == amount
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
      ],
    );
  }

  void _showCustomAmount(BuildContext context, GiftDonationCubit cubit) {
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

// ── Step 3: Recipient ───────────────────────────────────
class _RecipientStep extends StatelessWidget {
  const _RecipientStep();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cubit = context.read<GiftDonationCubit>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(s.recipientName, style: AppTypography.headline),
        const SizedBox(height: AppSpacing.md),
        TextField(
          onChanged: cubit.updateRecipientName,
          decoration: InputDecoration(
            hintText: s.recipientNameHint,
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(s.recipientContact, style: AppTypography.headline),
        const SizedBox(height: AppSpacing.md),
        TextField(
          onChanged: cubit.updateRecipientContact,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: s.recipientContactHint,
            prefixIcon: const Icon(Icons.contact_phone_outlined),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('${s.giftMessage} (${s.optional})', style: AppTypography.headline),
        const SizedBox(height: AppSpacing.md),
        TextField(
          onChanged: cubit.updateMessage,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: s.giftMessageHint,
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: cubit.state.canSubmit ? cubit.continueToPreview : null,
            child: Text(s.previewGift),
          ),
        ),
      ],
    );
  }
}

// ── Step 4: Preview ─────────────────────────────────────
class _PreviewStep extends StatelessWidget {
  const _PreviewStep();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cubit = context.read<GiftDonationCubit>();
    final state = cubit.state;
    final campaign = state.campaign!;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(s.giftPreview, style: AppTypography.headline),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              const Icon(
                Icons.card_giftcard,
                size: 56,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                s.isAr ? campaign.titleAr : campaign.titleEn,
                style: AppTypography.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(campaign.charityName, style: AppTypography.caption),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              _GiftRow(label: s.giftTo, value: state.recipientName),
              _GiftRow(
                label: s.recipientContact,
                value: state.recipientContact,
              ),
              _GiftRow(
                label: s.amount,
                value: Formatters.amount(state.amount!),
              ),
              if (state.message.trim().isNotEmpty)
                _GiftRow(
                  label: s.giftMessageLabel,
                  value: state.message.trim(),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.processing ? null : () => cubit.submit(),
            child: state.processing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(s.sendGift),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(onPressed: cubit.backToRecipient, child: Text(s.back)),
      ],
    );
  }
}

class _GiftRow extends StatelessWidget {
  const _GiftRow({required this.label, required this.value});

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

// ── Step 5: Result ──────────────────────────────────────
class _ResultStep extends StatelessWidget {
  const _ResultStep();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cubit = context.read<GiftDonationCubit>();
    final gift = cubit.state.gift;
    if (gift == null) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.xl),
        const Icon(Icons.card_giftcard, size: 96, color: AppColors.primary),
        const SizedBox(height: AppSpacing.lg),
        Text(
          s.giftSent,
          style: AppTypography.headline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          s.giftSentHint,
          style: AppTypography.bodySecondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppCard(
          child: Column(
            children: [
              _GiftRow(label: s.giftReference, value: gift.reference),
              _GiftRow(label: s.giftTo, value: gift.recipientName),
              _GiftRow(
                label: s.campaign,
                value: s.isAr ? gift.campaignTitleAr : gift.campaignTitleEn,
              ),
              _GiftRow(label: s.amount, value: Formatters.amount(gift.amount)),
              if (gift.message != null)
                _GiftRow(label: s.giftMessageLabel, value: gift.message!),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(s.done),
          ),
        ),
      ],
    );
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
      onAction: () => context.read<GiftDonationCubit>().load(),
    );
  }
}

/// Fixed quick-amount options for gift donations.
const List<double> kGiftAmounts = [10, 25, 50, 100, 250];
