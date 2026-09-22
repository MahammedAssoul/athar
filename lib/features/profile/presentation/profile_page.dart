import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_locales.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/app_user.dart';
import '../../auth/presentation/auth_cubit.dart';
import '../../auth/presentation/forgot_password_page.dart';
import '../../charities/presentation/charities_page.dart';
import 'edit_profile_page.dart';
import 'profile_cubit.dart';

/// Profile screen with user info and settings.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _confirmLogout(BuildContext context) async {
    final s = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.logout),
        content: Text(s.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(s.logoutConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AuthCubit>().logout();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.logoutSuccess)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.profile)),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          if (state.error || state.user == null) {
            return StateView(
              icon: Icons.error_outline,
              title: s.somethingWrong,
              subtitle: s.somethingWrongHint,
              actionLabel: s.retry,
              onAction: () => context.read<ProfileCubit>().load(),
            );
          }
          final user = state.user!;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _UserHeader(
                user: user,
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EditProfilePage(user: user),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(s.personalInfo, style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              _SettingTile(
                icon: Icons.person_outline,
                label: s.editProfile,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EditProfilePage(user: user),
                  ),
                ),
              ),
              _SettingTile(
                icon: Icons.phone_android,
                label: s.phone,
                subtitle: user.phone,
              ),
              _SettingTile(
                icon: Icons.email_outlined,
                label: s.email,
                subtitle: user.email ?? '—',
              ),
              _SettingTile(
                icon: Icons.location_city,
                label: s.city,
                subtitle: user.city ?? '—',
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(s.settings, style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              _SettingTile(
                icon: Icons.language,
                label: s.language,
                subtitle: s.languageHint,
                trailing: _LanguageSwitcher(),
              ),
              _SettingTile(
                icon: Icons.notifications_outlined,
                label: s.notificationsSetting,
                subtitle: s.notificationsSettingHint,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.notificationPreferences),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(s.myImpactShort, style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              _SettingTile(
                icon: Icons.insights,
                label: s.myImpactShort,
                subtitle: s.myImpactShortHint,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.impact),
              ),
              _SettingTile(
                icon: Icons.autorenew,
                label: s.recurringShort,
                subtitle: s.recurringShortHint,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.recurringDonations),
              ),
              _SettingTile(
                icon: Icons.favorite_outline,
                label: s.favoritesShort,
                subtitle: s.favoritesShortHint,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.favorites),
              ),
              _SettingTile(
                icon: Icons.account_balance_wallet_outlined,
                label: s.zakatShort,
                subtitle: s.zakatShortHint,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.zakat),
              ),
              _SettingTile(
                icon: Icons.card_giftcard,
                label: s.giftShort,
                subtitle: s.giftShortHint,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.giftDonation, arguments: 'c1'),
              ),
              _SettingTile(
                icon: Icons.bolt,
                label: s.quickShort,
                subtitle: s.quickShortHint,
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.quickDonation),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(s.security, style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              _SettingTile(
                icon: Icons.lock_outline,
                label: s.security,
                subtitle: s.securityHint,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ForgotPasswordPage(),
                  ),
                ),
              ),
              _SettingTile(
                icon: Icons.privacy_tip_outlined,
                label: s.privacy,
                onTap: () => _showSnack(context, s.privacy),
              ),
              _SettingTile(
                icon: Icons.handshake_outlined,
                label: s.charities,
                subtitle: s.verified,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CharitiesPage(),
                  ),
                ),
              ),
              _SettingTile(
                icon: Icons.info_outline,
                label: s.about,
                subtitle: '${s.appName} v1.0.0',
                onTap: () => _showSnack(context, s.about),
              ),
              _SettingTile(
                icon: Icons.description_outlined,
                label: s.terms,
                onTap: () => _showSnack(context, s.terms),
              ),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  s.logout,
                  style: AppTypography.button.copyWith(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const DemoDataBanner(),
            ],
          );
        },
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user, required this.onEdit});

  final AppUser user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AppCard(
      child: Row(
        children: [
          InitialAvatar(name: user.shortName, radius: 32),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        style: AppTypography.headline,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(
                        Icons.verified,
                        size: 18,
                        color: AppColors.verified,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(user.email ?? '—', style: AppTypography.bodySecondary),
                Text(user.phone, style: AppTypography.caption),
                const SizedBox(height: 4),
                Text(
                  '${s.memberSince} ${user.createdAt.year}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ?subtitle != null
                      ? Text(subtitle!, style: AppTypography.caption)
                      : null,
                ],
              ),
            ),
            ?trailing,
            if (trailing == null && onTap != null)
              const Icon(Icons.chevron_left, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Inline language toggle (Arabic / English).
class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    final controller = context.read<LocaleController>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LangLabel(text: 'عربي', active: controller.isAr),
        Switch(
          value: !controller.isAr,
          activeThumbColor: AppColors.primary,
          onChanged: (value) =>
              controller.setLocale(value ? AppLocales.en : AppLocales.ar),
        ),
        _LangLabel(text: 'EN', active: !controller.isAr),
      ],
    );
  }
}

class _LangLabel extends StatelessWidget {
  const _LangLabel({required this.text, required this.active});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.caption.copyWith(
        color: active ? AppColors.primary : AppColors.textMuted,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
