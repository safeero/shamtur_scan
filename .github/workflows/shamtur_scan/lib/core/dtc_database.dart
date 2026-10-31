class DTCModel {
  final String code;
  final String descriptionEn;
  final String descriptionAr;
  final String descriptionTr;
  final String category;

  DTCModel({
    required this.code,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.descriptionTr,
    required this.category,
  });
}

class DTCDatabase {
  static final Map<String, DTCModel> codes = {
    "P0300": DTCModel(
      code: "P0300",
      descriptionEn: "Random/Multiple Cylinder Misfire Detected",
      descriptionAr: "تم اكتشاف احتراق غير منتظم في عدة أسطوانات بالمحرك",
      descriptionTr: "Rastgele/Çoklu Silindir Ateşleme Hatası Tespit Edildi",
      category: "Engine / Motor",
    ),
    "P0420": DTCModel(
      code: "P0420",
      descriptionEn: "Catalyst System Efficiency Below Threshold",
      descriptionAr: "كفاءة نظام الحفاز (الكاتاليزور) أقل من الحد الأدنى",
      descriptionTr: "Katalitik Konvertör Verimliliği Eşik Değerin Altında",
      category: "Exhaust / Egzoz",
    ),
    "P0100": DTCModel(
      code: "P0100",
      descriptionEn: "Mass or Volume Air Flow Circuit Malfunction",
      descriptionAr: "خلل في دائرة حساس تدفق الهواء (MAF)",
      descriptionTr: "Hava Akış Sensörü (MAF) Devre Arızası",
      category: "Sensors / Sensörler",
    ),
    "P0200": DTCModel(
      code: "P0200",
      descriptionEn: "Injector Circuit Malfunction",
      descriptionAr: "خلل في دائرة بخاخات وقود المحرك",
      descriptionTr: "Enjektör Devresi Arızası",
      category: "Fuel System / Yakıt Sistemi",
    ),
  };

  static DTCModel getErrorDetails(String code) {
    return codes[code.toUpperCase()] ?? DTCModel(
      code: code,
      descriptionEn: "Unknown Trouble Code",
      descriptionAr: "رمز عطل غير مألوف أو يحتاج لفحص متقدم",
      descriptionTr: "Bilinmeyen Arıza Kodu",
      category: "General / Genel",
    );
  }
}