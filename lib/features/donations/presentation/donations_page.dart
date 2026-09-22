import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import 'donation_tile.dart';
import 'donations_cubit.dart';

/// My Donations screen with summary stats and history.
class DonationsPage extends StatelessWidget {
  const DonationsPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DonationsCubit()..load(),
      child: const _DonationsView(),
    );
  }
}

class _DonationsView extends StatelessWidget {
  const _DonationsView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.myDonations)),
      body: BlocBuilder<DonationsCubit, DonationsState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error) {
            return StateView(
              icon: Icons.error_outline,
              title: s.somethingWrong,
              subtitle: s.somethingWrongHint,
              actionLabel: s.retry,
              onAction: () => context.read<DonationsCubit>().load(),
            );
          }
          final cubit = context.read<DonationsCubit>();
          final filtered = cubit.filteredDonations;
          return RefreshIndicator(
            onRefresh: () => cubit.load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _SummaryCard(
                  total: cubit.totalDonated,
                  count: cubit.successCount,
                  campaigns: cubit.campaignsSupported,
                ),
                const SizedBox(height: AppSpacing.lg),
                _FilterBar(
                  selected: state.filter,
                  onChanged: (f) => cubit.setFilter(f),
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(title: s.recentDonations),
                const SizedBox(height: AppSpacing.sm),
                if (filtered.isEmpty)
                  StateView(
                    icon: Icons.favorite_border,
                    title: s.noDonations,
                    subtitle: s.noDonationsHint,
                  )
                else
                  for (final d in filtered)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: DonationTile(
                        donation: d,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.donationDetails, arguments: d.id),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Segmented filter: All / This month / This year.
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final DonationFilter selected;
  final ValueChanged<DonationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return SegmentedButton<DonationFilter>(
      segments: [
        ButtonSegment(value: DonationFilter.all, label: Text(s.filterAll)),
        ButtonSegment(
          value: DonationFilter.thisMonth,
          label: Text(s.filterThisMonth),
        ),
        ButtonSegment(
          value: DonationFilter.thisYear,
          label: Text(s.filterThisYear),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.count,
    required this.campaigns,
  });

  final double total;
  final int count;
  final int campaigns;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.totalDonated, style: AppTypography.bodySecondary),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.amount(total),
            style: AppTypography.display.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.receipt_long,
                  label: s.donationsCount,
                  value: Formatters.number(count),
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.handshake_outlined,
                  label: s.campaignsSupported,
                  value: Formatters.number(campaigns),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption),
            Text(
              value,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}
