import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:machine_guard/core/theme/app_theme.dart';
import 'package:machine_guard/providers/history_provider.dart';
import 'package:machine_guard/data/models/prediction_result.dart';
import 'package:machine_guard/widgets/common/neon_card.dart';
import 'package:machine_guard/widgets/common/risk_badge.dart';
import 'package:intl/intl.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<HistoryProvider>(
          builder: (context, history, _) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSummaryRow(history),
                      const SizedBox(height: 20),
                      _buildFleetHealth(history),
                      const SizedBox(height: 20),
                      _buildRecentHeader(),
                      const SizedBox(height: 12),
                      if (history.filtered.isEmpty)
                        _buildEmptyState()
                      else
                        ...history.filtered.take(10).map((r) => _buildHistoryItem(r)),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
            ),
            child: const Icon(Icons.shield, color: AppColors.cyan, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('MachineGuard', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSummaryRow(HistoryProvider history) {
    return Row(
      children: [
        Expanded(child: _statCard('Total', history.total.toString(), AppColors.textSecondary, Icons.memory)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('At Risk', history.atRiskCount.toString(), AppColors.red, Icons.warning_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Healthy', history.healthyCount.toString(), AppColors.cyan, Icons.check_circle)),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return NeonCard(
      glowColor: color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFleetHealth(HistoryProvider history) {
    final total = history.total;
    final healthPct = total == 0 ? 100.0 : (history.healthyCount / total * 100);

    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fleet Health', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('${healthPct.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: healthPct > 80 ? AppColors.cyan : AppColors.orange,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: healthPct / 100,
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: AlwaysStoppedAnimation(healthPct > 80 ? AppColors.cyan : AppColors.orange),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${history.healthyCount} of ${history.total} machines healthy',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Recent Predictions', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.sensors_off, color: AppColors.textMuted, size: 48),
            SizedBox(height: 12),
            Text('No predictions yet', style: TextStyle(color: AppColors.textMuted)),
            SizedBox(height: 4),
            Text('Run your first prediction to see results here',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(PredictionResult result) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeonCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: result.riskColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.precision_manufacturing, color: result.riskColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.machineId,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(DateFormat('MMM d, y • HH:mm').format(result.timestamp),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            RiskBadge(riskLevel: result.riskLevel, riskPercentage: result.riskPercentage),
          ],
        ),
      ),
    );
  }
}
