// widgets/app_text_field.dart

import 'package:flutter/material.dart';

enum FieldIconType { person, lock, email }

class AppTextField extends StatelessWidget {
  final String hint;
  final FieldIconType iconType;
  final bool obscure;
  final bool? isObscured;
  final VoidCallback? onToggle;
  final Color bgColor;
  final bool hasShadow;

  const AppTextField(
    this.hint,
    this.iconType, {
    super.key,
    this.obscure = false,
    this.isObscured,
    this.onToggle,
    this.bgColor = const Color(0xFFE3F2FD),
    this.hasShadow = false,
  });

  IconData _getIcon() {
    switch (iconType) {
      case FieldIconType.person:
        return Icons.person_outline;
      case FieldIconType.lock:
        return Icons.lock_outline;
      case FieldIconType.email:
        return Icons.email_outlined;
    }
  }

  IconData _getVisibilityIcon() {
    return isObscured == true ? Icons.visibility_off : Icons.visibility;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(_getIcon(), color: Colors.grey, size: 22),
          suffixIcon: onToggle != null
              ? IconButton(
                  icon: Icon(_getVisibilityIcon(), color: Colors.grey),
                  onPressed: onToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
