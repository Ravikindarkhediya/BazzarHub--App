import 'package:bazzar_hub_app/manager/session_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../presentation/services/api_service.dart';

class WalletManager {

  static final WalletManager _instance = WalletManager._internal();

  factory WalletManager() {
    return _instance;
  }

  WalletManager._internal();

  // -------------------------------------------------------------
  //                    WALLET PEN BALANCE
  // -------------------------------------------------------------


  Future<void> requestWalletPenBalance() async {
    try {
      var services = await getApiClient();
      var response = await services.getPenBalance();
      if (response.data.status) {
        SessionManager().setUserPenBalance(response.data.data?.balance ?? 0);
      }else{
        debugPrint("Pen balance not fetch");
      }
    } on DioException catch (e) {
      debugPrint("Dio error: $e");
    } catch (error) {
      debugPrint("Error: $error");
    }
  }

  // -------------------------------------------------------------
  //                    WALLET COIN BALANCE
  // -------------------------------------------------------------


  Future<void> requestWalletCoinBalance() async {
    try {
      var services = await getApiClient();
      var response = await services.getCoinBalance();
      if (response.data.status) {
        SessionManager().setUserCoinBalance(response.data.data?.balance ?? 0);
      }else{
        debugPrint("Coin balance not fetch");
      }
    } on DioException catch (e) {
      debugPrint("Dio error: $e");
    } catch (error) {
      debugPrint("Error: $error");
    }
  }
}
