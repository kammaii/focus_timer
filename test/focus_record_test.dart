import 'package:flutter_test/flutter_test.dart';
import 'package:focus_timer/data/models/focus_record.dart';

void main() {
  group('FocusRecord Model Tests', () {
    test('FocusRecord to json and from json', () {
      final date = DateTime(2023, 10, 25, 12, 0, 0);
      final record = FocusRecord(
        date: date,
        focusDurationSeconds: 1500,
        category: '공부',
      );

      final json = record.toJson();
      expect(json['date'], date.toIso8601String());
      expect(json['focusDurationSeconds'], 1500);
      expect(json['category'], '공부');

      final newRecord = FocusRecord.fromJson(json);
      expect(newRecord.date, date);
      expect(newRecord.focusDurationSeconds, 1500);
      expect(newRecord.category, '공부');
    });
  });
}
