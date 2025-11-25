  import 'package:dio/dio.dart';
  import 'package:get/get.dart';
  import 'package:google_sign_in/google_sign_in.dart';

  import '../../manager/session_manager.dart';
  import '../../app/core/utils/utils.dart';
  import '../commons/dialogs/app_toasts.dart';
  import '../routes/app_routes.dart';
  import 'api_service.dart';

  class AuthService {
    static final AuthService _instance = AuthService._internal();
    factory AuthService() => _instance;
    AuthService._internal();

    final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

    Future<void> handleGoogleSignIn() async {
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
          await requestGoogleLogin(googleAuth.idToken, googleAuth.accessToken);
        }
      } catch (error) {
        print("Error signing in with Google: $error");
        AppToast.showError("Error signing in with Google: $error");
      }
    }

    Future<void> requestGoogleLogin(String? idToken, String? accessToken) async {
      if (idToken == null) {
        AppToast.showError("Google sign-in failed, please try again.");
        return;
      }
      try {
        var services = await getApiClient();
        var params = {
          "token": idToken,
        };
        var response = await services.requestGoogleLogin(params);
        if (response.data.status) {
          if (!Utils.isEmpty(response.data.data?.token)) {
            SessionManager().saveToken(response.data.data!.token!);
          }
          if (response.data.data?.user != null) {
            SessionManager().saveUserData(response.data.data!.user!);
          }

          Get.offAllNamed(AppRoutes.homeWrapper);
        } else {
          AppToast.showError(response.data.message ?? "Something went wrong, please try again.");
        }
      } on DioException catch (e) {
        AppToast.showError('$e');
      } catch (error) {
        AppToast.showError('$error');
      }
    }
  }
