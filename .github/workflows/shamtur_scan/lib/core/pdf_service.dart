import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dtc_database.dart';

class PDFService {
  static Future<void> generateAndPrintReport({
    required String carModel,
    required String plateNumber,
    required List<String> errorCodes,
    required String language, // 'ar', 'tr', or 'en'
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // رأس التقرير
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("SHAMTUR SCAN - Enterprise Diagnostic",
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text(DateTime.now().toString().substring(0, 16),
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),

              // معلومات السيارة
              pw.Text("Vehicle Model / طراز السيارة: $carModel",
                  style: const pw.TextStyle(fontSize: 14)),
              pw.Text("Plate Number / رقم اللوحة: $plateNumber",
                  style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),

              // جدول الأعطال
              pw.Text("Diagnostic Trouble Codes (DTC) / تقرير الأعطال:",
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              // قائمة الأعطال
              ...errorCodes.map((code) {
                var dtc = DTCDatabase.getErrorDetails(code);
                String description = dtc.descriptionEn;
                if (language == 'ar') description = dtc.descriptionAr;
                if (language == 'tr') description = dtc.descriptionTr;

                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(dtc.code,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red800)),
                      pw.Expanded(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                          child: pw.Text(description,
                              style: const pw.TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  "SHAMTUR SCAN - Professional Vehicle Diagnostics Software",
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ),
            ],
          );
        },
      ),
    );

    // طباعة أو حفظ ملف الـ PDF مباشرة
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}