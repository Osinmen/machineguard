import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:machine_guard/core/theme/app_theme.dart';
import 'package:machine_guard/core/constants/app_constants.dart';
import 'package:machine_guard/data/services/api_service.dart';
import 'package:machine_guard/providers/prediction_provider.dart';
import 'package:machine_guard/providers/history_provider.dart';
import 'package:machine_guard/providers/settings_provider.dart';
import 'package:machine_guard/screens/dashboard/dashboard_screen.dart';
import 'package:machine_guard/screens/prediction/prediction_screen.dart';
import 'package:machine_guard/screens/history/history_screen.dart';
import 'package:machine_guard/screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = SettingsProvider();
  await settings.load();
  runApp(MachineGuardApp(settings: settings));
}

class MachineGuardApp extends StatelessWidget {
  final SettingsProvider settings;
  const MachineGuardApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(baseUrl: settings.apiUrl);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => PredictionProvider(apiService)),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    PredictionScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.sensors_outlined), activeIcon: Icon(Icons.sensors), label: 'Predict'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
