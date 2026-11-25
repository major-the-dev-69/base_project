import 'package:flutter/material.dart';

/// Centralized themed decorations and state widgets.
class AppDecorations {
  AppDecorations._();

  /// Standard rounded top decoration for bottom sheets, sourced from theme.
  static BoxDecoration bottomSheet(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color:
          color ??
          theme.bottomSheetTheme.backgroundColor ??
          theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    );
  }

  /// Selected / unselected container decoration, sourced from theme.
  static BoxDecoration selection(
    BuildContext context, {
    required bool isSelected,
    double radius = 12,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    Color backgroundColor = colorScheme.surface;
    Color borderColor = colorScheme.outline;
    double borderWidth = 1;

    if (isSelected) {
      backgroundColor = colorScheme.primaryContainer.withValues(alpha: 0.45);
      borderColor = colorScheme.primary;
      borderWidth = 1.5;
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: borderWidth),
    );
  }
}

/// Centralized themed bottom sheet wrapper with optional drag handle.
class AppBottomSheetContainer extends StatelessWidget {
  const AppBottomSheetContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
    this.showDragHandle = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: AppDecorations.bottomSheet(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) ...[
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

/// Centralized themed selectable container for selected / unselected states.
class AppSelectableContainer extends StatelessWidget {
  const AppSelectableContainer({
    super.key,
    required this.isSelected,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.radius = 12,
  });

  final bool isSelected;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: padding,
        decoration: AppDecorations.selection(
          context,
          isSelected: isSelected,
          radius: radius,
        ),
        child: child,
      ),
    );
  }
}

/// Centralized themed radio option using [RadioGroup] / [RadioListTile] style.
class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.title,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    VoidCallback? handleTap;
    if (onChanged != null) {
      handleTap = () => onChanged!(value);
    }

    FontWeight labelWeight = FontWeight.w400;
    if (isSelected) {
      labelWeight = FontWeight.w600;
    }

    Widget content;
    if (title == null) {
      content = Radio<T>(value: value);
    } else {
      content = AppSelectableContainer(
        isSelected: isSelected,
        onTap: handleTap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Radio<T>(value: value),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: labelWeight,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: onChanged ?? (_) {},
      child: content,
    );
  }
}

/// Centralized themed loading indicator with optional message.
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
