import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/gift_donation.dart';

/// Gift donation wizard step.
enum GiftStep { campaign, amount, recipient, preview, result }

/// Gift donation state.
class GiftDonationState {
  const GiftDonationState({
    this.step = GiftStep.campaign,
    this.loading = true,
    this.error = false,
    this.campaigns = const [],
    this.campaign,
    this.amount,
    this.recipientName = '',
    this.recipientContact = '',
    this.message = '',
    this.processing = false,
    this.gift,
  });

  final GiftStep step;
  final bool loading;
  final bool error;
  final List<Campaign> campaigns;
  final Campaign? campaign;
  final double? amount;
  final String recipientName;
  final String recipientContact;
  final String message;
  final bool processing;
  final GiftDonation? gift;

  bool get canContinueToRecipient =>
      campaign != null && amount != null && amount! > 0;

  bool get canSubmit =>
      recipientName.trim().isNotEmpty && recipientContact.trim().isNotEmpty;

  GiftDonationState copyWith({
    GiftStep? step,
    bool? loading,
    bool? error,
    List<Campaign>? campaigns,
    Campaign? campaign,
    double? amount,
    String? recipientName,
    String? recipientContact,
    String? message,
    bool? processing,
    GiftDonation? gift,
  }) {
    return GiftDonationState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      campaigns: campaigns ?? this.campaigns,
      campaign: campaign ?? this.campaign,
      amount: amount ?? this.amount,
      recipientName: recipientName ?? this.recipientName,
      recipientContact: recipientContact ?? this.recipientContact,
      message: message ?? this.message,
      processing: processing ?? this.processing,
      gift: gift ?? this.gift,
    );
  }
}

/// Drives the gift donation wizard.
class GiftDonationCubit extends Cubit<GiftDonationState> {
  GiftDonationCubit({String? campaignId})
    : _preselectedCampaignId = campaignId,
      super(GiftDonationState(campaign: null));

  final String? _preselectedCampaignId;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: false));
    try {
      final campaigns = await AppDependencies.instance.campaignRepository
          .getCampaigns();
      final active = campaigns.where((c) => c.isActive).toList();
      Campaign? preselected;
      if (_preselectedCampaignId != null) {
        for (final c in active) {
          if (c.id == _preselectedCampaignId) {
            preselected = c;
            break;
          }
        }
      }
      emit(
        state.copyWith(
          loading: false,
          campaigns: active,
          campaign: preselected,
          step: preselected != null ? GiftStep.amount : GiftStep.campaign,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false, error: true));
    }
  }

  void selectCampaign(Campaign campaign) {
    emit(state.copyWith(campaign: campaign, step: GiftStep.amount));
  }

  void selectAmount(double amount) {
    emit(state.copyWith(amount: amount, step: GiftStep.recipient));
  }

  void updateRecipientName(String value) {
    emit(state.copyWith(recipientName: value));
  }

  void updateRecipientContact(String value) {
    emit(state.copyWith(recipientContact: value));
  }

  void updateMessage(String value) {
    emit(state.copyWith(message: value));
  }

  void continueToPreview() {
    emit(state.copyWith(step: GiftStep.preview));
  }

  void backToRecipient() {
    emit(state.copyWith(step: GiftStep.recipient));
  }

  Future<void> submit() async {
    final campaign = state.campaign;
    final amount = state.amount;
    if (campaign == null || amount == null) return;
    emit(state.copyWith(processing: true));
    try {
      final gift = await AppDependencies.instance.giftDonationRepository
          .createGiftDonation(
            campaignId: campaign.id,
            campaignTitleAr: campaign.titleAr,
            campaignTitleEn: campaign.titleEn,
            charityNameAr: campaign.charityName,
            charityNameEn: campaign.charityName,
            amount: amount,
            recipientName: state.recipientName.trim(),
            recipientContact: state.recipientContact.trim(),
            message: state.message.trim().isEmpty ? null : state.message.trim(),
          );
      emit(
        state.copyWith(processing: false, gift: gift, step: GiftStep.result),
      );
    } catch (_) {
      emit(state.copyWith(processing: false, error: true));
    }
  }
}
