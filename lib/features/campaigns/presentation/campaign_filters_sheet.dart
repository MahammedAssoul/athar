import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/campaign_enums.dart';

/// Bottom sheet with category filters and sorting options.
class CampaignFiltersSheet extends StatelessWidget {
  const CampaignFiltersSheet({
    super.key,
    required this.selectedCategory,
    required this.selectedSort,
    required this.onApply,
  });

  final CampaignCategory? selectedCategory;
  final String? selectedSort;
  final void Function(CampaignCategory?, String?) onApply;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.filters, style: AppTypography.headline),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(s.allCategories, style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _FilterChip(
                label: s.allCategories,
                selected: selectedCategory == null,
                onTap: () => onApply(null, null),
              ),
              for (final cat in CampaignCategory.values)
                _FilterChip(
                  label: _categoryLabel(cat),
                  selected: selectedCategory == cat,
                  onTap: () => onApply(cat, null),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(s.sort, style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _SortOption(
                label: s.sortNewest,
                selected: selectedSort == null || selectedSort == 'newest',
                onTap: () => onApply(null, 'newest'),
              ),
              _SortOption(
                label: s.sortMostCollected,
                selected: selectedSort == 'mostCollected',
                onTap: () => onApply(null, 'mostCollected'),
              ),
              _SortOption(
                label: s.sortUrgentFirst,
                selected: selectedSort == 'urgentFirst',
                onTap: () => onApply(null, 'urgentFirst'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _categoryLabel(CampaignCategory cat) {
    switch (cat) {
      case CampaignCategory.treatment:
        return 'علاج';
      case CampaignCategory.food:
        return 'غذاء';
      case CampaignCategory.housing:
        return 'سكن';
      case CampaignCategory.education:
        return 'تعليم';
      case CampaignCategory.orphans:
        return 'أيتام';
      case CampaignCategory.families:
        return 'أسر محتاجة';
      case CampaignCategory.relief:
        return 'تفريج كربة';
      case CampaignCategory.mosques:
        return 'مساجد';
      case CampaignCategory.water:
        return 'مياه';
      case CampaignCategory.debtRelief:
        return 'تسديد ديون';
      case CampaignCategory.emergency:
        return 'طوارئ';
      case CampaignCategory.general:
        return 'مشاريع عامة';
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryLight,
      labelStyle: AppTypography.bodySecondary.copyWith(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      side: const BorderSide(color: AppColors.border),
      showCheckmark: false,
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryLight,
      labelStyle: AppTypography.bodySecondary.copyWith(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      side: const BorderSide(color: AppColors.border),
      showCheckmark: false,
    );
  }
}
