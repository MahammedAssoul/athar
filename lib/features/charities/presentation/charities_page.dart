import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/charity.dart';
import 'charities_cubit.dart';

/// Charities list screen.
class CharitiesPage extends StatelessWidget {
  const CharitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CharitiesCubit()..load(),
      child: const _CharitiesView(),
    );
  }
}

class _CharitiesView extends StatelessWidget {
  const _CharitiesView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.charities)),
      body: BlocBuilder<CharitiesCubit, CharitiesState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error) {
            return StateView(
              icon: Icons.error_outline,
              title: s.somethingWrong,
              subtitle: s.somethingWrongHint,
              actionLabel: s.retry,
              onAction: () => context.read<CharitiesCubit>().load(),
            );
          }
          if (state.charities.isEmpty) {
            return StateView(
              icon: Icons.handshake_outlined,
              title: s.noCharities,
              subtitle: s.noResultsHint,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              for (final c in state.charities)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _CharityTile(charity: c),
                ),
              const SizedBox(height: AppSpacing.sm),
              const DemoDataBanner(),
            ],
          );
        },
      ),
    );
  }
}

class _CharityTile extends StatelessWidget {
  const _CharityTile({required this.charity});

  final Charity charity;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialAvatar(
            name: s.isAr ? charity.nameAr : charity.nameEn,
            radius: 26,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        s.isAr ? charity.nameAr : charity.nameEn,
                        style: AppTypography.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (charity.isVerified) ...[
                      const SizedBox(width: AppSpacing.sm),
                      const AppBadge(
                        label: 'موثقة',
                        color: AppColors.verified,
                        icon: Icons.verified,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  charity.description,
                  style: AppTypography.bodySecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(charity.location, style: AppTypography.caption),
                    const SizedBox(width: AppSpacing.lg),
                    Text(
                      '${charity.campaignCount} ${s.campaignsCount}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
