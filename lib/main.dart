import 'package:bazzar_hub_app/presentation/controller/initialBinding_binding.dart';
import 'package:bazzar_hub_app/presentation/controller/location_repository.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/manager/log_manager.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocationRepository.instance.initialize();
  LogManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BazzarHub',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      themeMode: ThemeMode.system,
    );
  }
}
