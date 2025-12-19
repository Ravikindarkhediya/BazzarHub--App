import 'package:bazzar_hub_app/presentation/controller/location_repository.dart';
import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:bazzar_hub_app/presentation/commons/controllers/route_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/painting.dart';
import 'app/core/manager/log_manager.dart';
import 'presentation/services/api_service.dart';
import 'firebase_options.dart';


Future<void> main() async {

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 200;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 60 * 1024 * 1024;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocationRepository.instance.initialize();
  LogManager.initialize();
  // Ensure ApiServices is registered before any Get.find() calls
  await Get.putAsync<ApiServices>(() async => await getApiClient(),
      permanent: true);
  // Initialize RouteController for web header navigation
  Get.put(RouteController(), permanent: true);
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
      getPages: AppPages.routes,
      themeMode: ThemeMode.system,
    );
  }
}
