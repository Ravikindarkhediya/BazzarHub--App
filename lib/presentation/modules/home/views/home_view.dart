import 'package:bazzar_hub_app/app/core/manager/log_manager.dart';
import 'package:bazzar_hub_app/presentation/services/models/marketplace/marketplace_model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/core/utils/app_spacing.dart';
import '../../../../app/data/constants/app_colors.dart';
import '../../../commons/dialogs/app_toasts.dart';
import '../../../controller/filter_controller.dart';
import '../../../services/api_service.dart';
import '../../../commons/widgets/location_bar_widget.dart';
import '../../../routes/app_routes.dart';
import '../../../services/models/categorie/categorie_model.dart';
import '../../product/views/product_detail_page.dart';
import '../widgets/header_widget.dart';
import '../widgets/category_list_widget.dart';
import '../widgets/location_selection_bottom_sheet.dart';
import '../widgets/product_grid_widget.dart';
import '../widgets/category_selection_bottom_sheet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        child: Column(
          children: [

            /// 🎯 Header Section
            HeaderWidget(),
          ],
        ),
      ),
    );
  }

}