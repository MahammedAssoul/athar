import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/gift_donation.dart';
import 'gift_success_cubit.dart';

/// Beautiful gift confirmation screen shown after a gift donation.
class GiftSuccessPage extends StatelessWidget {
  const GiftSuccessPage({super.key, required this.giftId});

  final String giftId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GiftSuccessCubit(giftId)..load(),
      child: const _GiftSuccessView(),
    );
  }
}

class _GiftSuccessView extends StatelessWidget {
  const _GiftSuccessView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: BlocBuilder<GiftSuccessCubit, GiftSuccessState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error || state.gift == null) {
            return StateView(
              icon: Icons.error_outline,
              title: s.somethingWrong,
              subtitle: s.somethingWrongHint,
              actionLabel: s.retry,
              onAction: () => context.read<GiftSuccessCubit>().load(),
            );
          }
          return _Confirmation(gift: state.gift!);
        },
      ),
    );
  }
}

class _Confirmation extends StatelessWidget {
  const _Confirmation({required this.gift});

  final GiftDonation gift;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Icon(Icons.card_giftcard, size: 72, color: Colors.white),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  s.giftSent,
                  style: AppTypography.headline.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  s.giftSentHint,
                  style: AppTypography.bodySecondary.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              children: [
                _Row(label: s.giftReference, value: gift.reference),
                _Row(label: s.giftTo, value: gift.recipientName),
                _Row(label: s.recipientContact, value: gift.recipientContact),
                _Row(
                  label: s.campaign,
                  value: s.isAr ? gift.campaignTitleAr : gift.campaignTitleEn,
                ),
                _Row(
                  label: s.charity,
                  value: s.isAr ? gift.charityNameAr : gift.charityNameEn,
                ),
                _Row(label: s.amount, value: Formatters.amount(gift.amount)),
                if (gift.message != null)
                  _Row(label: s.giftMessageLabel, value: gift.message!),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: Text(s.done),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

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
