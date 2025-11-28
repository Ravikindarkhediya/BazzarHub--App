import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/utils/app_language.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../../app/data/constants/app_text_style.dart';

class LanguageActionSheet {
  static Future<Locale?> show(BuildContext context) async {
    return await showCupertinoModalPopup<Locale>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          'Select Language'.tr,
          style: AppTextStyles.h4.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        actions: <Widget>[
          _buildLanguageAction(
            context,
            language: 'हिंदी',
            locale: const Locale('hi', 'IN'),
          ),
          _buildLanguageAction(
            context,
            language: 'ગુજરાતી',
            locale: const Locale('gu', 'IN'),
          ),
          _buildLanguageAction(
            context,
            language: 'English',
            locale: const Locale('en', 'US'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildLanguageAction(
      BuildContext context, {
        required String language,
        required Locale locale,
      }) {
    final isSelected = Get.locale?.languageCode == locale.languageCode;

    return CupertinoActionSheetAction(
      onPressed: () {
        if (!isSelected) {
          AppLanguage.setLanguage(locale.languageCode);
          Get.updateLocale(locale);
          Navigator.pop(context, locale);
        } else {
          Navigator.pop(context);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            language,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }
}
