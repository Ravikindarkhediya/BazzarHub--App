import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/data/constants/app_colors.dart';
import '../../../app/data/constants/app_text_style.dart';

class AppReviewDialog extends StatefulWidget {
  final Function(double rating)? onSubmit;
  final Function()? onCancel;

  const AppReviewDialog({
    super.key,
    this.onSubmit,
    this.onCancel,
  });

  static Future<bool?> show(
      BuildContext context, {
        Function(double rating)? onSubmit,
        Function()? onCancel,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppReviewDialog(
        onSubmit: onSubmit,
        onCancel: onCancel,
      ),
    );
  }

  @override
  State<AppReviewDialog> createState() => _AppReviewDialogState();
}

class _AppReviewDialogState extends State<AppReviewDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleStarTap(TapUpDetails details, int index) {
    double localX = details.localPosition.dx;
    double starWidth = 36.0;

    setState(() {
      if (localX < starWidth / 2) {
        _rating = index + 0.5;
      } else {
        _rating = index + 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double dialogWidth = MediaQuery.of(context).size.width * 0.92;
    if (dialogWidth > 420) dialogWidth = 420;
    final logoSize = dialogWidth * 0.22;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.fromLTRB(22, 32, 22, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: logoSize,
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.store_rounded,
                color: AppColors.primary,
                size: logoSize * 0.8,
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(duration: 600.ms, begin: const Offset(0.5, 0.5)),
            ),
            const SizedBox(height: 8),

            Text(
              "BazzarHub",
              style: AppTextStyles.h2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),


            const SizedBox(height: 20),

            Text(
              "Enjoying BazzarHub?",
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "We would love to hear your feedback! Please rate your experience.",
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 26),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                double starValue = index + 1;

                IconData icon;

                if (_rating >= starValue) {
                  icon = Icons.star;
                } else if (_rating >= starValue - 0.5) {
                  icon = Icons.star_half;
                } else {
                  icon = Icons.star_border;
                }

                return GestureDetector(
                  onTapUp: (details) => _handleStarTap(details, index),
                  child: Icon(
                    icon,
                    size: 36,
                    color: AppColors.primary,
                  ).animate().scale(
                    duration: 180.ms,
                    curve: Curves.easeOutBack,
                  ),
                );
              }),
            ),

            const SizedBox(height: 34),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onCancel?.call();
                      Navigator.pop(context, false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.grey300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "No Thanks",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _rating > 0
                        ? () {
                      widget.onSubmit?.call(_rating);
                      Navigator.pop(context, true);
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
