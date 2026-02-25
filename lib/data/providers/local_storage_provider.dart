import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/focus_record.dart';
import '../models/damagotchi_data.dart';

class LocalStorageProvider {
  static const String _recordsKey = 'focus_records';
  static const String _categoriesKey = 'focus_categories';
  static const String _settingsKey = 'app_settings';
  static const String _damagotchiKey = 'damagotchi_data';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // --- Settings ---
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await _prefs;
    await prefs.setString(_settingsKey, jsonEncode(settings));
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await _prefs;
    final String? settingsStr = prefs.getString(_settingsKey);
    if (settingsStr != null) {
      return jsonDecode(settingsStr);
    }
    return {
      'focusMinutes': 25,
      'restMinutes': 5,
      'repeatCount': 4,
    };
  }

  // --- Categories ---
  Future<void> saveCategories(List<String> categories) async {
    final prefs = await _prefs;
    await prefs.setStringList(_categoriesKey, categories);
  }

  Future<List<String>> loadCategories() async {
    final prefs = await _prefs;
    final List<String>? categories = prefs.getStringList(_categoriesKey);
    return categories ?? ['공부', '독서', '업무'];
  }

  // --- Records ---
  Future<void> addRecord(FocusRecord record) async {
    final prefs = await _prefs;
    List<FocusRecord> currentRecords = await loadRecords();
    currentRecords.add(record);
    
    final List<String> encodedList = currentRecords.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_recordsKey, encodedList);
  }

  Future<List<FocusRecord>> loadRecords() async {
    final prefs = await _prefs;
    final List<String>? recordsStrList = prefs.getStringList(_recordsKey);
    
    if (recordsStrList == null) return [];
    
    return recordsStrList.map((str) {
      return FocusRecord.fromJson(jsonDecode(str));
    }).toList();
  }

  // --- Damagotchi ---
  Future<void> saveDamagotchiData(DamagotchiData data) async {
    final prefs = await _prefs;
    await prefs.setString(_damagotchiKey, jsonEncode(data.toJson()));
  }

  Future<DamagotchiData> loadDamagotchiData() async {
    final prefs = await _prefs;
    final String? dataStr = prefs.getString(_damagotchiKey);
    
    if (dataStr != null) {
      try {
        return DamagotchiData.fromJson(jsonDecode(dataStr));
      } catch (e) {
        // parsing error
      }
    }
    return DamagotchiData();
  }
}
