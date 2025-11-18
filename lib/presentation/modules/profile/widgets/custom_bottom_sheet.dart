import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final List<BottomSheetItem> items;
  final Function(String)? onItemSelected;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.items,
    this.onItemSelected,
  });

  static void showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(
        title: 'Language',
        items: BottomSheetData.languages,
        onItemSelected: (selectedLanguage) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Language changed to $selectedLanguage'),
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusSM,
              ),
            ),
          );
        },
      ),
    );
  }

  static void showCurrencyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(
        title: 'Currency',
        items: BottomSheetData.currencies,
        onItemSelected: (selectedCurrency) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Currency changed to $selectedCurrency'),
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusSM,
              ),
            ),
          );
        },
      ),
    );
  }

  static void showPrivacyPolicyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(
        title: 'Privacy Policy',
        items: BottomSheetData.privacyPolicySections,
        onItemSelected: (section) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening: $section'),
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusSM,
              ),
            ),
          );
        },
      ),
    );
  }

  static void showTermsAndConditionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(
        title: 'Terms & Conditions',
        items: BottomSheetData.termsAndConditionsSections,
        onItemSelected: (section) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening: $section'),
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusSM,
              ),
            ),
          );
        },
      ),
    );
  }

  static void showFAQBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(
        title: 'Frequently Asked Questions',
        items: BottomSheetData.faqItems,
        onItemSelected: (question) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewing: $question'),
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusSM,
              ),
            ),
          );
        },
      ),
    );
  }

  static void showContactSupportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(
        title: 'Contact Support',
        items: BottomSheetData.contactSupportOptions,
        onItemSelected: (option) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contacting via: $option'),
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusSM,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          AppSpacing.verticalSpaceMD,

          // Items list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: AppColors.textSecondary,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  onTap: () => onItemSelected?.call(item.title),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        if (item.icon != null) ...[
                          Icon(
                            item.icon,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          AppSpacing.horizontalSpaceMD,
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (item.subtitle != null) ...[
                                AppSpacing.verticalSpaceXS,
                                Text(
                                  item.subtitle!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (item.trailing != null) ...[
                          Text(
                            item.trailing!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          AppSpacing.horizontalSpaceSM,
                        ],
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          AppSpacing.verticalSpaceLG,
        ],
      ),
    );
  }
}

class BottomSheetItem {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? trailing;

  BottomSheetItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });
}

class BottomSheetData {
  static List<BottomSheetItem> languages = [
    BottomSheetItem(
      title: 'English',
      subtitle: 'Default language',
      trailing: 'EN',
    ),
    BottomSheetItem(
      title: 'Spanish',
      subtitle: 'Español',
      trailing: 'ES',
    ),
    BottomSheetItem(
      title: 'French',
      subtitle: 'Français',
      trailing: 'FR',
    ),
    BottomSheetItem(
      title: 'German',
      subtitle: 'Deutsch',
      trailing: 'DE',
    ),
    BottomSheetItem(
      title: 'Italian',
      subtitle: 'Italiano',
      trailing: 'IT',
    ),
    BottomSheetItem(
      title: 'Portuguese',
      subtitle: 'Português',
      trailing: 'PT',
    ),
    BottomSheetItem(
      title: 'Chinese',
      subtitle: '中文',
      trailing: 'ZH',
    ),
    BottomSheetItem(
      title: 'Japanese',
      subtitle: '日本語',
      trailing: 'JA',
    ),
    BottomSheetItem(
      title: 'Arabic',
      subtitle: 'العربية',
      trailing: 'AR',
    ),
    BottomSheetItem(
      title: 'Hindi',
      subtitle: 'हिन्दी',
      trailing: 'HI',
    ),
  ];

  static List<BottomSheetItem> currencies = [
    BottomSheetItem(
      title: 'US Dollar',
      subtitle: 'United States Dollar',
      trailing: 'USD',
    ),
    BottomSheetItem(
      title: 'Euro',
      subtitle: 'European Union Euro',
      trailing: 'EUR',
    ),
    BottomSheetItem(
      title: 'British Pound',
      subtitle: 'United Kingdom Pound',
      trailing: 'GBP',
    ),
    BottomSheetItem(
      title: 'Japanese Yen',
      subtitle: 'Japan Yen',
      trailing: 'JPY',
    ),
    BottomSheetItem(
      title: 'Indian Rupee',
      subtitle: 'India Rupee',
      trailing: 'INR',
    ),
    BottomSheetItem(
      title: 'Canadian Dollar',
      subtitle: 'Canada Dollar',
      trailing: 'CAD',
    ),
    BottomSheetItem(
      title: 'Australian Dollar',
      subtitle: 'Australia Dollar',
      trailing: 'AUD',
    ),
    BottomSheetItem(
      title: 'Swiss Franc',
      subtitle: 'Switzerland Franc',
      trailing: 'CHF',
    ),
    BottomSheetItem(
      title: 'Chinese Yuan',
      subtitle: 'China Yuan',
      trailing: 'CNY',
    ),
    BottomSheetItem(
      title: 'UAE Dirham',
      subtitle: 'United Arab Emirates Dirham',
      trailing: 'AED',
    ),
  ];

