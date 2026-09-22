import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/services/impact_service.dart';
import 'impact_cubit.dart';

/// "أثري" (My Impact) dashboard.
class ImpactPage extends StatelessWidget {
  const ImpactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImpactCubit()..load(),
      child: const _ImpactView(),
    );
  }
}

class _ImpactView extends StatelessWidget {
  const _ImpactView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.myImpact)),
      body: BlocBuilder<ImpactCubit, ImpactState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error || state.metrics == null) {
            return StateView(
              icon: Icons.error_outline,
              title: s.somethingWrong,
              subtitle: s.somethingWrongHint,
              actionLabel: s.retry,
              onAction: () => context.read<ImpactCubit>().load(),
            );
          }
          final m = state.metrics!;
          return RefreshIndicator(
            onRefresh: () => context.read<ImpactCubit>().load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _HeroCard(metrics: m),
                const SizedBox(height: AppSpacing.xl),
                Text(s.impactSummary, style: AppTypography.title),
                const SizedBox(height: AppSpacing.sm),
                _MetricGrid(metrics: m),
                const SizedBox(height: AppSpacing.xl),
                _KeepGoingCard(),
                const SizedBox(height: AppSpacing.lg),
                const DemoDataBanner(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.metrics});

  final ImpactMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.totalDonatedImpact,
            style: AppTypography.bodySecondary.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.amount(metrics.totalDonated),
            style: AppTypography.display.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _HeroStat(
                value: Formatters.number(metrics.donationCount),
                label: s.donationCountImpact,
              ),
              _HeroStat(
                value: Formatters.number(metrics.campaignsSupported),
                label: s.campaignsSupportedImpact,
              ),
              _HeroStat(
                value: Formatters.number(metrics.beneficiaries),
                label: s.beneficiariesImpact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTypography.title.copyWith(color: Colors.white)),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final ImpactMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.calendar_month,
            label: s.monthlyContribution,
            value: Formatters.amount(metrics.monthlyContribution),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MetricCard(
            icon: Icons.calendar_today,
            label: s.annualContribution,
            value: Formatters.amount(metrics.annualContribution),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.title.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _KeepGoingCard extends StatelessWidget {
  const _KeepGoingCard();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AppCard(
      color: AppColors.accentLight,
      child: Row(
        children: [
          const Icon(
            Icons.volunteer_activism,
            color: AppColors.accent,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              s.keepGoing,
              style: AppTypography.title.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
