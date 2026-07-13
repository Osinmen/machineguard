import 'package:flutter/material.dart';
import 'package:machine_guard/data/models/prediction_result.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel riskLevel;
  final double? riskPercentage;
  final bool showPercent;

  const RiskBadge({
    super.key,
    required this.riskLevel,
    this.riskPercentage,
    this.showPercent = true,
  });

  @override
  Widget build(BuildContext context) {
    final result = _mock(riskLevel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: result.riskColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: result.riskColor.withOpacity(0.6)),
      ),
      child: Text(
        showPercent && riskPercentage != null
            ? '${riskPercentage!.toStringAsFixed(1)}%'
            : result.riskLabel,
        style: TextStyle(
          color: result.riskColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper to get color/label from riskLevel without a full result object
 PredictionResult _mock(RiskLevel level) => PredictionResult(
    machineId: '',
    prediction: 0,
    riskProbability: 0,
    riskPercentage: riskPercentage ?? 0,
    riskLevel: level,
    recommendation: '',
    sensorAlerts: [],        // ADD THIS
    alertCount: 0,           // ADD THIS
    criticalCount: 0,        // ADD THIS
    warningCount: 0,         // ADD THIS
    modelVersion: '',
    timestamp: DateTime.now(),
  );
}
