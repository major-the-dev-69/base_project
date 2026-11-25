import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_service/base/base_controller.dart';
import 'package:go_service/components/app_buttons.dart';
import 'package:go_service/components/app_state_widgets.dart';
import 'package:go_service/components/app_text_fields.dart';
import 'package:go_service/components/empty_state_widget.dart';

abstract class BaseWidget<T extends BaseController> extends GetWidget<T> {
  const new({super.key});

  Widget baseIconButton(
    dynamic source, {
    required VoidCallback onTap,
    double size = 30,
    Color? color,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: baseIcon(source, size: size, color: color) ?? const Icon(Icons.add),
    );
  }

  Widget? baseIcon(dynamic source, {Color? color, double size = 30}) {
    ColorFilter? filter() {
      if (color == null) {
        return null;
      }
      return ColorFilter.mode(color, BlendMode.srcIn);
    }

    if (source == null) return null;
    if (source is Widget) return source;
    if (source is IconData) {
      return Icon(source, size: size, color: color);
    } else if (source is String) {
      if (source.contains('.svg')) {
        if (source.startsWith('http')) {
          return SvgPicture.network(
            source,
            height: size,
            width: size,
            fit: BoxFit.contain,
            colorFilter: filter(),
          );
        }
        return SvgPicture.asset(
          source,
          height: size,
          width: size,
          fit: BoxFit.contain,
          colorFilter: filter(),
        );
      } else if (source.startsWith('assets')) {
        return Image.asset(
          source,
          height: size,
          width: size,
          fit: BoxFit.contain,
          color: color,
        );
      } else if (source.startsWith('http')) {
        return Image.network(
          source,
          height: size,
          width: size,
          fit: BoxFit.contain,
          color: color,
        );
      }
    }
    return null;
  }

  // 1. BottomSheetDecoration
  BoxDecoration baseBottomSheetDecoration(
    BuildContext context, {
    Color? color,
  }) {
    return AppDecorations.bottomSheet(context, color: color);
  }

  Widget baseBottomSheet({required Widget child, bool showDragHandle = true}) {
    return AppBottomSheetContainer(
      showDragHandle: showDragHandle,
      child: child,
    );
  }

  // 2. Selected / UnSelected Background
  BoxDecoration baseSelectionDecoration(
    BuildContext context, {
    required bool isSelected,
  }) {
    return AppDecorations.selection(context, isSelected: isSelected);
  }

  Widget baseSelectableBackground({
    required bool isSelected,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return AppSelectableContainer(
      isSelected: isSelected,
      onTap: onTap,
      child: child,
    );
  }

  // 3. TextFormFields
  Widget baseTextField({
    TextEditingController? controller,
    String? hint,
    String? label,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool readOnly = false,
    int maxLines = 1,
    Widget? prefixIcon,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
  }) {
    return AppTextFields(
      controller: controller,
      hint: hint,
      label: label,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      maxLines: maxLines,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onChanged: onChanged,
      onTap: onTap,
    );
  }

  // 4. DropDown
  Widget baseDropdown<V>({
    required List<DropdownMenuItem<V>> items,
    required ValueChanged<V?>? onChanged,
    V? value,
    String? hint,
    String? label,
    FormFieldValidator<V>? validator,
    Widget? prefixIcon,
  }) {
    return AppDropdownField<V>(
      items: items,
      onChanged: onChanged,
      value: value,
      hint: hint,
      label: label,
      validator: validator,
      prefixIcon: prefixIcon,
    );
  }

  // 5. Radio
  Widget baseRadio<V>({
    required V value,
    required V? groupValue,
    required ValueChanged<V?>? onChanged,
    String? title,
  }) {
    return AppRadio<V>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: title,
    );
  }

  // 6. Button
  Widget baseButton(
    String title, {
    VoidCallback? onTap,
    bool isLoading = false,
    bool isOutlined = false,
    Widget? icon,
  }) {
    return AppButton(
      title: title,
      onTap: onTap,
      isLoading: isLoading,
      isOutlined: isOutlined,
      icon: icon,
    );
  }

  // 7. Loading State
  Widget baseLoadingState({String? message}) {
    return AppLoadingWidget(message: message);
  }

  // 8. Empty State
  Widget baseEmptyState({
    required String title,
    String? subtitle,
    IconData icon = Icons.inbox_outlined,
    String? actionTitle,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      title: title,
      subtitle: subtitle,
      icon: icon,
      actionTitle: actionTitle,
      onAction: onAction,
    );
  }
}
