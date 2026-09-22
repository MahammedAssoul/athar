import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/campaign_enums.dart';

/// A reusable campaign card with image, progress and donate button.
class CampaignCard extends StatelessWidget {
  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onTap,
    required this.onDonate,
    this.compact = false,
  });

  final Campaign campaign;
  final VoidCallback onTap;
  final VoidCallback onDonate;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CampaignImage(campaign: campaign, height: compact ? 110 : 140),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.isAr ? campaign.titleAr : campaign.titleEn,
                        style: AppTypography.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  s.isAr ? campaign.charityName : campaign.charityName,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.md),
                CampaignProgressBar(progress: campaign.progress),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Amount(
                      label: s.collected,
                      value: Formatters.amount(campaign.collectedAmount),
                    ),
                    _Amount(
                      label: s.target,
                      value: Formatters.amount(campaign.targetAmount),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onDonate,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: Text(s.donateNow),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignImage extends StatelessWidget {
  const _CampaignImage({required this.campaign, required this.height});

  final Campaign campaign;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (campaign.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
        child: Image.network(
          campaign.imageUrl,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => CampaignImagePlaceholder(height: height),
        ),
      );
    }
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.lg),
      ),
      child: CampaignImagePlaceholder(
        height: height,
        icon: _iconFor(campaign.category),
      ),
    );
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

class _Amount extends StatelessWidget {
  const _Amount({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        Text(
          value,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
