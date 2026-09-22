import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/campaign_enums.dart';
import '../../../data/repositories/campaign_repository.dart';
import 'campaign_card.dart';
import 'campaign_filters_sheet.dart';
import 'campaigns_cubit.dart';

/// Browsable donation opportunities with search, filters and sorting.
class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key, this.initialCategory, this.initialQuery});

  final CampaignCategory? initialCategory;
  final String? initialQuery;

  void _openCampaign(BuildContext context, String id) {
    Navigator.of(context).pushNamed(AppRoutes.campaignDetails, arguments: id);
  }

  void _openDonationFlow(BuildContext context, String id) {
    Navigator.of(context).pushNamed(AppRoutes.donationFlow, arguments: id);
  }

  void _showFilters(BuildContext context) {
    final cubit = context.read<CampaignsCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CampaignFiltersSheet(
        selectedCategory: cubit.state.category,
        selectedSort: cubit.state.sort,
        onApply: (category, sort) {
          cubit.setCategory(category);
          if (sort != null) cubit.setSort(sort);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.opportunitiesTitle)),
      body: BlocProvider(
        create: (_) =>
            CampaignsCubit(query: initialQuery ?? '', category: initialCategory)
              ..load(),
        child: BlocBuilder<CampaignsCubit, CampaignsState>(
          builder: (context, state) {
            if (state.loading) return const LoadingView();
            if (state.error) {
              return StateView(
                icon: Icons.error_outline,
                title: s.somethingWrong,
                subtitle: s.somethingWrongHint,
                actionLabel: s.retry,
                onAction: () => context.read<CampaignsCubit>().load(),
              );
            }
            return Column(
              children: [
                _SearchBar(
                  onChanged: (q) => context.read<CampaignsCubit>().search(q),
                  onFiltersTap: () => _showFilters(context),
                ),
                _SearchFieldSelector(
                  selected: state.searchField,
                  onChanged: (f) =>
                      context.read<CampaignsCubit>().setSearchField(f),
                ),
                _QuickFilters(
                  filters: state.filters,
                  onToggle: (f) =>
                      context.read<CampaignsCubit>().toggleFilter(f),
                  onClear: () => context.read<CampaignsCubit>().clearFilters(),
                ),
                Expanded(
                  child: state.campaigns.isEmpty
                      ? StateView(
                          icon: Icons.search_off,
                          title: s.noCampaigns,
                          subtitle: s.noResultsHint,
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              context.read<CampaignsCubit>().load(),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            children: [
                              for (final c in state.campaigns)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md,
                                  ),
                                  child: CampaignCard(
                                    campaign: c,
                                    onTap: () => _openCampaign(context, c.id),
                                    onDonate: () =>
                                        _openDonationFlow(context, c.id),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged, required this.onFiltersTap});

  final ValueChanged<String> onChanged;
  final VoidCallback onFiltersTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: s.searchHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onFiltersTap,
            tooltip: s.filters,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
    );
  }
}

/// Horizontal selector for the search field (title / charity / city / category).
class _SearchFieldSelector extends StatelessWidget {
  const _SearchFieldSelector({required this.selected, required this.onChanged});

  final CampaignSearchField? selected;
  final ValueChanged<CampaignSearchField?> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final options = [
      (null, s.searchByTitle),
      (CampaignSearchField.charity, s.searchByCharity),
      (CampaignSearchField.city, s.searchByCity),
      (CampaignSearchField.category, s.searchByCategory),
    ];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(option.$2),
                selected: selected == option.$1,
                onSelected: (_) => onChanged(option.$1),
                selectedColor: AppColors.primaryLight,
                labelStyle: AppTypography.caption.copyWith(
                  color: selected == option.$1
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                side: const BorderSide(color: AppColors.border),
                showCheckmark: false,
              ),
            ),
        ],
      ),
    );
  }
}

/// Quick filter chips: urgent / verified / near me / most needed / recently added.
class _QuickFilters extends StatelessWidget {
  const _QuickFilters({
    required this.filters,
    required this.onToggle,
    required this.onClear,
  });

  final Set<CampaignFilter> filters;
  final ValueChanged<CampaignFilter> onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final options = [
      (CampaignFilter.urgent, s.filterUrgent),
      (CampaignFilter.verified, s.filterVerified),
      (CampaignFilter.nearMe, s.filterNearMe),
      (CampaignFilter.mostNeeded, s.filterMostNeeded),
      (CampaignFilter.recentlyAdded, s.filterRecentlyAdded),
    ];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(option.$2),
                selected: filters.contains(option.$1),
                onSelected: (_) => onToggle(option.$1),
                selectedColor: AppColors.primary,
                labelStyle: AppTypography.caption.copyWith(
                  color: filters.contains(option.$1)
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                side: const BorderSide(color: AppColors.border),
                showCheckmark: false,
              ),
            ),
          if (filters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ActionChip(
                label: Text(s.clearFilters),
                onPressed: onClear,
                avatar: const Icon(Icons.close, size: 16),
                backgroundColor: AppColors.accentLight,
                labelStyle: AppTypography.caption.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
