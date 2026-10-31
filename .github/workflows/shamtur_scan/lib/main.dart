import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/diagnostics/bluetooth_screen.dart';
import 'features/diagnostics/diagnostics_screen.dart';
import 'features/subscription/subscription_screen.dart';

void main() {
  runApp(const ShamturScanApp());
}

class ShamturScanApp extends StatelessWidget {
  const ShamturScanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHAMTUR SCAN',
      debugShowCheckedModeBanner: false,
      theme: ShamturTheme.darkTheme,
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DiagnosticsScreen(),
    const BluetoothScreen(),
    const SubscriptionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: ShamturTheme.cardBackground,
        selectedItemColor: ShamturTheme.primaryCyan,
        unselectedItemColor: ShamturTheme.textGrey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.car_repair),
            label: 'الفحص والتشخيص',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth_searching),
            label: 'ربط البلوتوث',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'الاشتراكات',
          ),
        ],
      ),
    );
  }
}