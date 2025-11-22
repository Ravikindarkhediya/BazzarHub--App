// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import '../../../../app/core/utils/app_spacing.dart';
// import '../../../../app/data/constants/app_colors.dart';
// import '../../../../app/data/constants/app_text_style.dart';
// import '../../controller/filter_controller.dart';
//
// class FilterSideSheet extends StatefulWidget {
//   final FilterController filterController;
//
//   const FilterSideSheet({
//     super.key,
//     required this.filterController,
//   });
//
//   /// Show the side sheet
//   static void show(
//       BuildContext context, {
//         required FilterController filterController,
//       }) {
//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: 'Dismiss',
//       barrierColor: Colors.black54,
//       transitionDuration: const Duration(milliseconds: 350),
//       pageBuilder: (context, animation, secondaryAnimation) {
//         return FilterSideSheet(filterController: filterController);
//       },
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         return SlideTransition(
//           position: Tween<Offset>(
//             begin: const Offset(1, 0),
//             end: Offset.zero,
//           ).animate(
//             CurvedAnimation(
//               parent: animation,
//               curve: Curves.easeOutCubic,
//             ),
//           ),
//           child: child,
//         );
//       },
//     );
//   }
//
//   @override
//   State<FilterSideSheet> createState() => _FilterSideSheetState();
// }
//
// class _FilterSideSheetState extends State<FilterSideSheet> {
//   late TextEditingController _minPriceController;
//   late TextEditingController _maxPriceController;
//   late String _selectedSort;
//
//   @override
//   void initState() {
//     super.initState();
//     _minPriceController = TextEditingController(
//       text: widget.filterController.minPrice?.toInt().toString() ?? '',
//     );
//     _maxPriceController = TextEditingController(
//       text: widget.filterController.maxPrice?.toInt().toString() ?? '',
//     );
//     _selectedSort = widget.filterController.sortBy;
//   }
//
//   @override
//   void dispose() {
//     _minPriceController.dispose();
//     _maxPriceController.dispose();
//     super.dispose();
//   }
//
//   void _applyFilters() {
//     try {
//       // Parse price inputs
//       double? minPrice;
//       double? maxPrice;
//
//       if (_minPriceController.text.isNotEmpty) {
//         minPrice = double.tryParse(_minPriceController.text);
//         if (minPrice == null) {
//           _showError('Invalid minimum price');
//           return;
//         }
//       }
//
//       if (_maxPriceController.text.isNotEmpty) {
//         maxPrice = double.tryParse(_maxPriceController.text);
//         if (maxPrice == null) {
//           _showError('Invalid maximum price');
//           return;
//         }
//       }
//
//       // Validate price range
//       if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
//         _showError('Minimum price cannot be greater than maximum');
//         return;
//       }
//
//       // Apply filters
//       widget.filterController.updatePriceRange(min: minPrice, max: maxPrice);
//       widget.filterController.updateSortBy(_selectedSort);
//       widget.filterController.applyFilters();
//
//       debugPrint('✅ Filters Applied Successfully');
//       FocusScope.of(context).unfocus();
//       Navigator.pop(context);
//
//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Filters applied: ${widget.filterController.resultCount} products found'),
//           backgroundColor: AppColors.success,
//           behavior: SnackBarBehavior.floating,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     } catch (e) {
//       debugPrint('❌ Error applying filters: $e');
//       _showError('Failed to apply filters');
//     }
//   }
//
//   void _resetFilters() {
//     setState(() {
//       _minPriceController.clear();
//       _maxPriceController.clear();
//       _selectedSort = 'newest';
//     });
//     widget.filterController.resetFilters();
//     debugPrint('🔄 Filters Reset');
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Filters reset successfully'),
//         backgroundColor: AppColors.info,
//         behavior: SnackBarBehavior.floating,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: AppColors.error,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         /// Blurred Background
//         BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//           child: Container(
//             color: Colors.black.withOpacity(0.2),
//           ),
//         ),
//
//         /// Side Sheet Container
//         Align(
//           alignment: Alignment.centerRight,
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.85,
//               height: double.infinity,
//               decoration: BoxDecoration(
//                 color: AppColors.background,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(24),
//                   bottomLeft: Radius.circular(24),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.black.withOpacity(0.2),
//                     blurRadius: 20,
//                     offset: const Offset(-5, 0),
//                   ),
//                 ],
//               ),
//               child: SafeArea(
//                 child: Column(
//                   children: [
//                     /// Header
//                     _buildHeader(),
//
//                     /// Scrollable Content
//                     Expanded(
//                       child: SingleChildScrollView(
//                         padding: const EdgeInsets.all(AppSpacing.md),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             /// Sort By Section
//                             _buildSortSection(),
//
//                             AppSpacing.verticalSpaceXL,
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     /// Action Buttons
//                     _buildActionButtons(),
//                   ],
//                 ),
//               ),
//             ),
//           )
//               .animate()
//               .fadeIn(duration: 350.ms)
//               .slideX(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.md),
//       decoration: const BoxDecoration(
//         color: AppColors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: AppColors.border,
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Text(
//             'Filters',
//             style: AppTextStyles.h5.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const Spacer(),
//           IconButton(
//             onPressed: () {
//               FocusScope.of(context).unfocus();
//               Navigator.pop(context);
//             },
//             icon: Container(
//               padding: const EdgeInsets.all(AppSpacing.xs),
//               decoration: const BoxDecoration(
//                 color: AppColors.grey100,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.close_rounded,
//                 size: 20,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPriceSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.currency_rupee_rounded,
//               size: 20,
//               color: AppColors.primary,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'Price Range',
//               style: AppTextStyles.h6.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//
//         AppSpacing.verticalSpaceMD,
//
//         Row(
//           children: [
//             Expanded(
//               child: _buildPriceInput(
//                 controller: _minPriceController,
//                 label: 'Min Price',
//                 hint: '0',
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
//               child: Text(
//                 'to',
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: _buildPriceInput(
//                 controller: _maxPriceController,
//                 label: 'Max Price',
//                 hint: '∞',
//               ),
//             ),
//           ],
//         ),
//
//         AppSpacing.verticalSpaceSM,
//
//         /// Quick Price Buttons
//         Wrap(
//           spacing: AppSpacing.xs,
//           runSpacing: AppSpacing.xs,
//           children: [
//             _buildQuickPriceChip('Under ₹10K', max: 10000),
//             _buildQuickPriceChip('₹10K - ₹50K', min: 10000, max: 50000),
//             _buildQuickPriceChip('₹50K - ₹1L', min: 50000, max: 100000),
//             _buildQuickPriceChip('Above ₹1L', min: 100000),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPriceInput({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: AppTextStyles.caption.copyWith(
//             color: AppColors.textSecondary,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 6),
//         TextField(
//           controller: controller,
//           keyboardType: TextInputType.number,
//           style: AppTextStyles.bodyMedium,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: AppTextStyles.bodyMedium.copyWith(
//               color: AppColors.textHint,
//             ),
//             prefixText: '₹ ',
//             filled: true,
//             fillColor: AppColors.white,
//             border: OutlineInputBorder(
//               borderRadius: AppSpacing.borderRadiusSM,
//               borderSide: BorderSide(color: AppColors.border),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: AppSpacing.borderRadiusSM,
//               borderSide: BorderSide(color: AppColors.border),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: AppSpacing.borderRadiusSM,
//               borderSide: BorderSide(color: AppColors.primary, width: 2),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: AppSpacing.sm,
//               vertical: AppSpacing.sm,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildQuickPriceChip(String label, {double? min, double? max}) {
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _minPriceController.text = min?.toInt().toString() ?? '';
//           _maxPriceController.text = max?.toInt().toString() ?? '';
//         });
//       },
//       borderRadius: AppSpacing.borderRadiusSM,
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: AppSpacing.sm,
//           vertical: AppSpacing.xs,
//         ),
//         decoration: BoxDecoration(
//           color: AppColors.primary.withOpacity(0.1),
//           borderRadius: AppSpacing.borderRadiusSM,
//           border: Border.all(
//             color: AppColors.primary.withOpacity(0.3),
//           ),
//         ),
//         child: Text(
//           label,
//           style: AppTextStyles.caption.copyWith(
//             color: AppColors.primary,
//             fontWeight: FontWeight.w600,
//             fontSize: 11,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSortSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.sort_rounded,
//               size: 20,
//               color: AppColors.primary,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'Sort By',
//               style: AppTextStyles.h6.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//
//         AppSpacing.verticalSpaceMD,
//
//         _buildSortOption(
//           value: 'newest',
//           label: 'Newest First',
//           icon: Icons.new_releases_rounded,
//         ),
//         _buildSortOption(
//           value: 'oldest',
//           label: 'Oldest First',
//           icon: Icons.history_rounded,
//         ),
//         _buildSortOption(
//           value: 'price_low',
//           label: 'Price: Low to High',
//           icon: Icons.arrow_upward_rounded,
//         ),
//         _buildSortOption(
//           value: 'price_high',
//           label: 'Price: High to Low',
//           icon: Icons.arrow_downward_rounded,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSortOption({
//     required String value,
//     required String label,
//     required IconData icon,
//   }) {
//     final isSelected = _selectedSort == value;
//
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedSort = value;
//         });
//         debugPrint('🔀 Sort changed to: $value');
//       },
//       borderRadius: AppSpacing.borderRadiusSM,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: AppSpacing.sm),
//         padding: const EdgeInsets.all(AppSpacing.sm),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.white,
//           borderRadius: AppSpacing.borderRadiusSM,
//           border: Border.all(
//             color: isSelected ? AppColors.primary : AppColors.border,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               size: 20,
//               color: isSelected ? AppColors.primary : AppColors.textSecondary,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 label,
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   color: isSelected ? AppColors.primary : AppColors.textPrimary,
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                 ),
//               ),
//             ),
//             if (isSelected)
//               Icon(
//                 Icons.check_circle_rounded,
//                 size: 20,
//                 color: AppColors.primary,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.md),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         border: const Border(
//           top: BorderSide(
//             color: AppColors.border,
//             width: 1,
//           ),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.grey900.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           /// Reset Button
//           Expanded(
//             child: OutlinedButton(
//               onPressed: _resetFilters,
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: AppColors.textPrimary,
//                 side: BorderSide(color: AppColors.border),
//                 padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: AppSpacing.borderRadiusMD,
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.refresh_rounded, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Reset',
//                     style: AppTextStyles.button,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           AppSpacing.horizontalSpaceMD,
//
//           /// Apply Button
//           Expanded(
//             flex: 2,
//             child: ElevatedButton(
//               onPressed: _applyFilters,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: AppColors.white,
//                 padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: AppSpacing.borderRadiusMD,
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.check_rounded, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Apply Filters',
//                     style: AppTextStyles.button.copyWith(
//                       color: AppColors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }