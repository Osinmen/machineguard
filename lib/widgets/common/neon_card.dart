import 'package:flutter/material.dart';
import 'package:machine_guard/core/theme/app_theme.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const NeonCard({
    super.key,
    required this.child,
    this.glowColor,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: glowColor ?? AppColors.border,
            width: glowColor != null ? 1.5 : 1,
          ),
          boxShadow: glowColor != null
              ? [BoxShadow(color: glowColor!.withOpacity(0.15), blurRadius: 12, spreadRadius: 1)]
              : null,
        ),
        child: child,
      ),
    );
  }
}
