import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/common_widgets.dart';

/// Branded splash screen shown while the app boots.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 128),
            const SizedBox(height: AppSpacing.lg),
            Text(s.appName, style: AppTypography.display),
            const SizedBox(height: AppSpacing.sm),
            Text(s.appTagline, style: AppTypography.bodySecondary),
            const SizedBox(height: AppSpacing.xl),
            const SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}