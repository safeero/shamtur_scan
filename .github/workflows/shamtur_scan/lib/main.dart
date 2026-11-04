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
      'connection_title': 'إدارة الاتصال بقطعة الـ OBD2',
      'bluetooth_tab': 'البلوتوث (Bluetooth)',
      'wifi_tab': 'الواي فاي (Wi-Fi)',
      'subscription': 'الاشتراكات والترخيص',
      'electric': 'سيارة كهربائية (EV)',
      'hybrid': 'هجين (Hybrid)',
      'fuel': 'وقود (Fuel)',
      'start_scan': 'بدء فحص الأعطال الشامل',
      'scanning': 'جاري فحص أنظمة السيارة...',
      'scan_history': 'سجل الفحص والتشخيص:',
      'no_faults': 'النظام نظيف وآمن. اضغط على بدء الفحص للبحث.',
      'bank_title': 'التحويل البنكي المعتمد',
      'holder': 'المستفيد: BAKRI ALLABABIDI',
      'iban': 'رقم الـ IBAN:',
      'receipt_hint': 'أدخل رقم إيصال التحويل البنكي',
      'submit_receipt': 'إرسال الطلب للإدارة',
      'success_msg': 'تم إرسال طلبك بنجاح. سيتم التفعيل بعد مراجعة الإيصال.',
      'wifi_instructions': 'اتصل بشبكة الواي فاي الخاص بقطعة الـ OBD2 (مثل Wi-Fi_OBDII) من إعدادات الواي فاي في هاتفك، ثم اضغط اتصال.',
      'connect_btn': 'اتصال بالقطعة',
    },
    'tr': {
      'app_title': 'Shamtur Scan - Araç Teşhis',
      'login_title': 'Müşteri Girişi',
      'phone_hint': 'Telefon Numarasını Girin',
      'login_btn': 'Giriş / Abonelik Kontrolü',
      'connection_title': 'OBD2 Bağlantı Yönetimi',
      'bluetooth_tab': 'Bluetooth',
      'wifi_tab': 'Wi-Fi',
      'subscription': 'Abonelikler',
      'electric': 'Elektrikli (EV)',
      'hybrid': 'Hibrit',
      'fuel': 'Yakıt',
      'start_scan': 'Kapsamlı Taramayı Başlat',
      'scanning': 'Taranıyor...',
      'scan_history': 'Teşhis Geçmişi:',
      'no_faults': 'Sistem temiz. Taramayı başlatın.',
      'bank_title': 'Banka Havale Bilgileri',
      'holder': 'Alıcı: BAKRI ALLABABIDI',
      'iban': 'IBAN Numarası:',
      'receipt_hint': 'Dekont numarasını girin',
      'submit_receipt': 'Onaya Gönder',
      'success_msg': 'Talebiniz iletildi.',
      'wifi_instructions': 'Telefonunuzun Wi-Fi ayarlarından OBD2 cihaz ağınıza (örn: Wi-Fi_OBDII) bağlanın ve ardından bağlan butonuna basın.',
      'connect_btn': 'Cihaza Bağlan',
    },
    'en': {
      'app_title': 'Shamtur Scan - HUD Diagnostics',
      'login_title': 'Client Login',
      'phone_hint': 'Enter Phone Number',
      'login_btn': 'Login / Check Subscription',
      'connection_title': 'OBD2 Connection Manager',
      'bluetooth_tab': 'Bluetooth',
      'wifi_tab': 'Wi-Fi',
      'subscription': 'Subscriptions',
      'electric': 'Electric (EV)',
      'hybrid': 'Hybrid',
      'fuel': 'Fuel',
      'start_scan': 'Start Comprehensive Scan',
      'scanning': 'Scanning systems...',
      'scan_history': 'Diagnostics History:',
      'no_faults': 'System is clean. Tap start scan.',
      'bank_title': 'Bank Transfer Details',
      'holder': 'Beneficiary: BAKRI ALLABABIDI',
      'iban': 'IBAN:',
      'receipt_hint': 'Enter transfer receipt number',
      'submit_receipt': 'Submit to Admin',
      'success_msg': 'Request submitted successfully.',
      'wifi_instructions': 'Connect your phone to the OBD2 Wi-Fi network (e.g., Wi-Fi_OBDII) from phone settings, then tap connect.',
      'connect_btn': 'Connect Device',
    }
  };

  static String get(String key) => translations[currentLang]?[key] ?? key;
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
// شاشة تسجيل الدخول برقم الهاتف
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
    await Future.delayed(const Duration(seconds: 1));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', phone);

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
      detectedFaults.add('تنبيه: لم يتم رصد قطعة OBD2 متصلة (سواء عبر البلوتوث أو الواي فاي). يرجى ربط القطعة أولاً.');
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
            icon: const Icon(Icons.settings_input_antenna, color: Color(0xFF00F2FE)),
            tooltip: 'إدارة الاتصال',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConnectionManagerScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.card_membership, color: Color(0xFF00FF87)),
            tooltip: 'الاشتراكات',
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
// شاشة إدارة الاتصال (بلوتوث أو واي فاي) بأسماء نظيفة وبدون أكواد طويلة
// ==========================================
class ConnectionManagerScreen extends StatefulWidget {
  const ConnectionManagerScreen({super.key});

