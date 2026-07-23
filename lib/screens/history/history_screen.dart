import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:machine_guard/core/theme/app_theme.dart';
import 'package:machine_guard/data/models/prediction_result.dart';
import 'package:machine_guard/providers/history_provider.dart';
import 'package:machine_guard/widgets/common/neon_card.dart';
import 'package:machine_guard/widgets/common/risk_badge.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.red),
            onPressed: () => _confirmClear(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, history, _) {
          return Column(
            children: [
              _buildFilters(history),
              Expanded(
                child: history.filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: history.filtered.length,
                        itemBuilder: (ctx, i) => _buildItem(ctx, history.filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(HistoryProvider history) {
    final filters = ['all', 'faulty', 'healthy'];
    final labels = {'all': 'All', 'faulty': 'Faulty', 'healthy': 'Healthy'};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: filters.map((f) {
          final selected = history.filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => history.setFilter(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? AppColors.cyan.withOpacity(0.15) : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.cyan : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  labels[f]!,
                  style: TextStyle(
                    color: selected ? AppColors.cyan : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItem(BuildContext context, PredictionResult result) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(result.timestamp.toIso8601String()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: AppColors.red),
        ),
        onDismissed: (_) {
          // We don't have id in this demo — use timestamp as proxy
          context.read<HistoryProvider>().load();
        },
        child: NeonCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: result.statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.memory, color: result.statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.machineId,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(result.recommendation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text(DateFormat('MMM d, y • HH:mm').format(result.timestamp),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              RiskBadge(
                isHealthy: result.isHealthy,
                lowConfidence: result.lowConfidence,
                label: result.isHealthy ? 'Healthy' : result.predictedClass.replaceAll('_', ' '),
                percentage: result.confidencePercentage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: AppColors.textMuted, size: 56),
          SizedBox(height: 14),
          Text('No history yet', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
          SizedBox(height: 6),
          Text('Saved predictions will appear here', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear History', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('This will delete all saved predictions. Are you sure?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryProvider>().clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
