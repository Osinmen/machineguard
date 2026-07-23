import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:machine_guard/core/constants/app_constants.dart';
import 'package:machine_guard/core/theme/app_theme.dart';
import 'package:machine_guard/providers/history_provider.dart';
import 'package:machine_guard/widgets/common/neon_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppInfo(),
          const SizedBox(height: 20),
          _buildDangerSection(context),
          const SizedBox(height: 20),
          _buildAboutSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return NeonCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
            ),
            child: const Icon(Icons.shield, color: AppColors.cyan, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MachineGuard',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
              Text('v${AppConstants.appVersion}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const Text('Predictive Failure Detection',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDangerSection(BuildContext context) {
    return NeonCard(
      glowColor: AppColors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Danger Zone',
              style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _confirmClear(context),
            child: Row(
              children: [
                const Icon(Icons.delete_forever_outlined, color: AppColors.red, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Clear All History', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600)),
                      Text('Permanently delete all prediction records',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About',
              style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1)),
          const SizedBox(height: 14),
          _aboutRow('Model', 'LightGBM Classifier'),
          _aboutRow('Target', 'Fault Type (5-class)'),
          _aboutRow('Primary Metric', 'F1-Macro'),
          _aboutRow('Built with', 'Flutter + FastAPI'),
        ],
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
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
        content: const Text('This cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              context.read<HistoryProvider>().clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}