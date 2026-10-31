import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/obd_service.dart';
import '../../core/theme.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({Key? key}) : super(key: key);

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final OBDService _obdService = OBDService();
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkBluetooth();
  }

  void _checkBluetooth() async {
    if (await _obdService.isBluetoothAvailable()) {
      _startScanning();
    }
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _scanResults.clear();
    });

    _obdService.startScan((results) {
      setState(() {
        _scanResults = results;
      });
    });

    // إيقاف البحث تلقائياً بعد 5 ثوانٍ
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isScanning = false;
      });
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    bool success = await _obdService.connectToDevice(device);
    setState(() {
      _isConnected = success;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم الاتصال بقطعة الفحص بنجاح! Connected")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل الاتصال بالقطعة. حاول مجدداً")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SHAMTUR SCAN - ربط البلوتوث"),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
            onPressed: _isScanning ? null : _startScanning,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        key: const PageStorageKey('bluetooth_screen_body'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isConnected ? "الحالة: متصل بالسيارة (Connected)" : "الحالة: غير متصل (Not Connected)",
              style: TextStyle(
                color: _isConnected ? ShamturTheme.secondaryGreen : ShamturTheme.alertRed,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "اختر قطعة الـ OBDII / ELM327 المتاحة:",
              style: TextStyle(color: ShamturTheme.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _scanResults.isEmpty
                  ? Center(
                      child: _isScanning
                          ? const CircularProgressIndicator(color: ShamturTheme.primaryCyan)
                          : const Text(
                              "لا توجد أجهزة قريبة. تأكد من تشغيل البلوتوث.",
                              style: TextStyle(color: ShamturTheme.textWhite),
                            ),
                    )
                  : ListView.builder(
                      itemCount: _scanResults.length,
                      itemBuilder: (context, index) {
                        final data = _scanResults[index];
                        String deviceName = data.device.platformName.isNotEmpty
                            .toString() == 'true' && data.device.platformName.isNotEmpty
                                ? data.device.platformName
                                : "Unknown OBD Device";
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              deviceName,
                              style: const TextStyle(color: ShamturTheme.textWhite, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              data.device.remoteId.toString(),
                              style: const TextStyle(color: ShamturTheme.textGrey),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _connectToDevice(data.device),
                              child: const Text("اتصال"),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}