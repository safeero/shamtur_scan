import 'package:flutter/material.dart';
import '../../core/subscription_service.dart';
import '../../core/theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    bool status = await SubscriptionService.isSubscribed();
    setState(() {
      _isSubscribed = status;
    });
  }

  void _activateDemoSubscription() async {
    // تفعيل تجريبي للاشتراك لمدة 30 يوماً (عبر تأكيد التحويل البنكي Ziraat Bank أو الوكيل)
    await SubscriptionService.activateSubscription(30);
    _checkStatus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم تفعيل اشتراك الورشة بنجاح لمدة 30 يوماً!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SHAMTUR SCAN - إدارة الاشتراكات"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user, size: 80, color: ShamturTheme.primaryCyan),
            const SizedBox(height: 20),
            Text(
              _isSubscribed ? "حالة الحساب: مشترك ومفعل (Active)" : "حالة الحساب: غير مشترك (Expired/Inactive)",
              style: TextStyle(
                color: _isSubscribed ? ShamturTheme.secondaryGreen : ShamturTheme.alertRed,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "تفاصيل الاشتراك التجاري للورش:",
                      style: TextStyle(color: ShamturTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "• دعم الفحص الشامل للسيارات في السوق التركي والسوري.\n"
                      "• تحديثات دورية لقاعدة بيانات الأعطال DTC.\n"
                      "• طباعة تقارير PDF احترافية باسم الورشة.\n"
                      "• الدفع عبر الحوالات المحلية أو Ziraat Bank.",
                      style: TextStyle(color: ShamturTheme.textWhite, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _activateDemoSubscription,
                child: const Text("تفعيل الاشتراك عبر التحويل البنكي / الوكيل"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}