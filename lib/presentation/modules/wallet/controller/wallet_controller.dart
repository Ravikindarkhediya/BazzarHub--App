import 'package:bazzar_hub_app/manager/session_manager.dart';
import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../../../services/models/wallet/wallet_transactions_model.dart';

class WalletController extends GetxController {
  final ApiServices _apiService = Get.find<ApiServices>();

  RxList<WalletTransactionsModel> transactions =
      <WalletTransactionsModel>[].obs;

  var page = 1.obs;
  var totalPage = 20;
  var totalPages = 1.obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var coinBalance = "0".obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    final int coinBal = await SessionManager().getUserCoinBalance() ?? 0;
    coinBalance(coinBal.toString());
    fetchTransactions();
  }

  // FIRST TIME CALL
  Future<void> fetchTransactions() async {
    isLoading.value = true;
    page.value = 1;

    final params = {"page": page.value, "limit": totalPage, "type": "coin"};

    try {
      final response = await _apiService.getWalletTransactionsList(params);

      if (response.data.status) {
        transactions.value = response.data.data!;
        totalPages.value = response.data.pagination.pages;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // LOAD MORE (PAGINATION)
  Future<void> loadMore() async {
    if (isMoreLoading.value) return;
    if (page.value >= totalPages.value) return;

    isMoreLoading.value = true;
    page.value += 1;

    await Future.delayed(const Duration(seconds: 2));

    final params = {"page": page.value, "limit": totalPage, "type": "coin"};

    try {
      final api = await getApiClient();
      final res = await api.getWalletTransactionsList(params);

      if (res.data.status) {
        transactions.addAll(res.data.data!);
      }
    } finally {
      isMoreLoading.value = false;
    }
  }
}
