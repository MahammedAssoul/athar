import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/recurring_donation.dart';

/// Create recurring donation state.
class CreateRecurringState {
  const CreateRecurringState({
    this.loading = true,
    this.error = false,
    this.campaigns = const [],
    this.campaign,
    this.amount,
    this.frequency = RecurringFrequency.monthly,
    this.startDate,
  });

  final bool loading;
  final bool error;
  final List<Campaign> campaigns;
  final Campaign? campaign;
  final double? amount;
  final RecurringFrequency frequency;
  final DateTime? startDate;

  bool get canSubmit =>
      campaign != null && amount != null && amount! > 0 && startDate != null;

  CreateRecurringState copyWith({
    bool? loading,
    bool? error,
    List<Campaign>? campaigns,
    Campaign? campaign,
    double? amount,
    RecurringFrequency? frequency,
    DateTime? startDate,
  }) {
    return CreateRecurringState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      campaigns: campaigns ?? this.campaigns,
      campaign: campaign ?? this.campaign,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
    );
  }
}

/// Drives the create-recurring-donation wizard.
class CreateRecurringCubit extends Cubit<CreateRecurringState> {
  CreateRecurringCubit() : super(const CreateRecurringState());

  Future<void> load() async {
    emit(const CreateRecurringState(loading: true));
    try {
      final campaigns = await AppDependencies.instance.campaignRepository
          .getCampaigns();
      final active = campaigns.where((c) => c.isActive).toList();
      emit(
        CreateRecurringState(
          loading: false,
          campaigns: active,
          startDate: DateTime.now().add(const Duration(days: 1)),
        ),
      );
    } catch (_) {
      emit(const CreateRecurringState(loading: false, error: true));
    }
  }

  void selectCampaign(Campaign campaign) {
    emit(state.copyWith(campaign: campaign));
  }

  void selectAmount(double amount) {
    emit(state.copyWith(amount: amount));
  }

  void selectFrequency(RecurringFrequency frequency) {
    emit(state.copyWith(frequency: frequency));
  }

  Future<void> selectStartDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: state.startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      emit(state.copyWith(startDate: picked));
    }
  }

  Future<bool> create() async {
    final campaign = state.campaign;
    final amount = state.amount;
    final startDate = state.startDate;
    if (campaign == null || amount == null || startDate == null) return false;
    try {
      await AppDependencies.instance.recurringDonationRepository
          .createRecurringDonation(
            campaignId: campaign.id,
            campaignTitleAr: campaign.titleAr,
            campaignTitleEn: campaign.titleEn,
            charityNameAr: campaign.charityName,
            charityNameEn: campaign.charityName,
            amount: amount,
            frequency: state.frequency,
            startDate: startDate,
            paymentMethod: 'بطاقة مصرفية',
          );
      return true;
    } catch (_) {
      return false;
    }
  }
}
