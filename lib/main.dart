import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BazzarHub',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.homeWrapper,
      getPages: AppPages.routes,
      themeMode: ThemeMode.system,
    );
  }
}
