import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/donation.dart';
import '../../../data/models/platform_stats.dart';
import '../../campaigns/presentation/campaign_card.dart';
import '../../donations/presentation/donation_tile.dart';
import '../../notifications/presentation/notification_tile.dart';

/// Shared widgets for the home screen.
class HomeWidgets {
  HomeWidgets._();
}

/// Header with greeting, notification icon and avatar.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    required this.unreadCount,
    required this.onNotificationsTap,
  });

  final String userName;
  final int unreadCount;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.greeting(userName), style: AppTypography.headline),
              Text(s.appTagline, style: AppTypography.bodySecondary),
            ],
          ),
        ),
        // Notification icon with an unread-count badge.
        // `Badge` positions the label correctly on the icon corner
        // (unlike a manual Stack/Positioned which can clip or overlap).
        Badge(
          isLabelVisible: unreadCount > 0,
          label: Text('$unreadCount'),
          backgroundColor: AppColors.error,
          textColor: Colors.white,
          child: IconButton(
            onPressed: onNotificationsTap,
            tooltip: s.navNotifications,
            icon: const Icon(Icons.notifications_none),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const InitialAvatar(name: 'محمد', radius: 24),
      ],
    );
  }
}

/// Large donation CTA card.
class HomeCtaCard extends StatelessWidget {
  const HomeCtaCard({super.key, required this.onDonate});

  final VoidCallback onDonate;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.homeCtaTitle,
            style: AppTypography.headline.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            s.homeCtaSubtitle,
            style: AppTypography.bodySecondary.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: onDonate,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  s.donateNow,
                  style: AppTypography.button.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal list of quick-donate category chips.
class QuickDonateRow extends StatelessWidget {
  const QuickDonateRow({super.key, required this.onCategoryTap});

  final VoidCallback onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: s.quickDonate),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 96,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final entry in _categories)
                _CategoryChip(
                  label: entry.$1,
                  icon: entry.$2,
                  onTap: onCategoryTap,
                ),
            ],
          ),
        ),
      ],
    );
  }

  static final List<(String, IconData)> _categories = [
    ('صدقة', Icons.volunteer_activism),
    ('زكاة', Icons.account_balance_wallet),
    ('علاج', Icons.medical_services),
    ('غذاء', Icons.lunch_dining),
    ('سكن', Icons.home),
    ('كفالة يتيم', Icons.child_care),
    ('تفريج كربة', Icons.volunteer_activism),
    ('تعليم', Icons.school),
    ('مساعدة أسر', Icons.family_restroom),
  ];
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: 84,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: AppColors.primary),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal scrolling list of featured campaign cards.
class FeaturedCampaignsRow extends StatelessWidget {
  const FeaturedCampaignsRow({
    super.key,
    required this.campaigns,
    required this.onCampaignTap,
    required this.onDonateTap,
    required this.onViewAll,
  });

  final List<Campaign> campaigns;
  final void Function(Campaign) onCampaignTap;
  final void Function(Campaign) onDonateTap;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: s.featuredCampaigns,
          actionLabel: s.viewAll,
          onAction: onViewAll,
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 350,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final c in campaigns)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: SizedBox(
                    width: 260,
                    child: CampaignCard(
                      campaign: c,
                      onTap: () => onCampaignTap(c),
                      onDonate: () => onDonateTap(c),
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

/// Vertical list of urgent campaign cards.
class UrgentCampaignsList extends StatelessWidget {
  const UrgentCampaignsList({
    super.key,
    required this.campaigns,
    required this.onCampaignTap,
    required this.onDonateTap,
  });

  final List<Campaign> campaigns;
  final void Function(Campaign) onCampaignTap;
  final void Function(Campaign) onDonateTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: s.urgentCampaigns),
        const SizedBox(height: AppSpacing.sm),
        for (final c in campaigns)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: CampaignCard(
              campaign: c,
              onTap: () => onCampaignTap(c),
              onDonate: () => onDonateTap(c),
            ),
          ),
      ],
    );
  }
}

/// Impact statistics row.
class ImpactStats extends StatelessWidget {
  const ImpactStats({
    super.key,
    required this.beneficiaries,
    required this.projects,
    required this.charities,
  });

  final int beneficiaries;
  final int projects;
  final int charities;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: s.impactStats),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(
                value: Formatters.number(beneficiaries),
                label: s.beneficiaries,
              ),
              _Stat(value: Formatters.number(projects), label: s.projects),
              _Stat(value: Formatters.number(charities), label: s.charities),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.expanded = true});

  final String value;
  final String label;

  /// Whether to stretch across the available space.
  ///
  /// Use `expanded: false` when the stat sits inside a `Column`
  /// (e.g. a full-width stat) — `Expanded` inside an unbounded-height
  /// column produces a zero-size render box and breaks hit testing.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Text(
          value,
          style: AppTypography.title.copyWith(color: AppColors.primary),
        ),
        Text(label, style: AppTypography.caption),
      ],
    );
    return expanded ? Expanded(child: content) : content;
  }
}

/// Public platform statistics section (Phase 5).
///
/// Shows aggregated, safe-to-public numbers: total donations, donors,
/// campaigns, charities and beneficiaries.
class PlatformStatsSection extends StatelessWidget {
  const PlatformStatsSection({super.key, required this.stats});

  final PlatformStats stats;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: s.platformStats),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Stat(
                value: Formatters.amount(stats.totalDonations),
                label: s.totalDonationsPlatform,
                expanded: false,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Stat(
                    value: Formatters.number(stats.donorCount),
                    label: s.donorsCount,
                  ),
                  _Stat(
                    value: Formatters.number(stats.campaignCount),
                    label: s.campaignsCountPlatform,
                  ),
                  _Stat(
                    value: Formatters.number(stats.charityCount),
                    label: s.charitiesCount,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Stat(
                    value: Formatters.number(stats.beneficiaryCount),
                    label: s.beneficiariesCountPlatform,
                  ),
                  _Stat(
                    value: Formatters.number(stats.successfulCampaigns),
                    label: s.successfulCampaigns,
                  ),
                  _Stat(
                    value: Formatters.amount(stats.monthlyDonations),
                    label: s.monthlyDonationsPlatform,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Recent donations section for the home screen.
class RecentDonationsSection extends StatelessWidget {
  const RecentDonationsSection({
    super.key,
    required this.donations,
    required this.onDonationTap,
    required this.onViewAll,
  });

  final List<Donation> donations;
  final void Function(Donation) onDonationTap;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: s.recentDonations,
          actionLabel: s.viewAll,
          onAction: onViewAll,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final d in donations)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: DonationTile(donation: d, onTap: () => onDonationTap(d)),
          ),
      ],
    );
  }
}

/// A single notification tile used on the home screen.
class HomeNotificationTile extends StatelessWidget {
  const HomeNotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NotificationTile(notification: notification, onTap: onTap);
  }
}
