import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class OBDService {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? writeCharacteristic;
  BluetoothCharacteristic? readCharacteristic;

  // فحص ما إذا كان البلوتوث مفعل والأجهزة قريبة
  Future<bool> isBluetoothAvailable() async {
    return await FlutterBluePlus.isSupported;
  }

  // بدء البحث عن أجهزة ELM327 البلوتوث
  void startScan(Function(List<ScanResult>) onScanResults) {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) {
      onScanResults(results);
    });
  }

  // الاتصال بجهاز محدد (مثل ELM327 أو OBDII)
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: false);
      connectedDevice = device;
      
      // اكتشاف الخدمات والخصائص الخاصة بإرسال واستقبال أوامر OBD
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
            writeCharacteristic = characteristic;
          }
          if (characteristic.properties.read || characteristic.properties.notify) {
            readCharacteristic = characteristic;
          }
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // إرسال أمر فحص أخطاء المحرك (مثلاً قراءة الأعطال OBD-II: 03)
  Future<String> sendCommand(String command) async {
    if (writeCharacteristic == null || readCharacteristic == null) {
      return "Error: Not connected to OBD adapter";
    }

    try {
      // إرسال الأمر بصيغة بايتات مضاف لها رمز الإنهاء CR (\r)
      List<int> bytes = utf8.encode("$command\r");
      await writeCharacteristic!.write(bytes);

      // قراءة الرد من السيارة
      List<int> responseBytes = await readCharacteristic!.read();
      String response = utf8.decode(responseBytes);
      return response;
    } catch (e) {
      return "Error executing command: $e";
    }
  }

  // قطع الاتصال
  Future<void> disconnect() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      writeCharacteristic = null;
      readCharacteristic = null;
    }
  }
}