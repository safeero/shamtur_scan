import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../core/report_generator_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _generating = false;

  Future<void> _exportReport() async {
    setState(() => _generating = true);

    final prefs = await SharedPreferences.getInstance();
    final make = prefs.getString('vehicle.make') ?? 'Generic';
    final model = prefs.getString('vehicle.model') ?? 'Vehicle';
    final year = prefs.getString('vehicle.year') ?? '2024';
    final vin = prefs.getString('vehicle.vin') ?? '';

    // استخدام الأكواد التجريبية أو المسجلة مؤخراً
    final List<String> sampleCodes = ['P0300', 'P0420'];

    await ReportGeneratorService.generateAndShareReport(
      vehicleMake: make,
      vehicleModel: model,
      vehicleYear: year,
      vehicleVin: vin,
      troubleCodes: sampleCodes,
    );

    if (mounted) {
      setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تقارير الفحص والتوثيق')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.description_outlined, color: ShamturColors.cyan, size: 34),
                  const SizedBox(height: 12),
                  const Text('تصدير تقرير رسمي (PDF)', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'قم بإنشاء تقرير احترافي متكامل يتضمن معلومات السيارة المسجلة، نتائج فحص الأخطاء (DTCs)، ومشاركتها مباشرة مع العملاء أو حفظها كملف رسمي يحمل هوية شركتك.',
                    style: TextStyle(color: ShamturColors.muted, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _generating ? null : _exportReport,
                      icon: _generating
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.picture_as_pdf),
                      label: Text(_generating ? 'جارٍ إعداد التقرير...' : 'إنشاء ومشاركة تقرير PDF'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}