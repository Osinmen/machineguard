import 'package:flutter/material.dart';
import 'package:machine_guard/core/theme/app_theme.dart';
import 'package:machine_guard/data/models/prediction_result.dart';
import 'package:machine_guard/providers/history_provider.dart';
import 'package:machine_guard/providers/prediction_provider.dart';
import 'package:machine_guard/widgets/common/neon_card.dart';
import 'package:provider/provider.dart';

import 'dart:math' as math;

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictionProvider>();
    final result   = provider.latestResult;
    if (result == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Result'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),

          // ── Gauge ────────────────────────────────────────────────
          _buildGauge(result),
          const SizedBox(height: 20),

          // ── HEALTHY / FAULTY badge ───────────────────────────────
          _buildStatusBadge(result),
          const SizedBox(height: 16),

          // ── Risk level badge ─────────────────────────────────────
          _buildRiskBadge(result),
          const SizedBox(height: 20),

          // ── Recommendation ───────────────────────────────────────
          _buildRecommendation(result),
          const SizedBox(height: 20),

          // ── Sensor Alerts ────────────────────────────────────────
          if (result.sensorAlerts.isNotEmpty) ...[
            _buildAlertsSection(result),
            const SizedBox(height: 20),
          ],

          // ── Details ──────────────────────────────────────────────
          _buildDetails(result),
          const SizedBox(height: 28),

          // ── Actions ──────────────────────────────────────────────
          _buildActions(context, result),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Gauge ──────────────────────────────────────────────────────────────────

  Widget _buildGauge(PredictionResult result) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 220,
        child: CustomPaint(
          painter: _GaugePainter(
            value: result.riskProbability,
            color: result.riskColor,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${result.riskPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color:      result.riskColor,
                    fontSize:   42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Risk Score',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HEALTHY / FAULTY ───────────────────────────────────────────────────────

  Widget _buildStatusBadge(PredictionResult result) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color:        result.statusColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border:       Border.all(color: result.statusColor, width: 2),
          boxShadow: [
            BoxShadow(color: result.statusColor.withOpacity(0.25), blurRadius: 20),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(result.statusIcon, color: result.statusColor, size: 22),
            const SizedBox(width: 8),
            Text(
              result.statusLabel,
              style: TextStyle(
                color:      result.statusColor,
                fontWeight: FontWeight.w900,
                fontSize:   20,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Risk Level ─────────────────────────────────────────────────────────────

  Widget _buildRiskBadge(PredictionResult result) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color:        result.riskColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: result.riskColor.withOpacity(0.5)),
        ),
        child: Text(
          'Risk Level: ${result.riskLabel}',
          style: TextStyle(
            color:      result.riskColor,
            fontWeight: FontWeight.w600,
            fontSize:   14,
          ),
        ),
      ),
    );
  }

  // ── Recommendation ─────────────────────────────────────────────────────────

  Widget _buildRecommendation(PredictionResult result) {
    return NeonCard(
      glowColor: result.riskColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: result.riskColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RECOMMENDATION',
                  style: TextStyle(
                    color:      AppColors.textSecondary,
                    fontSize:   11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result.recommendation,
                  style: const TextStyle(
                    color:   AppColors.textPrimary,
                    fontSize: 14,
                    height:  1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sensor Alerts ──────────────────────────────────────────────────────────

  Widget _buildAlertsSection(PredictionResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.sensors, color: AppColors.textSecondary, size: 16),
            const SizedBox(width: 8),
            Text(
              'SENSOR ALERTS (${result.alertCount})',
              style: const TextStyle(
                color:      AppColors.textSecondary,
                fontSize:   12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
            if (result.criticalCount > 0)
              _alertChip('${result.criticalCount} CRITICAL', AppColors.red),
            if (result.warningCount > 0) ...[
              const SizedBox(width: 6),
              _alertChip('${result.warningCount} WARNING', AppColors.orange),
            ],
          ],
        ),
        const SizedBox(height: 10),
        ...result.sensorAlerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _alertChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildAlertCard(SensorAlert alert) {
    final color = alert.alertColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: color.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:        color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(alert.alertIcon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        alert.sensor,
                        style: const TextStyle(
                          color:      AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize:   14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:        color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          alert.status,
                          style: TextStyle(
                            color:      color,
                            fontSize:   11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Value: ${alert.value.toStringAsFixed(1)} ${alert.unit}',
                    style: TextStyle(
                      color:   color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: const TextStyle(
                      color:   AppColors.textSecondary,
                      fontSize: 12,
                      height:  1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Normal: ${alert.warnRange[0].toStringAsFixed(1)} – ${alert.warnRange[1].toStringAsFixed(1)} ${alert.unit}',
                    style: const TextStyle(
                      color:   AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Details ────────────────────────────────────────────────────────────────

  Widget _buildDetails(PredictionResult result) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PREDICTION DETAILS',
            style: TextStyle(
              color:      AppColors.cyan,
              fontWeight: FontWeight.w700,
              fontSize:   12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          _detailRow('Machine ID',       result.machineId),
          _detailRow('Status',           result.statusLabel),
          _detailRow('Risk Score',       '${result.riskPercentage.toStringAsFixed(2)}%'),
          _detailRow('Risk Level',       result.riskLabel),
          _detailRow('Sensor Alerts',    '${result.alertCount} (${result.criticalCount} critical, ${result.warningCount} warning)'),
          _detailRow('Model Version',    result.modelVersion),
          _detailRow('Timestamp',        result.timestamp.toString().substring(0, 19)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value,  style: const TextStyle(color: AppColors.textPrimary,   fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Actions 

  Widget _buildActions(BuildContext context, PredictionResult result) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            await context.read<PredictionProvider>().saveResult();
            await context.read<HistoryProvider>().load();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:         Text('Saved to history'),
                  backgroundColor: AppColors.cyanDim,
                ),
              );
            }
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color:        AppColors.cyan,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: AppColors.cyan.withOpacity(0.3), blurRadius: 16),
              ],
            ),
            child: const Center(
              child: Text(
                'Save to History',
                style: TextStyle(
                  color:      Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize:   15,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            context.read<PredictionProvider>().reset();
            Navigator.pop(context);
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color:        AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border:       Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'New Prediction',
                style: TextStyle(
                  color:      AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize:   15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Gauge Painter ──────────────────────────────────────────────────────────

class _GaugePainter extends CustomPainter {
  final double value;
  final Color  color;

  _GaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center     = Offset(size.width / 2, size.height / 2);
    final radius     = size.width / 2 - 16;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    final trackPaint = Paint()
      ..color      = AppColors.surfaceLight
      ..style      = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap  = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false, trackPaint,
    );

    final valuePaint = Paint()
      ..color      = color
      ..style      = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap  = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle * value.clamp(0.0, 1.0), false, valuePaint,
    );

    final glowPaint = Paint()
      ..color      = color.withOpacity(0.25)
      ..style      = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap  = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle * value.clamp(0.0, 1.0), false, glowPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}