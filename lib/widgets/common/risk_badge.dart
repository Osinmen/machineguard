import 'package:flutter/material.dart';
import 'package:machine_guard/core/theme/app_theme.dart';

/// Small badge used in dashboard / history list rows to show a
/// prediction's outcome at a glance. Renamed internally from a
/// 3-tier risk badge to a status badge — driven by isHealthy /
/// lowConfidence rather than a risk-level enum, but kept the same
/// cyan/orange/red visual language and the same widget name so
/// callers didn't need churn beyond their constructor args.
class RiskBadge extends StatelessWidget {
  final bool   isHealthy;
  final bool   lowConfidence;
  final String label;
  final double percentage; // 0-100, shown as confidence

  const RiskBadge({
    super.key,
    required this.isHealthy,
    required this.lowConfidence,
    required this.label,
    required this.percentage,
  });

  Color get _color {
    if (isHealthy) return AppColors.cyan;
    return lowConfidence ? AppColors.orange : AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label · ${percentage.toStringAsFixed(0)}%',
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
