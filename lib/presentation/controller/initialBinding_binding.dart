import 'package:get/get.dart';
import '../services/api_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize ApiServices asynchronously
    // This will be available throughout the app once initialized
    Get.putAsync<ApiServices>(
      () => getApiClient(),
      permanent: true,
    );
  }
}

