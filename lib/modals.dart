import 'package:flutter/material.dart';

class FocusedMenuItem {
  final Color? backgroundColor;
  final Widget title;
  final Widget? trailingIcon;
  final VoidCallback onPressed;

  const FocusedMenuItem({
    this.backgroundColor,
    required this.title,
    this.trailingIcon,
    required this.onPressed,
  });
}
