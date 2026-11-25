import 'package:flutter/material.dart';

/// Centralized themed button supporting primary, outlined, and loading states.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    this.onTap,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  final String title;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    VoidCallback? effectiveOnTap;
    if (!isLoading) {
      effectiveOnTap = onTap;
    }

    Color spinnerColor = colorScheme.onPrimary;
    if (isOutlined) {
      spinnerColor = colorScheme.primary;
    }

    Widget child;
    if (isLoading) {
      child = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: spinnerColor,
        ),
      );
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(title),
        ],
      );
    }

    if (isOutlined) {
      return OutlinedButton(
        onPressed: effectiveOnTap,
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: effectiveOnTap,
      child: child,
    );
  }
}
