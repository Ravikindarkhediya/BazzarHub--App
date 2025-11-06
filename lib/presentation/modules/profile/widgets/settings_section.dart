import 'package:bazzar_hub_app/presentation/modules/profile/widgets/settings_tile.dart';
import 'package:flutter/material.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsTile> tiles;

  const SettingsSection({
    super.key,
    required this.title,
    required this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.horizontalMD,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        AppSpacing.verticalSpaceSM,
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.borderRadiusLG,
            boxShadow: AppColors.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: AppSpacing.borderRadiusLG,
            child: Column(
              children: tiles.asMap().entries.map((entry) {
                final index = entry.key;
                final tile = entry.value;
                return Column(
                  children: [
                    tile,
                    if (index < tiles.length - 1)
                      const Padding(
                        padding: AppSpacing.horizontalMD,
                        child: Divider(
                          height: AppSpacing.dividerHeight,
                          color: AppColors.divider,
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
