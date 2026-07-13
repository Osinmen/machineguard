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

  // Controllers (machine_id removed — auto-generated at submit time, not user-facing)
  final _installYearCtrl = TextEditingController(text: '2018');
  final _tempCtrl = TextEditingController(text: '75.0');
  final _vibrationCtrl = TextEditingController(text: '3.5');
  final _powerCtrl = TextEditingController(text: '12.0');
  final _opHoursCtrl = TextEditingController(text: '14000');
  final _lastMaintenanceCtrl = TextEditingController(text: '45');
  final _maintCountCtrl = TextEditingController(text: '8');
  final _failureCountCtrl = TextEditingController(text: '2');
  final _oilCtrl = TextEditingController(text: '72.0');
  final _coolantCtrl = TextEditingController(text: '85.0');
  final _aiOverrideCtrl = TextEditingController(text: '1');
  final _rulCtrl = TextEditingController(text: '120.0');
  final _errorCodesCtrl = TextEditingController(text: '2');
  final _soundCtrl = TextEditingController(text: '68.5');

  // NOTE: default must be a value that exists in AppConstants.machineTypes
  // AND is one of the backend's VALID_MACHINE_TYPES:
  // CMM, CNC Lathe, Industrial Chiller, Injection Molder, Labeler, Pump, Vacuum Packer, Conveyor Belt
  // 'Compressor' is NOT in that list — confirm AppConstants.machineTypes matches the backend
  // before shipping, otherwise this dropdown can submit an invalid machine_type.
  String _selectedMachineType = 'Pump';
  bool _aiSupervision = true;

  @override
  void dispose() {
    for (final c in [
      _installYearCtrl, _tempCtrl, _vibrationCtrl,
      _powerCtrl, _opHoursCtrl, _lastMaintenanceCtrl, _maintCountCtrl,
      _failureCountCtrl, _oilCtrl, _coolantCtrl, _aiOverrideCtrl,
      _rulCtrl, _errorCodesCtrl, _soundCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final input = SensorInput(
      machineId: 'MCH-${DateTime.now().millisecondsSinceEpoch}',
      machineType: _selectedMachineType,
      installationYear: int.parse(_installYearCtrl.text),
      temperatureC: double.parse(_tempCtrl.text),
      vibrationMms: double.parse(_vibrationCtrl.text),
      powerConsumptionKw: double.parse(_powerCtrl.text),
      operationalHours: double.parse(_opHoursCtrl.text),
      lastMaintenanceDaysAgo: int.parse(_lastMaintenanceCtrl.text),
      maintenanceHistoryCount: int.parse(_maintCountCtrl.text),
      failureHistoryCount: int.parse(_failureCountCtrl.text),
      oilLevelPct: double.parse(_oilCtrl.text),
      coolantLevelPct: double.parse(_coolantCtrl.text),
      aiSupervision: _aiSupervision,
      aiOverrideEvents: int.parse(_aiOverrideCtrl.text),
      remainingUsefulLifeDays: double.parse(_rulCtrl.text),
      errorCodesLast30Days: int.parse(_errorCodesCtrl.text),
      soundDb: double.parse(_soundCtrl.text),
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
                      _dropdownField(),
                      const SizedBox(height: 12),
                      _textField('Installation Year', _installYearCtrl, isInt: true,
                          hint: '1990 – 2026'),
                    ]),
                    const SizedBox(height: 16),
                    _buildGroup('Sensor Readings', [
                      _textField('Temperature (°C)', _tempCtrl, hint: 'e.g. 75.0'),
                      const SizedBox(height: 12),
                      _textField('Vibration (mm/s)', _vibrationCtrl, hint: 'e.g. 3.5'),
                      const SizedBox(height: 12),
                      _textField('Power Consumption (kW)', _powerCtrl, hint: 'e.g. 12.0'),
                      const SizedBox(height: 12),
                      _textField('Operational Hours', _opHoursCtrl, hint: 'e.g. 14000'),
                      const SizedBox(height: 12),
                      _textField('Sound Level (dB)', _soundCtrl, hint: 'e.g. 68.5'),
                    ]),
                    const SizedBox(height: 16),
                    _buildGroup('Maintenance Info', [
                      _textField('Days Since Last Maintenance', _lastMaintenanceCtrl, isInt: true),
                      const SizedBox(height: 12),
                      _textField('Maintenance History Count', _maintCountCtrl, isInt: true),
                      const SizedBox(height: 12),
                      _textField('Failure History Count', _failureCountCtrl, isInt: true),
                      const SizedBox(height: 12),
                      _textField('Oil Level (%)', _oilCtrl, hint: '0 – 100'),
                      const SizedBox(height: 12),
                      _textField('Coolant Level (%)', _coolantCtrl, hint: '0 – 100'),
                    ]),
                    const SizedBox(height: 16),
                    _buildGroup('AI & Lifespan', [
                      _textField('Remaining Useful Life (days)', _rulCtrl),
                      const SizedBox(height: 12),
                      _textField('Error Codes (Last 30 Days)', _errorCodesCtrl, isInt: true),
                      const SizedBox(height: 12),
                      _textField('AI Override Events', _aiOverrideCtrl, isInt: true),
                      const SizedBox(height: 12),
                      _toggleField(),
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

  Widget _textField(String label, TextEditingController ctrl,
      {bool isInt = false, bool isRequired = false, String? hint}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isInt
          ? TextInputType.number
          : const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: (v) {
        if (v == null || v.isEmpty) return '$label is required';
        if (isInt && int.tryParse(v) == null) return 'Enter a valid integer';
        if (!isInt && !isRequired && double.tryParse(v) == null) return 'Enter a valid number';
        return null;
      },
    );
  }

  Widget _dropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedMachineType,
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(labelText: 'Machine Type'),
      items: AppConstants.machineTypes
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (v) => setState(() => _selectedMachineType = v!),
    );
  }

  Widget _toggleField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('AI Supervision', style: TextStyle(color: AppColors.textSecondary)),
        Switch(
          value: _aiSupervision,
          activeColor: AppColors.cyan,
          onChanged: (v) => setState(() => _aiSupervision = v),
        ),
      ],
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