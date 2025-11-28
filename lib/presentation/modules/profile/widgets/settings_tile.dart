import 'package:flutter/material.dart';

import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;  // ✅ Added custom trailing parameter
  final bool hasToggle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback? onTap;
  final bool showArrow;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,  // ✅ Added to constructor
    this.hasToggle = false,
    this.toggleValue,
    this.onToggleChanged,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasToggle ? null : onTap,
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Row(
            children: [
              // Icon Container
              Container(
                width: AppSpacing.avatarSM,
                height: AppSpacing.avatarSM,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusSM,
                ),
                child: Icon(
                  icon,
                  size: AppSpacing.iconSM,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.horizontalSpaceMD,

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      AppSpacing.verticalSpaceXS,
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ✅ Updated Trailing Widget Logic
              if (trailing != null)
                trailing!  // Custom trailing widget takes priority
              else if (hasToggle && onToggleChanged != null)
                Switch.adaptive(
                  value: toggleValue ?? false,
                  onChanged: onToggleChanged,
                  activeColor: AppColors.accent,
                  activeTrackColor: AppColors.accentLight.withOpacity(0.5),
                )
              else if (!hasToggle && showArrow)
                  const Icon(
                    Icons.chevron_right,
                    size: AppSpacing.iconMD,
                    color: AppColors.grey400,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
