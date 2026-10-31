enum VehicleType { electric, hybrid, petrolDiesel }

enum DataStatus { live, demo, unavailable, unsupported }

class DiagnosticValue {
  const DiagnosticValue({
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
    this.note,
  });

  final String label;
  final String value;
  final String unit;
  final DataStatus status;
  final String? note;
}

class TroubleCode {
  const TroubleCode({
    required this.code,
    required this.title,
    required this.description,
    required this.status,
  });

  final String code;
  final String title;
  final String description;
  final DataStatus status;
}
