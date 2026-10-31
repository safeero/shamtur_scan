import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  static const String _subKey = "is_subscribed";
  static const String _expiryKey = "subscription_expiry";

  // التحقق مما إذا كان حساب الورشة أو الفاحص مشتركاً ومفعلاً
  static Future<bool> isSubscribed() async {
    final prefs = await SharedPreferences.getInstance();
    bool isSub = prefs.getBool(_subKey) ?? false;
    
    if (!isSub) return false;

    // التحقق من تاريخ انتهاء الاشتراك
    String? expiryDateStr = prefs.getString(_expiryKey);
    if (expiryDateStr != null) {
      DateTime expiryDate = DateTime.parse(expiryDateStr);
      if (DateTime.now().isAfter(expiryDate)) {
        // انتهى الاشتراك
        return false;
      }
    }
    return true;
  }

  // تفعيل الاشتراك يدوياً (عبر الإدارة أو بعد تأكيد حوالة Ziraat Bank / الوكيل المحلي)
  static Future<void> activateSubscription(int days) async {
    final prefs = await SharedPreferences.getInstance();
    DateTime expiryDate = DateTime.now().add(Duration(days: days));
    
    await prefs.setBool(_subKey, true);
    await prefs.setString(_expiryKey, expiryDate.toIso8601String());
  }

  // إلغاء تفعيل الاشتراك
  static Future<void> clearSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_subKey);
    await prefs.remove(_expiryKey);
  }
}