import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/campaign_enums.dart';
import '../../../data/models/donation.dart';

/// Quick donation state.
class QuickDonationState {
  const QuickDonationState({
    this.loading = true,
    this.error = false,
    this.campaigns = const [],
    this.category,
    this.amount,
    this.processing = false,
    this.donation,
  });

  final bool loading;
  final bool error;
  final List<Campaign> campaigns;
  final CampaignCategory? category;
  final double? amount;
  final bool processing;
  final Donation? donation;

  bool get canSubmit => category != null && amount != null && amount! > 0;

  QuickDonationState copyWith({
    bool? loading,
    bool? error,
    List<Campaign>? campaigns,
    CampaignCategory? category,
    double? amount,
    bool? processing,
    Donation? donation,
  }) {
    return QuickDonationState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      campaigns: campaigns ?? this.campaigns,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      processing: processing ?? this.processing,
      donation: donation ?? this.donation,
    );
  }
}

/// Drives the universal quick donation flow.
class QuickDonationCubit extends Cubit<QuickDonationState> {
  QuickDonationCubit() : super(const QuickDonationState());

  Future<void> load() async {
    emit(const QuickDonationState(loading: true));
    try {
      final campaigns = await AppDependencies.instance.campaignRepository
          .getCampaigns();
      emit(
        QuickDonationState(
          loading: false,
          campaigns: campaigns.where((c) => c.isActive).toList(),
        ),
      );
    } catch (_) {
      emit(const QuickDonationState(loading: false, error: true));
    }
  }

  void selectCategory(CampaignCategory category) {
    emit(state.copyWith(category: category));
  }

  void selectAmount(double amount) {
    emit(state.copyWith(amount: amount));
  }

  /// Picks the best matching campaign for the selected category.
  Campaign? get targetCampaign {
    final category = state.category;
    if (category == null) return null;
    final matches = state.campaigns
        .where((c) => c.category == category && c.isActive)
        .toList();
    if (matches.isEmpty) return null;
    // Prefer the most needed (lowest progress) active campaign.
    matches.sort((a, b) => a.progress.compareTo(b.progress));
    return matches.first;
  }

  Future<bool> donate() async {
    final campaign = targetCampaign;
    final amount = state.amount;
    if (campaign == null || amount == null) return false;
    emit(state.copyWith(processing: true));
    try {
      final deps = AppDependencies.instance;
      final donation = await deps.donationRepository.createDonation(
        campaignId: campaign.id,
        campaignTitleAr: campaign.titleAr,
        campaignTitleEn: campaign.titleEn,
        charityNameAr: campaign.charityName,
        charityNameEn: campaign.charityName,
        amount: amount,
        type: DonationType.oneTime,
        paymentMethod: 'بطاقة مصرفية',
      );
      await deps.campaignRepository.updateCampaignCollected(
        campaign.id,
        amount,
      );
      emit(state.copyWith(processing: false, donation: donation));
      return true;
    } catch (_) {
      emit(state.copyWith(processing: false, error: true));
      return false;
    }
  }
}
