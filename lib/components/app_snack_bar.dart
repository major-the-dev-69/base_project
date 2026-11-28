import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackBarType { success, warning, error, info }

class CustomSnackBar {
  static void show({
    required String message,
    SnackBarType type = SnackBarType.success,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onTap,
    String? title,
    Widget? icon,
    bool isDismissible = true,
  }) {
    if (Get.isSnackbarOpen) {
      return;
    }
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        duration: duration,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _getBackgroundColor(type),
        borderRadius: 12,
        forwardAnimationCurve: Curves.bounceIn,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDismissible: isDismissible,
        dismissDirection: DismissDirection.horizontal,
        icon: icon ?? _getIcon(type),
        borderColor: _getBorderColor(type),
        borderWidth: 1.5,
        boxShadows: [
          BoxShadow(
            color: _getShadowColor(type),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        messageText: Text(
          message,
          style: TextStyle(
            color: _getTextColor(type),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),

        onTap: onTap != null ? (_) => onTap() : null,
        mainButton: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _getCloseButtonColor(type),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.close, color: _getTextColor(type), size: 16),
          ),
        ),
      ),
    );
  }

  static void showSuccess({
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    String? title,
    bool isDismissible = true,
  }) {
    show(
      message: message,
      type: SnackBarType.success,
      duration: duration,
      onTap: onTap,
      title: title,
      isDismissible: isDismissible,
    );
  }

  static void showWarning({
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    String? title,
    bool isDismissible = true,
  }) {
    show(
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      onTap: onTap,
      title: title,
      isDismissible: isDismissible,
    );
  }

  static void showError({
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    String? title,
    bool isDismissible = true,
  }) {
    show(
      message: message,
      type: SnackBarType.error,
      duration: duration,
      onTap: onTap,
      title: title,
      isDismissible: isDismissible,
    );
  }

  static void showInfo({
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    String? title,
    bool isDismissible = true,
  }) {
    show(
      message: message,
      type: SnackBarType.info,
      duration: duration,
      onTap: onTap,
      title: title,
      isDismissible: isDismissible,
    );
  }

  // Helper method for simple messages (like back to exit)
  static void showSimple({
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: duration,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: backgroundColor ?? Colors.black87,
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
        messageText: Text(
          message,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Private helper methods for styling
  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFFF0FDF4);
      case SnackBarType.warning:
        return const Color(0xFFFFFBEB);
      case SnackBarType.error:
        return const Color(0xFFFEF2F2);
      case SnackBarType.info:
        return const Color(0xFFEFF6FF);
    }
  }

  static Color _getBorderColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFFBBF7D0);
      case SnackBarType.warning:
        return const Color(0xFFFDE68A);
      case SnackBarType.error:
        return const Color(0xFFFECACA);
      case SnackBarType.info:
        return const Color(0xFFBFDBFE);
    }
  }

  static Color _getShadowColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF22C55E).withValues(alpha: 0.15);
      case SnackBarType.warning:
        return const Color(0xFFF59E0B).withValues(alpha: 0.15);
      case SnackBarType.error:
        return const Color(0xFFEF4444).withValues(alpha: 0.15);
      case SnackBarType.info:
        return const Color(0xFF3B82F6).withValues(alpha: 0.15);
    }
  }

  static Color _getTextColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF166534);
      case SnackBarType.warning:
        return const Color(0xFF92400E);
      case SnackBarType.error:
        return const Color(0xFF991B1B);
      case SnackBarType.info:
        return const Color(0xFF1E40AF);
    }
  }

  static Color _getIconColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF22C55E);
      case SnackBarType.warning:
        return const Color(0xFFF59E0B);
      case SnackBarType.error:
        return const Color(0xFFEF4444);
      case SnackBarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  static Color _getIconBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFFDCFCE7);
      case SnackBarType.warning:
        return const Color(0xFFFEF3C7);
      case SnackBarType.error:
        return const Color(0xFFFEE2E2);
      case SnackBarType.info:
        return const Color(0xFFDBEAFE);
    }
  }

  static Color _getCloseButtonColor(SnackBarType type) {
    return _getTextColor(type).withValues(alpha: 0.1);
  }

  static Widget _getIcon(SnackBarType type) {
    IconData iconData;
    switch (type) {
      case SnackBarType.success:
        iconData = Icons.check_circle;
        break;
      case SnackBarType.warning:
        iconData = Icons.warning;
        break;
      case SnackBarType.error:
        iconData = Icons.error;
        break;
      case SnackBarType.info:
        iconData = Icons.info;
        break;
    }

    return Container(
      margin: EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(type),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox.square(
        dimension: 35,
        child: Icon(iconData, color: _getIconColor(type), size: 20),
      ),
    );
  }
}
