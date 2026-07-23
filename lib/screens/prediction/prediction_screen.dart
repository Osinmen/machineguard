import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:machine_guard/core/constants/app_constants.dart';
import 'package:machine_guard/core/theme/app_theme.dart';
import 'package:machine_guard/data/models/sensor_input.dart';
import 'package:machine_guard/providers/prediction_provider.dart';
import 'package:machine_guard/widgets/common/neon_card.dart';
import 'package:machine_guard/screens/prediction/result_screen.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _vibrationCtrl   = TextEditingController(text: '2.4');
  final _tempMotorCtrl   = TextEditingController(text: '68.5');
  final _currentCtrl     = TextEditingController(text: '9.2');
  final _pressureCtrl    = TextEditingController(text: '55.0');
  final _rpmCtrl         = TextEditingController(text: '1200');
  final _hoursCtrl       = TextEditingController(text: '150');
  final _ambientCtrl     = TextEditingController(text: '13.0');

  // Defaults must exist in AppConstants.machineTypes / operatingModes,
  // which must match the backend's VALID_MACHINE_TYPES / VALID_OPERATING_MODES
  // exactly — these are baked into the fitted OneHotEncoder.
  String _selectedMachineType   = AppConstants.machineTypes.first;
  String _selectedOperatingMode = 'normal';

  @override
  void dispose() {
    for (final c in [
      _vibrationCtrl, _tempMotorCtrl, _currentCtrl,
      _pressureCtrl, _rpmCtrl, _hoursCtrl, _ambientCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final input = SensorInput(
      machineId: 'MCH-${DateTime.now().millisecondsSinceEpoch}',
      machineType: _selectedMachineType,
      operatingMode: _selectedOperatingMode,
      vibrationRms: double.parse(_vibrationCtrl.text),
      temperatureMotor: double.parse(_tempMotorCtrl.text),
      currentPhaseAvg: double.parse(_currentCtrl.text),
      pressureLevel: double.parse(_pressureCtrl.text),
      rpm: double.parse(_rpmCtrl.text),
      hoursSinceMaintenance: double.parse(_hoursCtrl.text),
      ambientTemp: double.parse(_ambientCtrl.text),
    );

    await context.read<PredictionProvider>().runPrediction(input);

    if (!mounted) return;
    final provider = context.read<PredictionProvider>();

    if (provider.state == PredictionState.success) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Prediction failed'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prediction'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Consumer<PredictionProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('Enter machine sensor readings',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 20),
                    _buildGroup('Machine Info', [
                      _dropdownField(
                        label: 'Machine Type',
                        value: _selectedMachineType,
                        options: AppConstants.machineTypes,
                        onChanged: (v) => setState(() => _selectedMachineType = v!),
                      ),
                      const SizedBox(height: 12),
                      _dropdownField(
                        label: 'Operating Mode',
                        value: _selectedOperatingMode,
                        options: AppConstants.operatingModes,
                        onChanged: (v) => setState(() => _selectedOperatingMode = v!),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildGroup('Sensor Readings', [
                      _textField('Vibration RMS (mm/s)', _vibrationCtrl, hint: 'e.g. 2.4'),
                      const SizedBox(height: 12),
                      _textField('Motor Temperature (°C)', _tempMotorCtrl, hint: 'e.g. 68.5', allowNegative: true),
                      const SizedBox(height: 12),
                      _textField('Phase Current avg (A)', _currentCtrl, hint: 'e.g. 9.2'),
                      const SizedBox(height: 12),
                      _textField('Pressure Level (psi)', _pressureCtrl, hint: 'e.g. 55.0'),
                      const SizedBox(height: 12),
                      _textField('Rotational Speed (RPM)', _rpmCtrl, hint: 'e.g. 1200'),
                    ]),
                    const SizedBox(height: 16),
                    _buildGroup('Maintenance & Environment', [
                      _textField('Hours Since Maintenance', _hoursCtrl, hint: 'e.g. 150'),
                      const SizedBox(height: 12),
                      _textField('Ambient Temperature (°C)', _ambientCtrl, hint: 'e.g. 13.0', allowNegative: true),
                    ]),
                    const SizedBox(height: 28),
                    _buildSubmitButton(provider),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              if (provider.isLoading)
                Container(
                  color: AppColors.background.withOpacity(0.85),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.cyan),
                        SizedBox(height: 16),
                        Text('Analysing machine...', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroup(String title, List<Widget> children) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
              color: AppColors.cyan, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController ctrl, {String? hint, bool allowNegative = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: allowNegative),
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: (v) {
        if (v == null || v.isEmpty) return '$label is required';
        final parsed = double.tryParse(v);
        if (parsed == null) return 'Enter a valid number';
        if (!allowNegative && parsed < 0) return '$label cannot be negative';
        return null;
      },
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(labelText: label),
      items: options
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSubmitButton(PredictionProvider provider) {
    return GestureDetector(
      onTap: provider.isLoading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: provider.isLoading ? AppColors.cyanDim : AppColors.cyan,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: provider.isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
              : const Text('Run Prediction',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16)),
        ),
      ),
    );
  }
}
