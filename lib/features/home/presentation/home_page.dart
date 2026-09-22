import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/donation.dart';
import '../../campaigns/presentation/campaign_card.dart';
import '../../campaigns/presentation/campaigns_page.dart';
import '../../donations/presentation/donations_page.dart';
import 'home_cubit.dart';
import 'home_widgets.dart';

/// The main home screen.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  void _openCampaign(BuildContext context, String id) {
    Navigator.of(context).pushNamed(AppRoutes.campaignDetails, arguments: id);
  }

  void _openDonationFlow(BuildContext context, String campaignId) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.donationFlow, arguments: campaignId);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.loading) return const LoadingView();
            if (state.error) {
              return StateView(
                icon: Icons.error_outline,
                title: s.somethingWrong,
                subtitle: s.somethingWrongHint,
                actionLabel: s.retry,
                onAction: () => context.read<HomeCubit>().load(),
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().load(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  HomeHeader(
                    userName: state.userName,
                    unreadCount: state.unreadCount,
                    onNotificationsTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.notifications),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  HomeCtaCard(onDonate: () => _openOpportunities(context)),
                  const SizedBox(height: AppSpacing.xl),
                  QuickDonateRow(
                    onCategoryTap: () => _openQuickDonation(context),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FeaturedCampaignsRow(
                    campaigns: state.featured,
                    onCampaignTap: (c) => _openCampaign(context, c.id),
                    onDonateTap: (c) => _openDonationFlow(context, c.id),
                    onViewAll: () => _openOpportunities(context),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (state.urgent.isNotEmpty) ...[
                    UrgentCampaignsList(
                      campaigns: state.urgent,
                      onCampaignTap: (c) => _openCampaign(context, c.id),
                      onDonateTap: (c) => _openDonationFlow(context, c.id),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  // ── Phase 3: Personalization ──────────────
                  if (state.continueDonating.isNotEmpty) ...[
                    _PersonalizedRow(
                      title: s.continueDonating,
                      campaigns: state.continueDonating,
                      onCampaignTap: (c) => _openCampaign(context, c.id),
                      onDonateTap: (c) => _openDonationFlow(context, c.id),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  if (state.causesYouSupport.isNotEmpty) ...[
                    _PersonalizedRow(
                      title: s.causesYouSupport,
                      campaigns: state.causesYouSupport,
                      onCampaignTap: (c) => _openCampaign(context, c.id),
                      onDonateTap: (c) => _openDonationFlow(context, c.id),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  if (state.recommended.isNotEmpty) ...[
                    _PersonalizedRow(
                      title: s.recommendedForYou,
                      campaigns: state.recommended,
                      onCampaignTap: (c) => _openCampaign(context, c.id),
                      onDonateTap: (c) => _openDonationFlow(context, c.id),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  if (state.recentlyViewed.isNotEmpty) ...[
                    _PersonalizedRow(
                      title: s.recentlyViewed,
                      campaigns: state.recentlyViewed,
                      onCampaignTap: (c) => _openCampaign(context, c.id),
                      onDonateTap: (c) => _openDonationFlow(context, c.id),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  ImpactStats(
                    beneficiaries: state.stats.beneficiaries,
                    projects: state.stats.projects,
                    charities: state.stats.charities,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (state.platformStats != null) ...[
                    PlatformStatsSection(stats: state.platformStats!),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  if (state.recentDonations.isNotEmpty)
                    RecentDonationsSection(
                      donations: state.recentDonations,
                      onDonationTap: (d) => _openDonation(context, d),
                      onViewAll: () => _openMyDonations(context),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  const DemoDataBanner(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openOpportunities(BuildContext context) {
    final page = CampaignsPage(initialCategory: null, initialQuery: '');
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _openQuickDonation(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.quickDonation);
  }

  void _openDonation(BuildContext context, Donation donation) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.donationDetails, arguments: donation.id);
  }

  void _openMyDonations(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DonationsPage(initialTab: 0)),
    );
  }
}

/// Horizontal row of personalized campaign cards.
class _PersonalizedRow extends StatelessWidget {
  const _PersonalizedRow({
    required this.title,
    required this.campaigns,
    required this.onCampaignTap,
    required this.onDonateTap,
  });

  final String title;
  final List<Campaign> campaigns;
  final void Function(Campaign) onCampaignTap;
  final void Function(Campaign) onDonateTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
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
