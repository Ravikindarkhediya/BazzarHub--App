import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app/data/constants/app_colors.dart';

class ProfileCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String email;

  const ProfileCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rounded Image or Placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: (imageUrl.isNotEmpty)
              ? Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder(); // fallback if image fails
                  },
                )
              : _buildPlaceholder(),
        ),
        const SizedBox(height: 8),

        // Name
        Text(
          name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 4),

        // Email
        Text(
          email,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // Placeholder with first letter of name
  Widget _buildPlaceholder() {
    String firstLetter = (name.isNotEmpty) ? name[0].toUpperCase() : "U";

    return Container(
      width: 100,
      height: 100,
      color: AppColors.primary,
      // background color
      alignment: Alignment.center,
      child: Text(
        firstLetter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
