import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_service/services/session_service.dart';

import '../core/network/api_services.dart';

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => SessionService.init());
  Get.put(ApiServices());
}
