import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ObdCommandEngine {
  // تهيئة شريحة ELM327 عند الاتصال الناجح
  static Future<bool> initializeElm327(BluetoothDevice device) async {
    try {
      // العثور على الخدمات والخصائص الخاصة بجهاز BLE
      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? writeChar;
      BluetoothCharacteristic? readChar;

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
            writeChar = characteristic;
          }
          if (characteristic.properties.read || characteristic.properties.notify || characteristic.properties.indicate) {
            readChar = characteristic;
          }
        }
      }

      if (writeChar == null || readChar == null) {
        return false; // خصائص البلوتوث غير متوافقة
      }

      // إرسال أوامر التهيئة القياسية لـ ELM327
      // AT Z (إعادة ضبط الشريحة)
      // AT E0 (إيقاف صدى الأوامر Echo off)
      // AT L0 (إيقاف التنسيق الإضافي Linefeeds off)
      // AT SP 0 (اختيار البروتوكول تلقائياً Automatic protocol)
      
      await _sendCommand(writeChar, readChar, 'ATZ\r');
      await _sendCommand(writeChar, readChar, 'ATE0\r');
      await _sendCommand(writeChar, readChar, 'ATL0\r');
      await _sendCommand(writeChar, readChar, 'ATSP0\r');

      return true;
    } catch (e) {
      return false;
    }
  }

  // دالة مساعدة لإرسال الأمر وقراءة الرد
  static Future<String> _sendCommand(
    BluetoothCharacteristic writeChar,
    BluetoothCharacteristic readChar,
    String command,
  ) async {
    await writeChar.write(command.codeUnits);
    await Future.delayed(const Duration(milliseconds: 200));
    
    // قراءة الاستجابة من المحول
    List<int> value = await readChar.read();
    return String.fromCharCodes(value);
  }

  // قراءة أكواد الأعطال (DTC - Diagnostic Trouble Codes)
  // الأمر القياسي: 03
  static Future<List<String>> readTroubleCodes(BluetoothDevice device) async {
    List<String> codes = [];
    try {
      // سيتم تنفيذ طبقة الإرسال واستخراج الأكواد الفعلية (مثل P0300, P0420)
      // وإرجاعها فقط إذا كانت حقيقية من السيارة.
    } catch (e) {
      // التعامل مع الخطأ أو عدم الدعم
    }
    return codes;
  }
}