import 'package:flutter/material.dart';

/// Centralized themed [TextFormField] with minimal required arguments.
class AppTextFields extends StatelessWidget {
  const AppTextFields({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
  });

  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    int effectiveMaxLines = maxLines;
    if (obscureText) {
      effectiveMaxLines = 1;
    }

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      maxLines: effectiveMaxLines,
      onChanged: onChanged,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// Centralized themed [DropdownButtonFormField] with minimal required arguments.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.label,
    this.validator,
    this.prefixIcon,
  });

  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? hint;
  final String? label;
  final FormFieldValidator<T>? validator;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
