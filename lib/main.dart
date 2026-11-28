import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_service/base/base_widget.dart';
import 'package:go_service/core/style/theme/app_theme.dart';

import 'app/app_routes.dart';
import 'app/init_app.dart';

Future<void> main() async {
  await initApp();
  runApp(const MyApp());
}

class MyApp extends BaseWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeMode = controller.activeTheme.value;

      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: controller.appName.value,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        getPages: AppPages.pages,
        builder: (context, child) {
          return Obx(() {
            final currentTheme = controller.getThemeData(
              controller.activeTheme.value,
            );
            final isDark = currentTheme.brightness == Brightness.dark;
            final brightness = isDark ? Brightness.light : Brightness.dark;

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: brightness,
                statusBarBrightness: brightness,
                systemNavigationBarColor: currentTheme.scaffoldBackgroundColor,
                systemNavigationBarIconBrightness: brightness,
              ),
              child: Theme(
                data: currentTheme,
                child: SafeArea(
                  top: false,
                  bottom: Platform.isAndroid,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            );
          });
        },
      );
    });
  }
}
