import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'obd_command_engine.dart';

class ObdConnectionService {
  static final ObdConnectionService _instance = ObdConnectionService._internal();
  factory ObdConnectionService() => _instance;
  ObdConnectionService._internal();

  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;
  bool _isInitialized = false;

  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  Future<bool> checkAdapterStatus() async {
    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) return false;
      
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      return false;
    }
  }

  // الاتصال المطور مع تهيئة ELM327 تلقائياً
  Future<bool> connectBleDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 15), autoConnect: false);
      _connectedDevice = device;
      _isConnected = true;

      // تهيئة المحول بأوامر AT البرمجية
      _isInitialized = await ObdCommandEngine.initializeElm327(device);

      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _isConnected = false;
          _isInitialized = false;
          _connectedDevice = null;
        }
      });

      return true;
    } catch (e) {
      _isConnected = false;
      _isInitialized = false;
      _connectedDevice = null;
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _isConnected = false;
      _isInitialized = false;
    }
  }
}