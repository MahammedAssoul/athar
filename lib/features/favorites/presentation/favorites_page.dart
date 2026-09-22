import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../campaigns/presentation/campaign_card.dart';
import 'favorites_cubit.dart';

/// Favorites screen with saved campaigns.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FavoritesCubit()..load(),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.favorites)),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error) {
            return StateView(
              icon: Icons.error_outline,
              title: s.somethingWrong,
              subtitle: s.somethingWrongHint,
              actionLabel: s.retry,
              onAction: () => context.read<FavoritesCubit>().load(),
            );
          }
          if (state.campaigns.isEmpty) {
            return StateView(
              icon: Icons.favorite_border,
              title: s.noFavorites,
              subtitle: s.noFavoritesHint,
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<FavoritesCubit>().load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(s.favoritesHint, style: AppTypography.bodySecondary),
                const SizedBox(height: AppSpacing.lg),
                for (final c in state.campaigns)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Stack(
                      children: [
                        CampaignCard(
                          campaign: c,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.campaignDetails,
                            arguments: c.id,
                          ),
                          onDonate: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.donationFlow, arguments: c.id),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _RemoveButton(
                            onTap: () =>
                                context.read<FavoritesCubit>().remove(c.id),
                          ),
                        ),
                      ],
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

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        tooltip: s.removeFromFavorites,
        icon: const Icon(Icons.favorite, color: AppColors.error, size: 20),
      ),
    );
  }
}
