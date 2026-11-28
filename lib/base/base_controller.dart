import 'package:get/get.dart';
import 'package:go_service/core/network/api_services.dart';
import 'package:go_service/services/session_service.dart';

class BaseController extends GetxController {
  final isLoading = false.obs;

  void startLoading() {
    isLoading.value = true;
  }

  void stopLoading() {
    isLoading.value = false;
  }

  final api = Get.find<ApiServices>();
  final session = Get.find<SessionService>();
}
