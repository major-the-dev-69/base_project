abstract class BaseDataModel {
  String safeString(dynamic v, {String defaultValue = ''}) {
    if (v == null) return defaultValue;
    return v.toString();
  }

  int safeInt(dynamic v, {int defaultValue = 0}) {
    if (v == null) return defaultValue;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? defaultValue;
  }

  num safeNum(dynamic v, {num defaultValue = 0}) {
    if (v == null) return defaultValue;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? defaultValue;
  }

  double safeDouble(dynamic v, {double defaultValue = 0.0}) {
    if (v == null) return defaultValue;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? defaultValue;
  }

  bool safeBool(dynamic v, {bool defaultValue = false}) {
    if (v == null) return defaultValue;
    if (v is bool) return v;
    if (v is int) return v == 1;
    return v.toString().toLowerCase() == 'true';
  }

  DateTime safeDateTime(dynamic v, {DateTime? defaultValue}) {
    if (v == null) return defaultValue ?? DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? defaultValue ?? DateTime.now();
  }

  List<T> safeList<T>(dynamic v, T Function(dynamic json) parser) {
    if (v == null || v is! List) return <T>[];
    return v.map((e) => parser(e)).toList();
  }
}
