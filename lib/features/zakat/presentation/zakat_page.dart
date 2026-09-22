import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/zakat_asset.dart';
import '../../../data/services/zakat_calculator.dart';
import 'zakat_cubit.dart';

/// Zakat calculator screen.
///
/// The calculation itself is isolated in `ZakatCalculator` (a service).
/// This screen only collects inputs and displays results.
class ZakatPage extends StatelessWidget {
  const ZakatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => ZakatCubit(), child: const _ZakatView());
  }
}

class _ZakatView extends StatelessWidget {
  const _ZakatView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.zakatCalculator)),
      body: BlocBuilder<ZakatCubit, ZakatState>(
        builder: (context, state) {
          final cubit = context.read<ZakatCubit>();
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(s.zakatHint, style: AppTypography.bodySecondary),
              const SizedBox(height: AppSpacing.lg),
              Text(s.zakatAddAsset, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.md),
              _AssetTypeGrid(onAdd: cubit.addAsset),
              const SizedBox(height: AppSpacing.xl),
              if (state.assets.isEmpty)
                StateView(
                  icon: Icons.account_balance_wallet_outlined,
                  title: s.zakatEmpty,
                )
              else ...[
                Text(s.zakatTotalAssets, style: AppTypography.title),
                const SizedBox(height: AppSpacing.sm),
                for (var i = 0; i < state.assets.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _AssetTile(
                      asset: state.assets[i],
                      onRemove: () => cubit.removeAsset(i),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
                _ResultCard(result: state.result!),
              ],
              const SizedBox(height: AppSpacing.lg),
              _Disclaimer(),
              const SizedBox(height: AppSpacing.lg),
              const DemoDataBanner(),
            ],
          );
        },
      ),
    );
  }
}

/// Grid of asset categories to add.
class _AssetTypeGrid extends StatelessWidget {
  const _AssetTypeGrid({required this.onAdd});

  final void Function(ZakatAssetType, double) onAdd;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final entries = [
      (s.zakatCash, Icons.payments_outlined, ZakatAssetType.cash),
      (s.zakatGold, Icons.workspace_premium_outlined, ZakatAssetType.gold),
      (s.zakatSilver, Icons.workspace_premium, ZakatAssetType.silver),
      (s.zakatInvestments, Icons.trending_up, ZakatAssetType.investments),
      (s.zakatOther, Icons.category_outlined, ZakatAssetType.other),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final entry in entries)
          _AssetTypeChip(
            label: entry.$1,
            icon: entry.$2,
            onTap: () => _promptAmount(context, entry.$1, entry.$3),
          ),
      ],
    );
  }

  void _promptAmount(BuildContext context, String label, ZakatAssetType type) {
    final s = AppStrings.of(context);
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$label — ${s.zakatAssetAmount}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: s.enterAmount,
            suffixText: s.lyd,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value != null && value > 0) {
                onAdd(type, value);
              }
              Navigator.of(dialogContext).pop();
            },
            child: Text(s.confirm),
          ),
        ],
      ),
    );
  }
}

class _AssetTypeChip extends StatelessWidget {
  const _AssetTypeChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.primaryLight,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      labelStyle: AppTypography.bodySecondary.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  const _AssetTile({required this.asset, required this.onRemove});

  final ZakatAsset asset;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _typeLabel(s, asset.type),
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            Formatters.amount(asset.amount),
            style: AppTypography.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: s.zakatRemove,
            icon: const Icon(Icons.close, size: 18, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  static String _typeLabel(AppStrings s, ZakatAssetType type) {
    return switch (type) {
      ZakatAssetType.cash => s.zakatCash,
      ZakatAssetType.gold => s.zakatGold,
      ZakatAssetType.silver => s.zakatSilver,
      ZakatAssetType.investments => s.zakatInvestments,
      ZakatAssetType.other => s.zakatOther,
    };
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final ZakatCalculation result;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final total = result.totalAssets;
    final due = result.zakatDue;
    return AppCard(
      color: AppColors.primaryLight,
      child: Column(
        children: [
          Text(s.zakatDue, style: AppTypography.bodySecondary),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.amount(due),
            style: AppTypography.display.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(label: s.zakatTotalAssets, value: Formatters.amount(total)),
              _Stat(label: s.zakatRate, value: s.zakatRateValue),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              s.zakatDisclaimer,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
