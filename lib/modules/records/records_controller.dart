import 'package:get/get.dart';
import '../../data/models/focus_record.dart';
import '../../data/providers/local_storage_provider.dart';

class RecordsController extends GetxController {
  final LocalStorageProvider storageProvider;

  RecordsController({required this.storageProvider});

  var records = <FocusRecord>[].obs;
  var maxStreak = 0.obs;
  var currentStreak = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  Future<void> loadRecords() async {
    records.value = await storageProvider.loadRecords();
    _calculateStreaks();
  }

  Future<void> addRecord(int durationSeconds, String category) async {
    final record = FocusRecord(
      date: DateTime.now(),
      focusDurationSeconds: durationSeconds,
      category: category,
    );
    await storageProvider.addRecord(record);
    await loadRecords();
  }

  void _calculateStreaks() {
    if (records.isEmpty) {
      currentStreak.value = 0;
      maxStreak.value = 0;
      return;
    }

    final sortedDates = records
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Descending

    int current = 0;
    int max = 0;
    int tempStreak = 1;
    
    DateTime today = DateTime.now();
    DateTime normalizedToday = DateTime(today.year, today.month, today.day);

    if (sortedDates.first.isAtSameMomentAs(normalizedToday) || 
        sortedDates.first.isAtSameMomentAs(normalizedToday.subtract(const Duration(days: 1)))) {
       current = 1;
    }

    for (int i = 0; i < sortedDates.length - 1; i++) {
      if (sortedDates[i].difference(sortedDates[i + 1]).inDays == 1) {
        tempStreak++;
        if (i == 0 || current == i + 1) {
          current++;
        }
      } else {
        if (tempStreak > max) max = tempStreak;
        tempStreak = 1;
      }
    }
    if (tempStreak > max) max = tempStreak;
    if (sortedDates.length == 1) max = 1;

    currentStreak.value = current;
    maxStreak.value = max;
  }
}
