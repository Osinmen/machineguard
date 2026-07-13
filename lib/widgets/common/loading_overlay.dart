import 'package:flutter/material.dart';
import 'package:machine_guard/core/theme/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;
  const LoadingOverlay({super.key, this.message = 'Analysing machine...'});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.cyan),
            const SizedBox(height: 20),
            Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