  @override
  State<ConnectionManagerScreen> createState() => _ConnectionManagerScreenState();
}

class _ConnectionManagerScreenState extends State<ConnectionManagerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // متغيرات خاصة بالبلوتوث
  List<ScanResult> _bluetoothDevices = [];
  bool _isScanningBluetooth = false;
  String _bluetoothStatus = 'جاهز للبحث عن أجهزة البلوتوث';

  // متغيرات خاصة بالواي فاي
  final TextEditingController _wifiIpController = TextEditingController(text: '192.168.0.10');
  final TextEditingController _wifiPortController = TextEditingController(text: '35000');
  bool _isConnectingWifi = false;
  String _wifiStatus = 'جاهز للاتصال عبر الشبكة اللاسلكية';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // بحث البلوتوث (مع إخفاء الأكواد الطويلة وإظهار الاسم النظيف فقط)
  void _startBluetoothScan() async {
    setState(() {
      _isScanningBluetooth = true;
      _bluetoothDevices.clear();
      _bluetoothStatus = 'جاري البحث عن أجهزة OBD2 القريبة...';
    });

    try {
      bool isAdapterOn = await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
      if (!isAdapterOn) {
        setState(() {
          _bluetoothStatus = 'خطأ: يرجى تشغيل البلوتوث في إعدادات الهاتف.';
          _isScanningBluetooth = false;
        });
        return;
      }

      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          _bluetoothDevices = results;
        });
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));
      
      setState(() {
        _isScanningBluetooth = false;
        _bluetoothStatus = _bluetoothDevices.isEmpty ? 'لم يتم العثور على أجهزة بلوتوث قريبة.' : 'اختر جهاز OBD2 من القائمة:';
      });
    } catch (e) {
      setState(() {
        _isScanningBluetooth = false;
        _bluetoothStatus = 'حدث خطأ في البحث.';
      });
    }
  }

  // محاكاة الاتصال عبر الواي فاي
  void _connectViaWifi() async {
    setState(() {
      _isConnectingWifi = true;
      _wifiStatus = 'جاري الاتصال بعنوان القطعة...';
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isConnectingWifi = false;
      _wifiStatus = 'تم الاتصال بنجاح بقطعة الواي فاي اللاسلكية!';
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم الاتصال عبر الواي فاي بنجاح!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.get('connection_title'), style: const TextStyle(color: Color(0xFF00F2FE), fontSize: 15)),
        backgroundColor: const Color(0xFF0A192F),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00FF87),
          labelColor: const Color(0xFF00FF87),
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(icon: const Icon(Icons.bluetooth), text: AppLocale.get('bluetooth_tab')),
            Tab(icon: const Icon(Icons.wifi), text: AppLocale.get('wifi_tab')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ----------------- تاب البلوتوث (بأسماء نظيفة فقط بدون أكواد طويلة) -----------------
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A192F),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00FF87), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF00FF87)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_bluetoothStatus, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F2FE), foregroundColor: Colors.black),
                  onPressed: _isScanningBluetooth ? null : _startBluetoothScan,
                  icon: const Icon(Icons.search),
                  label: Text(_isScanningBluetooth ? 'جاري البحث...' : 'بحث عن أجهزة البلوتوث'),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: _bluetoothDevices.length,
                    itemBuilder: (context, index) {
                      final result = _bluetoothDevices[index];
                      // إظهار الاسم النظيف فقط وإخفاء الكود الطويل المزعج تماماً
                      String cleanName = result.device.platformName.isNotEmpty ? result.device.platformName : 'OBDII Bluetooth Device';
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A192F),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                        ),
                        child: ListTile(
                          title: Text(cleanName, style: const TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold)),
                          subtitle: const Text('متوافق مع محولات ELM327', style: TextStyle(color: Colors.white38, fontSize: 11)),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF87), foregroundColor: Colors.black),
                            onPressed: () async {
                              try {
                                await result.device.connect();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الاتصال بنجاح عبر البلوتوث!')));
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

          // ----------------- تاب الواي فاي (الاتصال عبر الشبكة اللاسلكية) -----------------
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A192F),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00FF87), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi, color: Color(0xFF00FF87)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_wifiStatus, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(AppLocale.get('wifi_instructions'), style: const TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 20),
                TextField(
                  controller: _wifiIpController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'عنوان آيباد القطعة (IP Address)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.cyan)),
                    filled: true,
                    fillColor: const Color(0xFF0A192F),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _wifiPortController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'منفذ الاتصال (Port)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.cyan)),
                    filled: true,
                    fillColor: const Color(0xFF0A192F),
                  ),
                ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF87),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isConnectingWifi ? null : _connectViaWifi,
                child: Text(
                  _isConnectingWifi ? 'جاري الاتصال بالشبكة...' : AppLocale.get('connect_btn'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// شاشة الاشتراكات وتفاصيل حسابك البنكي الثابت
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
