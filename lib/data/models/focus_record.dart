class FocusRecord {
  final DateTime date;
  final int focusDurationSeconds;
  final String category;

  FocusRecord({
    required this.date,
    required this.focusDurationSeconds,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'focusDurationSeconds': focusDurationSeconds,
      'category': category,
    };
  }

  factory FocusRecord.fromJson(Map<String, dynamic> json) {
    return FocusRecord(
      date: DateTime.parse(json['date']),
      focusDurationSeconds: json['focusDurationSeconds'] as int,
      category: json['category'] as String,
    );
  }
}
