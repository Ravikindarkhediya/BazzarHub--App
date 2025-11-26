import 'package:bazzar_hub_app/presentation/controller/initialBinding_binding.dart';
import 'package:bazzar_hub_app/presentation/controller/location_repository.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'app/core/manager/log_manager.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      themeMode: ThemeMode.system,
    );
  }
}