  static List<BottomSheetItem> privacyPolicySections = [
    BottomSheetItem(
      title: 'Information We Collect',
      subtitle: 'What data we gather from users',
      icon: Icons.info_outline,
    ),
    BottomSheetItem(
      title: 'How We Use Your Information',
      subtitle: 'Purpose of data collection',
      icon: Icons.settings_applications,
    ),
    BottomSheetItem(
      title: 'Data Sharing & Disclosure',
      subtitle: 'When and how we share data',
      icon: Icons.share,
    ),
    BottomSheetItem(
      title: 'Data Security',
      subtitle: 'How we protect your information',
      icon: Icons.security,
    ),
    BottomSheetItem(
      title: 'Your Rights & Choices',
      subtitle: 'Control over your personal data',
      icon: Icons.manage_accounts,
    ),
    BottomSheetItem(
      title: 'Cookies & Tracking',
      subtitle: 'How we use cookies and tracking',
      icon: Icons.cookie,
    ),
    BottomSheetItem(
      title: 'International Data Transfers',
      subtitle: 'Cross-border data handling',
      icon: Icons.language,
    ),
    BottomSheetItem(
      title: 'Contact for Privacy Matters',
      subtitle: 'How to reach our privacy team',
      icon: Icons.contact_mail,
    ),
  ];

  static List<BottomSheetItem> termsAndConditionsSections = [
    BottomSheetItem(
      title: 'Acceptance of Terms',
      subtitle: 'Agreement to our terms',
      icon: Icons.gavel,
    ),
    BottomSheetItem(
      title: 'User Accounts',
      subtitle: 'Account creation and management',
      icon: Icons.person,
    ),
    BottomSheetItem(
      title: 'Acceptable Use',
      subtitle: 'Proper usage guidelines',
      icon: Icons.check_circle_outline,
    ),
    BottomSheetItem(
      title: 'Intellectual Property',
      subtitle: 'Content ownership and rights',
      icon: Icons.copyright,
    ),
    BottomSheetItem(
      title: 'Payment Terms',
      subtitle: 'Billing and payment policies',
      icon: Icons.payment,
    ),
    BottomSheetItem(
      title: 'Prohibited Activities',
      subtitle: 'Actions not allowed on platform',
      icon: Icons.block,
    ),
    BottomSheetItem(
      title: 'Dispute Resolution',
      subtitle: 'Handling conflicts and issues',
      icon: Icons.handshake,
    ),
    BottomSheetItem(
      title: 'Termination',
      subtitle: 'Account closure policies',
      icon: Icons.cancel,
    ),
  ];

  static List<BottomSheetItem> faqItems = [
    BottomSheetItem(
      title: 'How do I create an account?',
      subtitle: 'Step-by-step account setup guide',
      icon: Icons.person_add,
    ),
    BottomSheetItem(
      title: 'How to list items for sale?',
      subtitle: 'Creating and managing listings',
      icon: Icons.add_shopping_cart,
    ),
    BottomSheetItem(
      title: 'Payment methods accepted',
      subtitle: 'Available payment options',
      icon: Icons.payment,
    ),
    BottomSheetItem(
      title: 'Shipping and delivery',
      subtitle: 'Delivery options and timelines',
      icon: Icons.local_shipping,
    ),
    BottomSheetItem(
      title: 'Return and refund policy',
      subtitle: 'How returns and refunds work',
      icon: Icons.assignment_return,
    ),
    BottomSheetItem(
      title: 'How to contact sellers?',
      subtitle: 'Communication with other users',
      icon: Icons.chat,
    ),
    BottomSheetItem(
      title: 'Account security tips',
      subtitle: 'Keeping your account safe',
      icon: Icons.security,
    ),
    BottomSheetItem(
      title: 'Reporting issues or problems',
      subtitle: 'How to report concerns',
      icon: Icons.report_problem,
    ),
    BottomSheetItem(
      title: 'Deleting your account',
      subtitle: 'Account removal process',
      icon: Icons.delete_forever,
    ),
  ];

  static List<BottomSheetItem> contactSupportOptions = [
    BottomSheetItem(
      title: 'Live Chat',
      subtitle: 'Chat with our support team instantly',
      icon: Icons.chat,
      trailing: 'Available 24/7',
    ),
    BottomSheetItem(
      title: 'Email Support',
      subtitle: 'Send us an email',
      icon: Icons.email,
      trailing: 'support@bazzarhub.com',
    ),
    BottomSheetItem(
      title: 'Phone Support',
      subtitle: 'Call our helpline',
      icon: Icons.phone,
      trailing: '+1-800-BHAZZAR',
    ),
    BottomSheetItem(
      title: 'WhatsApp Support',
      subtitle: 'Connect via WhatsApp',
      icon: Icons.message,
      trailing: '+1-800-BHAZZAR',
    ),
    BottomSheetItem(
      title: 'Help Center',
      subtitle: 'Browse our knowledge base',
      icon: Icons.help_center,
    ),
    BottomSheetItem(
      title: 'Report a Bug',
      subtitle: 'Report technical issues',
      icon: Icons.bug_report,
    ),
    BottomSheetItem(
      title: 'Feature Request',
      subtitle: 'Suggest new features',
      icon: Icons.lightbulb,
    ),
    BottomSheetItem(
      title: 'Community Forum',
      subtitle: 'Get help from other users',
      icon: Icons.forum,
    ),
  ];
}
