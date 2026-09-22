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
import '../../../data/di/app_dependencies.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/campaign_enums.dart';
import '../../../data/models/charity.dart';
import 'campaign_details_cubit.dart';

/// Full campaign details page.
class CampaignDetailsPage extends StatelessWidget {
  const CampaignDetailsPage({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CampaignDetailsCubit(campaignId)..load(),
      child: const _DetailsView(),
    );
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.aboutCampaign),
        actions: [
          BlocBuilder<CampaignDetailsCubit, CampaignDetailsState>(
            builder: (context, state) {
              final cubit = context.read<CampaignDetailsCubit>();
              return IconButton(
                onPressed: state.campaign == null
                    ? null
                    : () => cubit.toggleFavorite(),
                tooltip: state.isFavorite
                    ? s.removeFromFavorites
                    : s.addToFavorites,
                icon: Icon(
                  state.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: state.isFavorite ? AppColors.error : null,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CampaignDetailsCubit, CampaignDetailsState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error) return const _ErrorView();
          final campaign = state.campaign;
          if (campaign == null) return const SizedBox.shrink();
          return _buildContent(context, campaign, state.charity);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Campaign campaign,
    Charity? charity,
  ) {
    final s = AppStrings.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _HeaderImage(campaign: campaign),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.isAr ? campaign.titleAr : campaign.titleEn,
                            style: AppTypography.headline,
                          ),
                        ),
                        if (campaign.isUrgent)
                          const AppBadge(
                            label: 'عاجل',
                            color: AppColors.error,
                            icon: Icons.priority_high,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _StatusBadge(status: campaign.status),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(icon: Icons.handshake, text: campaign.charityName),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      text: campaign.location,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ProgressCard(campaign: campaign),
                    const SizedBox(height: AppSpacing.lg),
                    if (charity != null) ...[
                      _CharityCard(charity: charity),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    Text(s.aboutCampaign, style: AppTypography.title),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      s.isAr ? campaign.descriptionAr : campaign.descriptionEn,
                      style: AppTypography.bodySecondary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const DemoDataBanner(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ],
          ),
        ),
        _BottomBar(
          onDonate: () => _openDonationFlow(context, campaign.id),
          onShare: () => _share(context, campaign),
          onGift: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.giftDonation, arguments: campaign.id),
        ),
      ],
    );
  }

  void _openDonationFlow(BuildContext context, String id) {
    Navigator.of(context).pushNamed(AppRoutes.donationFlow, arguments: id);
  }

  Future<void> _share(BuildContext context, Campaign campaign) async {
    final s = AppStrings.of(context);
    final result = await AppDependencies.instance.shareService.shareCampaign(
      campaign,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? '${s.shareCampaign}: ${s.isAr ? campaign.titleAr : campaign.titleEn}'
              : s.somethingWrong,
        ),
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  const _HeaderImage({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(campaign.category);
    if (campaign.imageUrl.isNotEmpty) {
      return Image.network(
        campaign.imageUrl,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            CampaignImagePlaceholder(height: 220, icon: icon),
      );
    }
    return CampaignImagePlaceholder(height: 220, icon: icon);
  }

  static IconData _iconFor(CampaignCategory category) {
    switch (category) {
      case CampaignCategory.treatment:
        return Icons.medical_services;
      case CampaignCategory.food:
        return Icons.lunch_dining;
      case CampaignCategory.housing:
        return Icons.home;
      case CampaignCategory.education:
        return Icons.school;
      case CampaignCategory.orphans:
        return Icons.child_care;
      case CampaignCategory.families:
        return Icons.family_restroom;
      case CampaignCategory.relief:
        return Icons.volunteer_activism;
      case CampaignCategory.mosques:
        return Icons.mosque;
      case CampaignCategory.water:
        return Icons.water_drop;
      case CampaignCategory.debtRelief:
        return Icons.account_balance_wallet_outlined;
      case CampaignCategory.emergency:
        return Icons.priority_high;
      case CampaignCategory.general:
        return Icons.volunteer_activism;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.bodySecondary)),
        ],
      ),
    );
  }
}

/// A badge showing the campaign lifecycle status.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CampaignStatus status;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final (label, color) = switch (status) {
      CampaignStatus.draft => (s.statusDraft, AppColors.textMuted),
      CampaignStatus.submitted => (s.statusSubmitted, AppColors.accent),
      CampaignStatus.underReview => (s.statusUnderReview, AppColors.accent),
      CampaignStatus.approved => (s.statusApproved, AppColors.primary),
      CampaignStatus.published => (s.statusPublished, AppColors.success),
      CampaignStatus.completed => (s.statusCompleted, AppColors.success),
      CampaignStatus.rejected => (s.statusRejected, AppColors.error),
      CampaignStatus.suspended => (s.statusSuspended, AppColors.error),
    };
    return AppBadge(label: label, color: color);
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final days = campaign.endDate.difference(DateTime.now()).inDays;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.progress, style: AppTypography.bodySecondary),
              Text(
                '${(campaign.progress * 100).toStringAsFixed(0)}%',
                style: AppTypography.title.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          CampaignProgressBar(progress: campaign.progress),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatCell(
                label: s.target,
                value: Formatters.amount(campaign.targetAmount),
              ),
              _StatCell(
                label: s.collected,
                value: Formatters.amount(campaign.collectedAmount),
              ),
              _StatCell(
                label: s.remaining,
                value: Formatters.amount(campaign.remainingAmount),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatCell(
                label: s.beneficiariesCount,
                value: Formatters.number(campaign.beneficiaryCount),
              ),
              _StatCell(
                label: s.deadline,
                value: days >= 0
                    ? '${Formatters.number(days)} ${s.daysLeft}'
                    : s.statusClosed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

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

class _CharityCard extends StatelessWidget {
  const _CharityCard({required this.charity});

  final Charity charity;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AppCard(
      child: Row(
        children: [
          const InitialAvatar(name: 'ج', radius: 26),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        s.isAr ? charity.nameAr : charity.nameEn,
                        style: AppTypography.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (charity.isVerified) ...[
                      const SizedBox(width: AppSpacing.sm),
                      const AppBadge(
                        label: 'موثقة',
                        color: AppColors.verified,
                        icon: Icons.verified,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${s.charities}: ${charity.campaignCount} · ${charity.location}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.onDonate,
    required this.onShare,
    required this.onGift,
  });

  final VoidCallback onDonate;
  final VoidCallback onShare;
  final VoidCallback onGift;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        child: Row(
          children: [
            OutlinedButton(
              onPressed: onShare,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(56, 52),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              child: const Icon(Icons.share),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton(
              onPressed: onGift,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(56, 52),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              child: const Icon(Icons.card_giftcard),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: onDonate,
                child: Text(s.donateNow),
              ),
            ),
          ],
        ),
      ),
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
      onAction: () => context.read<CampaignDetailsCubit>().load(),
    );
  }
}
