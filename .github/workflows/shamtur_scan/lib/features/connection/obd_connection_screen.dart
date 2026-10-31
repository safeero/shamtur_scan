import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme.dart';
import '../../core/obd_connection_service.dart';

class ObdConnectionScreen extends StatefulWidget {
  const ObdConnectionScreen({super.key});

  @override
  State<ObdConnectionScreen> createState() => _ObdConnectionScreenState();
}

class _ObdConnectionScreenState extends State<ObdConnectionScreen> {
  final ObdConnectionService _obdService = ObdConnectionService();
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  final List<ScanResult> _results = [];
  
  bool _scanning = false;
  bool _connecting = false;
  String _status = 'لم يتم الاتصال';
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPermissionsAndScan();
  }

  Future<void> _initPermissionsAndScan() async {
    // طلب صلاحيات الموقع والبلوتوث اللازمة لأندرويد
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothConnect] != PermissionStatus.granted &&
        statuses[Permission.location] != PermissionStatus.granted) {
      setState(() {
        _error = 'صلاحيات البلوتوث والموقع مطلوبة للبحث عن محولات OBD2.';
      });
      return;
    }

    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _error = null;
      _results.clear();
      _status = 'جارٍ البحث عن محولات OBD2 القريبة...';
    });

    try {
      final available = await _obdService.checkAdapterStatus();
      if (!available) {
        throw Exception('الرجاء التأكد من تشغيل بلوتوث الهاتف.');
      }

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (!mounted) return;
        setState(() {
          for (final r in results) {
            final index = _results.indexWhere((element) => element.device.remoteId == r.device.remoteId);
            if (index == -1) {
              _results.add(r);
            } else {
              _results[index] = r;
            }
          }
          _results.sort((a, b) => b.rssi.compareTo(a.rssi));
        });
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _scanning = false);
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _connecting = true;
      _status = 'جارٍ الاتصال بالمحول ${device.platformName.isEmpty ? device.remoteId.str : device.platformName}...';
    });

    final success = await _obdService.connectBleDevice(device);

    if (!mounted) return;
    setState(() {
      _connecting = false;
      if (success) {
        _status = 'تم الاتصال بنجاح! جاهز لقراءة بيانات المحرك';
      } else {
        _error = 'فشل الاتصال بالجهاز. تأكد من أن المحول يعمل وفي وضع الاقتران.';
        _status = 'غير متصل';
      }
    });
  }

  Future<void> _disconnectDevice() async {
    await _obdService.disconnect();
    setState(() {
      _status = 'تم قطع الاتصال';
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectedDev = _obdService.connectedDevice;

    return Scaffold(
      appBar: AppBar(title: const Text('اتصال محول OBD2')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('حالة الاتصال الحالية', style: TextStyle(color: ShamturColors.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        connectedDev == null ? Icons.link_off : Icons.link,
                        color: connectedDev == null ? ShamturColors.amber : ShamturColors.green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_status, style: const TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: ShamturColors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _scanning || _connecting ? null : _startScan,
                        icon: _scanning 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : const Icon(Icons.refresh),
                        label: Text(_scanning ? 'جارٍ البحث...' : 'إعادة البحث'),
                      ),
                      if (connectedDev != null)
                        OutlinedButton.icon(
                          onPressed: _disconnectDevice,
                          icon: const Icon(Icons.link_off, color: ShamturColors.red),
                          label: const Text('قطع الاتصال', style: TextStyle(color: ShamturColors.red)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('الأجهزة المكتشفة في النطاق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (_results.isEmpty && !_scanning)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'لم يتم العثور على أجهزة BLE. ملاحظة: بعض محولات ELM327 القديمة تستخدم Bluetooth Classic وتتطلب إقتران مسبق من إعدادات البلوتوث بنظام الأندرويد.',
                  style: TextStyle(color: ShamturColors.muted, height: 1.5),
                ),
              ),
            ),
          ..._results.map((r) {
            final name = r.device.platformName.trim().isEmpty ? 'محول OBD غير مسمى' : r.device.platformName;
            final isConnected = connectedDev?.remoteId == r.device.remoteId;

            return Card(
              child: ListTile(
                leading: const Icon(Icons.bluetooth, color: ShamturColors.cyan),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('المعرف: ${r.device.remoteId.str}\nقوة الإشارة: ${r.rssi} dBm', style: const TextStyle(fontSize: 11)),
                isThreeLine: true,
                trailing: isConnected
                    ? const Chip(label: Text('متصل', style: TextStyle(color: ShamturColors.green)))
                    : FilledButton(
                        onPressed: _connecting ? null : () => _connectToDevice(r.device),
                        child: const Text('اتصال'),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}