import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShamturScanApp());
}

// مدير اللغات والتطبيق
class AppLocale {
  static String currentLang = 'ar';

  static Map<String, Map<String, String>> translations = {
    'ar': {
      'app_title': 'شامتور سكان - فحص السيارات',
      'login_title': 'تسجيل دخول العميل',
      'phone_hint': 'أدخل رقم الهاتف (مع رمز الدولة)',
      'login_btn': 'دخول / التحقق من الاشتراك',
      'bluetooth': 'الاتصال بالـ OBD2',
      'subscription': 'الاشتراكات والترخيص',
      'electric': 'سيارة كهربائية (EV)',
      'hybrid': 'هجين (Hybrid)',
      'fuel': 'وقود (Fuel)',
      'start_scan': 'بدء فحص الأعطال الشامل',
      'scanning': 'جاري فحص أنظمة السيارة...',
      'scan_history': 'سجل الفحص والتشخيص:',
      'no_faults': 'النظام نظيف وآمن. اضغط على بدء الفحص للبحث.',
      'active_sub': 'الاشتراك نشط. الأيام المتبقية: ',
      'expired_sub': 'اشتراكك منتهي أو غير مفعيل. يرجى التجديد عبر التحويل البنكي.',
      'bank_title': 'التحويل البنكي المعتمد',
      'holder': 'المستفيد: BAKRI ALLABABIDI',
      'iban': 'رقم الـ IBAN:',
      'receipt_hint': 'أدخل رقم إيصال التحويل البنكي',
      'submit_receipt': 'إرسال الطلب للإدارة',
      'success_msg': 'تم إرسال طلبك بنجاح. سيتم التفعيل بعد مراجعة الإيصال.',
    },
    'tr': {
      'app_title': 'Shamtur Scan - Araç Teşhis',
      'login_title': 'Müşteri Girişi',
      'phone_hint': 'Telefon Numarasını Girin',
      'login_btn': 'Giriş / Abonelik Kontrolü',
      'bluetooth': 'OBD2 Bağlantısı',
      'subscription': 'Abonelikler',
      'electric': 'Elektrikli (EV)',
      'hybrid': 'Hibrit',
      'fuel': 'Yakıt',
      'start_scan': 'Kapsamlı Taramayı Başlat',
      'scanning': 'Taranıyor...',
      'scan_history': 'Teşhis Geçmişi:',
      'no_faults': 'Sistem temiz. Taramayı başlatın.',
      'active_sub': 'Abonelik Aktif. Kalan Gün: ',
      'expired_sub': 'Aboneliğiniz sona erdi. Lütfen havale ile yenileyin.',
      'bank_title': 'Banka Havale Bilgileri',
      'holder': 'Alıcı: BAKRI ALLABABIDI',
      'iban': 'IBAN Numarası:',
      'receipt_hint': 'Dekont numarasını girin',
      'submit_receipt': 'Onaya Gönder',
      'success_msg': 'Talebiniz iletildi. İncelendikten sonra aktifleşecektir.',
    },
    'en': {
      'app_title': 'Shamtur Scan - HUD Diagnostics',
      'login_title': 'Client Login',
      'phone_hint': 'Enter Phone Number',
      'login_btn': 'Login / Check Subscription',
      'bluetooth': 'OBD2 Connection',
      'subscription': 'Subscriptions',
      'electric': 'Electric (EV)',
      'hybrid': 'Hybrid',
      'fuel': 'Fuel',
      'start_scan': 'Start Comprehensive Scan',
      'scanning': 'Scanning systems...',
      'scan_history': 'Diagnostics History:',
      'no_faults': 'System is clean. Tap start scan.',
      'active_sub': 'Subscription Active. Days Left: ',
      'expired_sub': 'Subscription expired. Please renew via bank transfer.',
      'bank_title': 'Bank Transfer Details',
      'holder': 'Beneficiary: BAKRI ALLABABIDI',
      'iban': 'IBAN:',
      'receipt_hint': 'Enter transfer receipt number',
      'submit_receipt': 'Submit to Admin',
      'success_msg': 'Request submitted successfully. Will be activated after review.',
    }
  };

  static String get(String key) => translations[currentLang]?[key] ?? key;
}

void mainAsyncSetup() async {
  WidgetsFlutterBinding.ensureInitialized();
}

class ShamturScanApp extends StatefulWidget {
  const ShamturScanApp({super.key});

