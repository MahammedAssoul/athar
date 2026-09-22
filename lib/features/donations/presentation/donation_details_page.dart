import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/donation.dart';
import 'donation_detail_cubit.dart';

/// Donation details page.
class DonationDetailsPage extends StatelessWidget {
  const DonationDetailsPage({super.key, required this.donationId});

  final String donationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DonationDetailCubit(donationId)..load(),
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
      appBar: AppBar(title: Text(s.donationDetails)),
      body: BlocBuilder<DonationDetailCubit, DonationDetailState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error || state.donation == null) {
            return StateView(
              icon: Icons.error_outline,
              title: s.somethingWrong,
              subtitle: s.somethingWrongHint,
              actionLabel: s.retry,
              onAction: () => context.read<DonationDetailCubit>().load(),
            );
          }
          final donation = state.donation!;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _Header(donation: donation),
              const SizedBox(height: AppSpacing.lg),
              _InfoCard(donation: donation),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.receipt, arguments: donation.id),
                  icon: const Icon(Icons.receipt_long),
                  label: Text(s.receipt),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.donation});

  final Donation donation;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final success = donation.isSuccessful;
    return Column(
      children: [
        Icon(
          success ? Icons.check_circle : Icons.pending,
          size: 72,
          color: success ? AppColors.success : AppColors.warning,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          Formatters.amount(donation.amount),
          style: AppTypography.display.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          s.isAr ? donation.campaignTitleAr : donation.campaignTitleEn,
          style: AppTypography.title,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          s.isAr ? donation.charityNameAr : donation.charityNameEn,
          style: AppTypography.bodySecondary,
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.donation});

  final Donation donation;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AppCard(
      child: Column(
        children: [
          _Row(
            label: s.campaign,
            value: s.isAr ? donation.campaignTitleAr : donation.campaignTitleEn,
          ),
          _Row(
            label: s.charity,
            value: s.isAr ? donation.charityNameAr : donation.charityNameEn,
          ),
          _Row(label: s.amount, value: Formatters.amount(donation.amount)),
          _Row(label: s.date, value: _formatDate(donation.date)),
          _Row(label: s.status, value: _statusLabel(s, donation.status)),
          _Row(
            label: s.recurringSadaqah,
            value: donation.type == DonationType.recurring
                ? s.recurring
                : s.oneTime,
          ),
          _Row(label: s.paymentMethod, value: donation.paymentMethod),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  static String _statusLabel(AppStrings s, DonationStatus status) {
    return switch (status) {
      DonationStatus.success => s.statusSuccess,
      DonationStatus.pending => s.statusPending,
      DonationStatus.failed => s.statusFailed,
    };
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
            ),
          ),
        ],
      ),
    );
  }
}
