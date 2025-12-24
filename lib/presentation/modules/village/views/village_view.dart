import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bazzar_hub_app/app/core/utils/app_spacing.dart';
import 'package:bazzar_hub_app/app/data/constants/app_colors.dart';
import 'package:bazzar_hub_app/app/data/constants/app_text_style.dart';
import 'package:bazzar_hub_app/presentation/modules/village/views/panchayat_form_screen.dart';



class VillageView extends StatelessWidget {
  const VillageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Village',
          style: AppTextStyles.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVillageOverview(),
            const SizedBox(height: AppSpacing.xl),
            _buildVillageFeatures(),
            const SizedBox(height: AppSpacing.xl),
            _buildPanchayatSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildRecentActivity(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildVillageOverview() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_city,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Your Village',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Connect with your local community and discover nearby services',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('250+', 'Villagers'),
              _buildStatItem('15+', 'Businesses'),
              _buildStatItem('50+', 'Activities'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h5.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVillageFeatures() {
    final features = [
      {'icon': Icons.people, 'title': 'Villagers', 'subtitle': 'Connect with your neighbors'},
      {'icon': Icons.store, 'title': 'Local Businesses', 'subtitle': 'Discover nearby shops'},
      {'icon': Icons.event, 'title': 'Events', 'subtitle': 'Join local activities'},
      {'icon': Icons.chat, 'title': 'Village Chat', 'subtitle': 'Community discussions'},
      {'icon': Icons.account_balance, 'title': 'Panchayat', 'subtitle': 'Local governance'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth > 1200;
        final isTablet = screenWidth > 700 && screenWidth <= 1200;
        final isLargeMobile = screenWidth > 450 && screenWidth <= 700;
        
        int crossAxisCount;
        double childAspectRatio;
        double spacing = AppSpacing.md;
        
        if (isDesktop) {
          crossAxisCount = 5;
          childAspectRatio = 1.5;
        } else if (isTablet) {
          crossAxisCount = 3;
          childAspectRatio = 1.8;
        } else if (isLargeMobile) {
          crossAxisCount = 2;
          childAspectRatio = 2.0;
        } else {
          // Small mobile
          crossAxisCount = 2;
          childAspectRatio = 1.8;
          spacing = AppSpacing.sm;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                'Village Features',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              children: features.map((feature) {
                return GestureDetector(
                  onTap: feature['title'] == 'Panchayat' 
                      ? _navigateToPanchayat 
                      : null,
                  child: _buildFeatureItem(
                    icon: feature['icon'] as IconData,
                    title: feature['title'] as String,
                    subtitle: feature['subtitle'] as String,
                    isClickable: feature['title'] == 'Panchayat',
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPanchayat() {
    Get.to(() => const PanchayatFormScreen());
  }

  Widget _buildPanchayatSection() {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    final isDesktop = screenWidth > 900;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Panchayat & Local Governance',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isDesktop)
                ElevatedButton(
                  onPressed: _navigateToPanchayat,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add New'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Manage and explore local governance, public services, and community resources in your village.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (!isDesktop) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToPanchayat,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add New Panchayat'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isClickable = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isClickable 
                  ? AppColors.primary 
                  : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isClickable ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isClickable) 
            Icon(
              Icons.arrow_forward_ios, 
              size: 14, 
              color: AppColors.primary.withOpacity(0.7)
            ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActivityItem(
          'New event: Village Fair 2023',
          '2 hours ago',
          Icons.event,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildActivityItem(
          'New business: Local Grocery Store',
          '5 hours ago',
          Icons.store,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildActivityItem(
          'New villager joined: John Doe',
          '1 day ago',
          Icons.person_add,
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
