import 'package:bazzar_hub_app/presentation/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      title: 'BazzarHub',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.signup,
      getPages: AppPages.routes,
      themeMode: ThemeMode.system,
    );
  }
}

// import 'package:bazzarhub/presentation/modules/auth/services/auth_provider.dart';
// import 'package:bazzarhub/presentation/modules/auth/views/sign_in.dart';
// import 'package:bazzarhub/presentation/modules/auth/views/signup_page.dart';
// import 'package:bazzarhub/presentation/modules/home/views/home_view.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'presentation/routes/app_routes.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (_) => AuthProvider()..initialize(),
//         ),
//       ],
//       child: MaterialApp(
//         title: 'BazzarHub',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           useMaterial3: true,
//           primarySwatch: Colors.blue,
//         ),
//
//         // Check if user is logged in
//         home: Consumer<AuthProvider>(
//           builder: (context, authProvider, child) {
//             if (authProvider.isAuthenticated) {
//               return const HomeView();
//             } else {
//               return const SignInPage();
//             }
//           },
//         ),
//
//         // Routes
//         routes: {
//           AppRoutes.login: (context) => const SignInPage(),
//           AppRoutes.signup: (context) => const SignupPage(),
//           AppRoutes.home: (context) => const HomeView(),
//         },
//       ),
//     );
//   }
// }