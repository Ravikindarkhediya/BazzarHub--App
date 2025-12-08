import 'dart:async';
import 'package:bazzar_hub_app/app/data/constants/app_colors.dart';
import 'package:bazzar_hub_app/presentation/modules/wallet/transaction_item_widget.dart';
import 'package:bazzar_hub_app/presentation/modules/wallet/wallet_controller.dart';
import 'package:bazzar_hub_app/presentation/services/models/wallet/wallet_transactions_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../app/core/utils/app_spacing.dart';
import '../../../app/data/constants/app_text_style.dart';
import '../../services/api_service.dart';


class WalletScreen extends StatefulWidget {

  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
  
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late WalletController _walletController;
  late final TabController _tabController;
  bool _isLoading = false;
  List<WalletTransactionsModel>? walletTransactionListModel;

  @override
  void initState() {
    super.initState();
    _walletController = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController(), permanent: true);
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    requestTransactionList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> requestTransactionList() async {
    setState(() {
      _isLoading = true;
      walletTransactionListModel = null;
    });

    final params = {
      "page": 1,
      "limit": 30,
      "type": "coin",
    };

    try {
      final apiClient = await getApiClient();
      final response = await apiClient.getWalletTransactionsList(params);
      if (response.data.status) {
        setState(() {
          walletTransactionListModel = response.data.data;
        });
      } else {

      }
    } catch (e, s) {
      print("Error: $e");
      print("Stacktrace: $s");

    }
    finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Container(
              height: kToolbarHeight,
              decoration: const BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
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
              decoration: BoxDecoration(
                color: AppColors.white,
              ),
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
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
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl,
                                  vertical: AppSpacing.sm,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMD),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Redeem",
                                style:
                                AppTextStyles.button.copyWith(color: AppColors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
              ),

            ),

            // TabBar below app bar
            Container(
              color: AppColors.white,
              child: TabBar(
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
            ),

            // Expanded TabBarView holds scrollable content for each tab
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
    );
  }

  Widget _buildTransactionsTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final transactions = walletTransactionListModel;

    if(_isLoading){
      return Center(child: CircularProgressIndicator());
    }

    if (transactions == null || transactions.isEmpty) {
      return const Center(
        child: Text(
          "No transactions found",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];

        return Column(
          children: [
            TransactionItemWidget(transaction: transaction),
            if (index != transactions.length - 1)
              const Divider(
                color: Colors.grey,
                thickness: 0.5,
                height: 1,
              ),
          ],
        );
      },
    );

  }


  Widget _buildRedemptionsTab() {
    return SizedBox();
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
}
