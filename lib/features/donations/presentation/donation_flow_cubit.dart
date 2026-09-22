import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/donation.dart';
import '../../../data/services/payment_gateway.dart';

/// Step in the donation flow wizard.
enum DonationStep { amount, options, summary, payment, result }

/// Donation flow state.
class DonationFlowState {
  const DonationFlowState({
    this.step = DonationStep.amount,
    this.loading = true,
    this.error = false,
    this.campaign,
    this.amount,
    this.isRecurring = false,
    this.paymentMethod,
    this.processing = false,
    this.paymentFailed = false,
    this.result,
    this.donationId,
  });

  final DonationStep step;
  final bool loading;
  final bool error;
  final Campaign? campaign;
  final double? amount;
  final bool isRecurring;
  final String? paymentMethod;
  final bool processing;
  final bool paymentFailed;
  final PaymentResult? result;
  final String? donationId;

  DonationFlowState copyWith({
    DonationStep? step,
    bool? loading,
    bool? error,
    Campaign? campaign,
    double? amount,
    bool? isRecurring,
    String? paymentMethod,
    bool? processing,
    bool? paymentFailed,
    PaymentResult? result,
    String? donationId,
  }) {
    return DonationFlowState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      campaign: campaign ?? this.campaign,
      amount: amount ?? this.amount,
      isRecurring: isRecurring ?? this.isRecurring,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      processing: processing ?? this.processing,
      paymentFailed: paymentFailed ?? this.paymentFailed,
      result: result ?? this.result,
      donationId: donationId ?? this.donationId,
    );
  }
}

/// Fixed quick-amount options in LYD.
const List<double> kDonationAmounts = [10, 25, 50, 100, 250];

/// Payment method placeholders.
const List<String> kPaymentMethods = ['card', 'applePay', 'bankTransfer'];

/// Drives the mock donation wizard.
class DonationFlowCubit extends Cubit<DonationFlowState> {
  DonationFlowCubit(this.campaignId) : super(const DonationFlowState());

  final String campaignId;

  Future<void> loadCampaign() async {
    emit(const DonationFlowState(loading: true));
    try {
      final campaign = await AppDependencies.instance.campaignRepository
          .getCampaignById(campaignId);
      emit(DonationFlowState(loading: false, campaign: campaign));
    } catch (_) {
      emit(const DonationFlowState(loading: false, error: true));
    }
  }

  void selectAmount(double amount) {
    emit(state.copyWith(amount: amount, step: DonationStep.options));
  }

  void toggleRecurring(bool value) {
    emit(state.copyWith(isRecurring: value));
  }

  void continueToSummary() {
    emit(state.copyWith(step: DonationStep.summary));
  }

  void continueToPayment() {
    emit(state.copyWith(step: DonationStep.payment));
  }

  void backToOptions() {
    emit(state.copyWith(step: DonationStep.options));
  }

  void selectPaymentMethod(String method) {
    emit(state.copyWith(paymentMethod: method, step: DonationStep.payment));
  }

  void backToSummary() {
    emit(state.copyWith(step: DonationStep.summary));
  }

  void retryPayment() {
    emit(state.copyWith(paymentFailed: false, step: DonationStep.payment));
  }

  Future<void> processPayment() async {
    final campaign = state.campaign;
    final amount = state.amount;
    final method = state.paymentMethod;
    if (campaign == null || amount == null || method == null) return;

    emit(state.copyWith(processing: true, paymentFailed: false));
    final payment = await AppDependencies.instance.paymentGateway.pay(
      amount: amount,
      method: method,
    );

    if (!payment.success) {
      emit(state.copyWith(processing: false, paymentFailed: true));
      return;
    }

    try {
      final deps = AppDependencies.instance;
      final donation = await deps.donationRepository.createDonation(
        campaignId: campaign.id,
        campaignTitleAr: campaign.titleAr,
        campaignTitleEn: campaign.titleEn,
        charityNameAr: campaign.charityName,
        charityNameEn: campaign.charityName,
        amount: amount,
        type: state.isRecurring ? DonationType.recurring : DonationType.oneTime,
        paymentMethod: method,
      );
      await deps.campaignRepository.updateCampaignCollected(
        campaign.id,
        amount,
      );
      emit(
        state.copyWith(
          processing: false,
          result: payment,
          donationId: donation.id,
          step: DonationStep.result,
        ),
      );
    } catch (_) {
      emit(state.copyWith(processing: false, paymentFailed: true));
    }
  }

  void reset() {
    emit(DonationFlowState(campaign: state.campaign));
  }
}
