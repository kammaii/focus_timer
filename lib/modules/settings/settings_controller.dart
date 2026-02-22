import 'package:get/get.dart';
import '../../data/providers/local_storage_provider.dart';

class SettingsController extends GetxController {
  final LocalStorageProvider storageProvider;

  SettingsController({required this.storageProvider});

  var focusMinutes = 25.obs;
  var restMinutes = 5.obs;
  var repeatCount = 4.obs;
  var ambientModeEnabled = false.obs;
  
  var focusEndSound = 'default'.obs;
  var restEndSound = 'default'.obs;
  
  var categories = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    final settings = await storageProvider.loadSettings();
    focusMinutes.value = settings['focusMinutes'] ?? 25;
    restMinutes.value = settings['restMinutes'] ?? 5;
    repeatCount.value = settings['repeatCount'] ?? 4;
    ambientModeEnabled.value = settings['ambientModeEnabled'] ?? false;
    focusEndSound.value = settings['focusEndSound'] ?? 'default';
    restEndSound.value = settings['restEndSound'] ?? 'default';

    categories.value = await storageProvider.loadCategories();
  }

  Future<void> saveSettings(int focus, int rest, int repeat, bool ambient) async {
    focusMinutes.value = focus;
    restMinutes.value = rest;
    repeatCount.value = repeat;
    ambientModeEnabled.value = ambient;
    
    await storageProvider.saveSettings({
      'focusMinutes': focus,
      'restMinutes': rest,
      'repeatCount': repeat,
      'ambientModeEnabled': ambient,
    });
    
    // settings changed event
    Get.snackbar("설정 저장", "타이머 설정이 저장되었습니다.", snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> saveSilently() async {
    await storageProvider.saveSettings({
      'focusMinutes': focusMinutes.value,
      'restMinutes': restMinutes.value,
      'repeatCount': repeatCount.value,
      'ambientModeEnabled': ambientModeEnabled.value,
      'focusEndSound': focusEndSound.value,
      'restEndSound': restEndSound.value,
    });
  }

  Future<void> addCategory(String category) async {
    if (category.trim().isEmpty || categories.contains(category)) return;
    
    categories.add(category);
    await storageProvider.saveCategories(categories);
  }

  Future<void> removeCategory(String category) async {
    categories.remove(category);
    await storageProvider.saveCategories(categories);
  }
}
