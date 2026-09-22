import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/campaign_enums.dart';
import '../../../data/models/donation.dart';
import '../../../data/models/platform_stats.dart';

/// Home screen state.
class HomeState {
  const HomeState({
    this.loading = true,
    this.error = false,
    this.userName = '',
    this.unreadCount = 0,
    this.quickCategories = const [],
    this.featured = const [],
    this.urgent = const [],
    this.recentDonations = const [],
    this.recommended = const [],
    this.recentlyViewed = const [],
    this.continueDonating = const [],
    this.causesYouSupport = const [],
    this.stats = const HomeStats(0, 0, 0),
    this.platformStats,
  });

  final bool loading;
  final bool error;
  final String userName;
  final int unreadCount;
  final List<CampaignCategory> quickCategories;
  final List<Campaign> featured;
  final List<Campaign> urgent;
  final List<Donation> recentDonations;
  final List<Campaign> recommended;
  final List<Campaign> recentlyViewed;
  final List<Campaign> continueDonating;
  final List<Campaign> causesYouSupport;
  final HomeStats stats;

  /// Public platform statistics (Phase 5).
  final PlatformStats? platformStats;

  HomeState copyWith({
    bool? loading,
    bool? error,
    String? userName,
    int? unreadCount,
    List<CampaignCategory>? quickCategories,
    List<Campaign>? featured,
    List<Campaign>? urgent,
    List<Donation>? recentDonations,
    List<Campaign>? recommended,
    List<Campaign>? recentlyViewed,
    List<Campaign>? continueDonating,
    List<Campaign>? causesYouSupport,
    HomeStats? stats,
    PlatformStats? platformStats,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      userName: userName ?? this.userName,
      unreadCount: unreadCount ?? this.unreadCount,
      quickCategories: quickCategories ?? this.quickCategories,
      featured: featured ?? this.featured,
      urgent: urgent ?? this.urgent,
      recentDonations: recentDonations ?? this.recentDonations,
      recommended: recommended ?? this.recommended,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
      continueDonating: continueDonating ?? this.continueDonating,
      causesYouSupport: causesYouSupport ?? this.causesYouSupport,
      stats: stats ?? this.stats,
      platformStats: platformStats ?? this.platformStats,
    );
  }
}

/// Mock impact statistics.
class HomeStats {
  const HomeStats(this.beneficiaries, this.projects, this.charities);

  final int beneficiaries;
  final int projects;
  final int charities;
}

/// Loads all home sections from the repositories.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> load() async {
    emit(const HomeState(loading: true));
    try {
      final deps = AppDependencies.instance;
      final user = await deps.userRepository.getCurrentUser();
      final notifications = await deps.notificationRepository
          .getNotifications();
      final featured = await deps.campaignRepository.getFeaturedCampaigns();
      final urgent = await deps.campaignRepository.getUrgentCampaigns();
      final donations = await deps.donationRepository.getDonations();
      final charities = await deps.charityRepository.getCharities();
      final allCampaigns = await deps.campaignRepository.getCampaigns();
      final platformStats = await deps.platformStatsRepository
          .getPlatformStats();

      // ── Personalization (mock logic) ────────────────────
      final supportedIds = donations
          .where((d) => d.isSuccessful)
          .map((d) => d.campaignId)
          .toSet();
      final supportedCategories = donations
          .where((d) => d.isSuccessful)
          .map((d) => d.campaignId)
          .toSet()
          .map((id) => allCampaigns.where((c) => c.id == id).firstOrNull)
          .whereType<Campaign>()
          .map((c) => c.category)
          .toSet();

      // Continue donating: campaigns the user already supports that are active.
      final continueDonating = allCampaigns
          .where((c) => supportedIds.contains(c.id) && c.isActive)
          .toList();

      // Causes you support: active campaigns in the user's supported categories.
      final causesYouSupport = allCampaigns
          .where(
            (c) =>
                c.isActive &&
                supportedCategories.contains(c.category) &&
                !supportedIds.contains(c.id),
          )
          .take(5)
          .toList();

      // Recommended: active campaigns not yet supported, most needed first.
      final recommended =
          allCampaigns
              .where((c) => c.isActive && !supportedIds.contains(c.id))
              .toList()
            ..sort((a, b) => a.progress.compareTo(b.progress));

      // Recently viewed: newest active campaigns (mock).
      final recentlyViewed = allCampaigns.where((c) => c.isActive).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(
        HomeState(
          loading: false,
          error: false,
          userName: user?.shortName ?? 'أثر',
          unreadCount: notifications.where((n) => !n.isRead).length,
          quickCategories: _quickCategories,
          featured: featured.take(5).toList(),
          urgent: urgent.take(3).toList(),
          recentDonations: donations.take(3).toList(),
          recommended: recommended.take(5).toList(),
          recentlyViewed: recentlyViewed.take(5).toList(),
          continueDonating: continueDonating.take(3).toList(),
          causesYouSupport: causesYouSupport.take(5).toList(),
          stats: HomeStats(1250, 320, charities.length * 9 + 3),
          platformStats: platformStats,
        ),
      );
    } catch (_) {
      emit(const HomeState(loading: false, error: true));
    }
  }

  static const List<CampaignCategory> _quickCategories = [
    CampaignCategory.general,
    CampaignCategory.families,
    CampaignCategory.treatment,
    CampaignCategory.food,
    CampaignCategory.housing,
    CampaignCategory.orphans,
    CampaignCategory.relief,
    CampaignCategory.education,
    CampaignCategory.families,
  ];
}
