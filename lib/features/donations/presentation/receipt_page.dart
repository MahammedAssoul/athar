import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/di/app_dependencies.dart';
import '../../../data/models/donation.dart';
import 'donation_detail_cubit.dart';

/// Mock donation receipt page.
class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key, required this.donationId});

  final String donationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DonationDetailCubit(donationId)..load(),
      child: const _ReceiptView(),
    );
  }
}

class _ReceiptView extends StatelessWidget {
  const _ReceiptView();

  Future<void> _download(BuildContext context, Donation donation) async {
    final s = AppStrings.of(context);
    final service = AppDependencies.instance.receiptService;
    final receipt = await service.buildReceipt(donation);
    final ok = await service.download(receipt);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? s.receiptDownloaded : s.somethingWrong)),
    );
  }

  Future<void> _share(BuildContext context, Donation donation) async {
    final s = AppStrings.of(context);
    final service = AppDependencies.instance.receiptService;
    final receipt = await service.buildReceipt(donation);
    final ok = await service.share(receipt);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? s.receiptShared : s.somethingWrong)),
    );
  }

  Future<void> _print(BuildContext context, Donation donation) async {
    final s = AppStrings.of(context);
    final service = AppDependencies.instance.receiptService;
    final receipt = await service.buildReceipt(donation);
    final ok = await service.print(receipt);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? s.receiptPrinted : s.somethingWrong)),
    );
  }

  Future<void> _generatePdf(BuildContext context, Donation donation) async {
    final s = AppStrings.of(context);
    final service = AppDependencies.instance.receiptService;
    final receipt = await service.buildReceipt(donation);
    final bytes = await service.generatePdf(receipt);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${s.receiptPdfReady} (${bytes.length} bytes)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.donationReceipt)),
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
              _ReceiptCard(donation: donation),
              const SizedBox(height: AppSpacing.lg),
              _ReceiptActions(
                onDownload: () => _download(context, donation),
                onShare: () => _share(context, donation),
                onPrint: () => _print(context, donation),
                onPdf: () => _generatePdf(context, donation),
              ),
              const SizedBox(height: AppSpacing.lg),
              const DemoDataBanner(),
            ],
          );
        },
      ),
    );
  }
}

/// Action row preparing PDF / download / share / print.
class _ReceiptActions extends StatelessWidget {
  const _ReceiptActions({
    required this.onDownload,
    required this.onShare,
    required this.onPrint,
    required this.onPdf,
  });

  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onPrint;
  final VoidCallback onPdf;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(s.downloadPdf),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download_outlined),
                label: Text(s.downloadPdf),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined),
                label: Text(s.shareReceipt),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onPrint,
            icon: const Icon(Icons.print_outlined),
            label: Text(s.printReceipt),
          ),
        ),
      ],
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.donation});

  final Donation donation;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final d = donation;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(s.appName, style: AppTypography.headline),
          Text(s.appTagline, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          _ReceiptRow(label: s.receiptNo, value: 'ATH-${d.id.toUpperCase()}'),
          _ReceiptRow(label: s.transactionReference, value: _txRef(d)),
          _ReceiptRow(label: s.donor, value: s.demoUserFull),
          _ReceiptRow(label: s.date, value: _formatDate(d.date)),
          _ReceiptRow(
            label: s.campaign,
            value: s.isAr ? d.campaignTitleAr : d.campaignTitleEn,
          ),
          _ReceiptRow(
            label: s.charity,
            value: s.isAr ? d.charityNameAr : d.charityNameEn,
          ),
          _ReceiptRow(label: s.paymentMethod, value: d.paymentMethod),
          _ReceiptRow(
            label: s.donationTypeLabel,
            value: d.type == DonationType.recurring ? s.recurring : s.oneTime,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.amount, style: AppTypography.title),
              Text(
                Formatters.amount(d.amount),
                style: AppTypography.headline.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const AppBadge(label: '✓', color: AppColors.success),
        ],
      ),
    );
  }

  static String _txRef(Donation d) =>
      'TXN-${d.id.toUpperCase()}-${d.date.millisecondsSinceEpoch % 100000}';

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});

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
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
