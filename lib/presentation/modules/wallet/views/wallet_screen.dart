import 'dart:async';
import 'package:bazzar_hub_app/app/data/constants/app_colors.dart';
import 'package:bazzar_hub_app/presentation/modules/wallet/widgets/transaction_item_widget.dart';
import 'package:bazzar_hub_app/presentation/modules/wallet/controller/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../app/core/utils/app_spacing.dart';
import '../../../../../app/data/constants/app_text_style.dart';


class WalletScreen extends StatefulWidget {

  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
  
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late WalletController _walletController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _walletController = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController(), permanent: false);
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _tabController.dispose();
      WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          color: AppColors.white,
          child: Column(
            children: [
              // Custom AppBar
              Container(
                height: kToolbarHeight,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    Spacer(),
                    Spacer(),
                    Spacer(),
                    Spacer(),
                    Spacer(),
                    Expanded(
                      flex: 9,
                      child: Center(
                        child:
                        Text(
                          'Wallet',
                          style: AppTextStyles.h5.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -0.3, end: 0),
                      ),
                    ),

                    Spacer(flex: 9),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppSpacing.borderRadiusLG,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Obx(() {
                          return _buildWalletInfo(
                            "Coin Balance",
                            _walletController.coinBalance.value,
                            "assets/icons/icon_coin_balance.png",
                          );
                        }),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () {
                            _launchURL();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.sm,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Redeem",
                            style: AppTextStyles.button.copyWith(color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // TabBar below app bar
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: "Transactions"),
                  Tab(text: "Redeem History"),
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTransactionsTab(),
                    _buildRedemptionsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Obx(() {
      if (_walletController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_walletController.transactions.isEmpty) {
        return const Center(
          child: Text(
            "No transactions found",
            style: TextStyle(fontSize: 16),
          ),
        );
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels ==
              scrollInfo.metrics.maxScrollExtent) {
            _walletController.loadMore();
          }
          return true;
        },
        child: ListView.builder(
          itemCount: _walletController.transactions.length +
              (_walletController.isMoreLoading.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _walletController.transactions.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final transaction = _walletController.transactions[index];

            return Column(
              children: [
                TransactionItemWidget(transaction: transaction),
                if (index != _walletController.transactions.length - 1)
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                    height: 1,
                  ),
              ],
            );
          },
        ),
      );
    });
  }


  Widget _buildRedemptionsTab() {
    return const Center(
      child: Text(
        "No redeem history found",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildWalletInfo(String title,String value,String iconPath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 22,
              height: 22,
              color: AppColors.primary,
            ),

            const SizedBox(width: 6),

            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _launchURL() async {
    final Uri uri = Uri.parse("https://en.wikipedia.org/wiki/Terms_of_service");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the link'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