  @override
  State<ShamturScanApp> createState() => _ShamturScanAppState();
}

class _ShamturScanAppState extends State<ShamturScanApp> {
  void changeLanguage(String lang) {
    setState(() {
      AppLocale.currentLang = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shamtur Scan Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050B14),
        primaryColor: const Color(0xFF00F2FE),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F2FE),
          secondary: Color(0xFF00FF87),
          surface: Color(0xFF0A192F),
        ),
        fontFamily: 'Roboto',
      ),
      home: LoginScreen(onLanguageChanged: changeLanguage),
    );
  }
}

// ==========================================
// شاشة تسجيل الدخول برقم الهاتف (ربط السيرفر/الجدول)
// ==========================================
class LoginScreen extends StatefulWidget {
  final Function(String) onLanguageChanged;
  const LoginScreen({super.key, required this.onLanguageChanged});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void _verifyAndLogin() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم الهاتف بشكل صحيح')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // محاكاة التحقق السحابي (هنا سيتم لاحقاً جلب الحالة من جدول بياناتك على الكمبيوتر)
    await Future.delayed(const Duration(seconds: 2));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', phone);

    // افتراضياً لغرض التجربة: إذا كان الرقم مدخلاً نعتبره مفعلاً أو نأخذه للوحة التحكم
    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HolographicDashboard(onLanguageChanged: widget.onLanguageChanged)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        title: Text(AppLocale.get('login_title'), style: const TextStyle(color: Color(0xFF00F2FE))),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Color(0xFF00F2FE)),
            onSelected: (lang) => widget.onLanguageChanged(lang),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ar', child: Text('العربية')),
              const PopupMenuItem(value: 'tr', child: Text('Türkçe')),
              const PopupMenuItem(value: 'en', child: Text('English')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Color(0xFF00F2FE)),
            const SizedBox(height: 20),
            Text(AppLocale.get('app_title'),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: AppLocale.get('phone_hint'),
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.cyan)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00FF87), width: 2)),
                filled: true,
                fillColor: const Color(0xFF0A192F),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F2FE),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isLoading ? null : _verifyAndLogin,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : Text(AppLocale.get('login_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// لوحة التحكم الرئيسية (HUD Dashboard)
// ==========================================
class HolographicDashboard extends StatefulWidget {
  final Function(String) onLanguageChanged;
  const HolographicDashboard({super.key, required this.onLanguageChanged});

  @override
  State<HolographicDashboard> createState() => _HolographicDashboardState();
}

class _HolographicDashboardState extends State<HolographicDashboard> {
  String selectedVehicleType = 'electric';
  bool isScanningActive = false;
  List<String> detectedFaults = [];

  void _startRealDiagnostics() async {
    setState(() {
      isScanningActive = true;
      detectedFaults.clear();
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isScanningActive = false;
      detectedFaults.add('تنبيه: لم يتم رصد وحدة OBD2 متصلة. يرجى ربط القطعة أولاً.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        title: Text(AppLocale.get('app_title'), style: const TextStyle(color: Color(0xFF00F2FE), fontSize: 13)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth, color: Color(0xFF00F2FE)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OBDConnectionScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.card_membership, color: Color(0xFF00FF87)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen())),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildVehicleTypeChip(AppLocale.get('electric'), 'electric'),
                const SizedBox(width: 8),
                _buildVehicleTypeChip(AppLocale.get('hybrid'), 'hybrid'),
                const SizedBox(width: 8),
                _buildVehicleTypeChip(AppLocale.get('fuel'), 'fuel'),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F2FE),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isScanningActive ? null : _startRealDiagnostics,
                icon: isScanningActive
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.radar),
                label: Text(isScanningActive ? AppLocale.get('scanning') : AppLocale.get('start_scan'),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A192F).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocale.get('scan_history'), style: const TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white24),
                    Expanded(
                      child: detectedFaults.isEmpty
                          ? Center(child: Text(AppLocale.get('no_faults'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 13)))
                          : ListView.builder(
                              itemCount: detectedFaults.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const Icon(Icons.info_outline, color: Colors.amberAccent),
                                  title: Text(detectedFaults[index], style: const TextStyle(color: Colors.white, fontSize: 13)),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleTypeChip(String label, String type) {
    bool isSelected = selectedVehicleType == type;
    return Expanded(
      child: ChoiceChip(
        label: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
        selected: isSelected,
        selectedColor: const Color(0xFF00F2FE).withOpacity(0.3),
        backgroundColor: const Color(0xFF0A192F),
        labelStyle: TextStyle(color: isSelected ? const Color(0xFF00F2FE) : Colors.white70),
        onSelected: (bool selected) {
          setState(() {
            selectedVehicleType = type;
          });
        },
      ),
    );
  }
}

// ==========================================
// شاشة اتصال البلوتوث (OBD2)
// ==========================================
class OBDConnectionScreen extends StatefulWidget {
  const OBDConnectionScreen({super.key});

  @override
  State<OBDConnectionScreen> createState() => _OBDConnectionScreenState();
}

class _OBDConnectionScreenState extends State<OBDConnectionScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  String _statusMessage = 'جاهز للبحث عن أجهزة OBD2 القريبة';

  void _startBluetoothScan() async {
    setState(() {
      _isScanning = true;
      _scanResults.clear();
      _statusMessage = 'جاري التحقق من البلوتوث والأذونات...';
    });

    try {
      bool isAdapterOn = await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
      if (!isAdapterOn) {
        setState(() {
          _statusMessage = 'خطأ: يرجى تشغيل البلوتوث في إعدادات الهاتف.';
          _isScanning = false;
        });
        return;
      }

      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          _scanResults = results;
        });
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 7));
      
      setState(() {
        _isScanning = false;
        if (_scanResults.isEmpty) {
          _statusMessage = 'لم يتم العثور على أجهزة. تأكد من تشغيل السيارة ووجود القطعة.';
        } else {
          _statusMessage = 'تم اكتشاف الأجهزة التالية:';
        }
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'خطأ في البحث: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.get('bluetooth'), style: const TextStyle(color: Color(0xFF00F2FE))),
        backgroundColor: const Color(0xFF0A192F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF0A192F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00FF87), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bluetooth_connected, color: Color(0xFF00FF87)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_statusMessage,
                        style: const TextStyle(color: Color(0xFF00FF87), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F2FE), foregroundColor: Colors.black),
              onPressed: _isScanning ? null : _startBluetoothScan,
              icon: const Icon(Icons.search),
              label: Text(_isScanning ? 'جاري البحث...' : 'بحث عن قطع OBD2'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _scanResults.length,
                itemBuilder: (context, index) {
                  final result = _scanResults[index];
                  String name = result.device.platformName.isNotEmpty ? result.device.platformName : 'OBDII Device';
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A192F),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                    ),
                    child: ListTile(
                      title: Text(name, style: const TextStyle(color: Color(0xFF00F2FE))),
                      subtitle: Text(result.device.remoteId.toString(), style: const TextStyle(color: Colors.white54)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF87), foregroundColor: Colors.black),
                        onPressed: () async {
                          try {
                            await result.device.connect();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الاتصال بنجاح!')));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الاتصال: $e')));
                          }
                        },
                        child: const Text('اتصال'),
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

// ==========================================
// شاشة الاشتراكات والتحويل البنكي لحسابك الثابت
// ==========================================
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final TextEditingController _receiptController = TextEditingController();
  bool _requestSent = false;

  void _submitBankTransfer() async {
    if (_receiptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم إيصال التحويل البنكي!')),
      );
      return;
    }

    setState(() => _requestSent = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0A192F),
          title: const Text('تم إرسال الطلب', style: TextStyle(color: Color(0xFF00FF87))),
          content: Text(AppLocale.get('success_msg'), style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('حسناً', style: TextStyle(color: Color(0xFF00F2FE))),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.get('subscription'), style: const TextStyle(color: Color(0xFF00F2FE))),
        backgroundColor: const Color(0xFF0A192F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0A192F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00FF87), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocale.get('bank_title'),
                      style: const TextStyle(color: Color(0xFF00FF87), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('المستفيد: BAKRI ALLABABIDI',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('رقم الـ IBAN:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(6)),
                    child: const SelectableText(
                      'TR610001001119866870265001',
                      style: TextStyle(color: Color(0xFF00F2FE), fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _receiptController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: AppLocale.get('receipt_hint'),
                labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.cyan)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00FF87), width: 2)),
                filled: true,
                fillColor: const Color(0xFF0A192F),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF87),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _requestSent ? null : _submitBankTransfer,
                child: Text(
                  _requestSent ? 'جاري المعالجة...' : AppLocale.get('submit_receipt'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
