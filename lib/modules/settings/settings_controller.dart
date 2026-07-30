import 'package:get/get.dart';
import '../../data/providers/local_storage_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/services/ad_service.dart';

class SettingsController extends GetxController {
  final LocalStorageProvider storageProvider;
  final AudioPlayer _audioPlayer = AudioPlayer();

  SettingsController({required this.storageProvider});

  var focusMinutes = 25.obs;
  var restMinutes = 5.obs;
  var repeatCount = 4.obs;
  var ambientModeEnabled = true.obs;

  var focusEndSound = 'ding_ding.mp3'.obs;
  var restEndSound = 'ding_ring.mp3'.obs;

  var categories = <String>[].obs;
  var isAdminMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isAdminMode.value = AdService().adsDisabledForDevice;
    final settings = await storageProvider.loadSettings();
    focusMinutes.value = settings['focusMinutes'] ?? 25;
    restMinutes.value = settings['restMinutes'] ?? 5;
    repeatCount.value = settings['repeatCount'] ?? 4;
    ambientModeEnabled.value = true;
    focusEndSound.value = settings['focusEndSound'] ?? 'ding_ding.mp3';
    restEndSound.value = settings['restEndSound'] ?? 'ding_ring.mp3';

    // 이전에 default나 옛날 임시 파일이 지정되어 있었을 경우 새 파일명으로 기본 변경
    if (focusEndSound.value == 'default' ||
        focusEndSound.value == 'focus_end.wav')
      focusEndSound.value = 'ding_ding.mp3';
    if (restEndSound.value == 'default' || restEndSound.value == 'rest_end.wav')
      restEndSound.value = 'ding_ring.mp3';

    categories.value = await storageProvider.loadCategories();
  }

  Future<void> saveSettings(
    int focus,
    int rest,
    int repeat,
    bool _ambient,
  ) async {
    focusMinutes.value = focus;
    restMinutes.value = rest;
    repeatCount.value = repeat;
    ambientModeEnabled.value = true;

    await storageProvider.saveSettings({
      'focusMinutes': focus,
      'restMinutes': rest,
      'repeatCount': repeat,
      'ambientModeEnabled': true,
    });

    // settings changed event
    Get.snackbar(
      "설정 저장",
      "타이머 설정이 저장되었습니다.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> saveSilently() async {
    await storageProvider.saveSettings({
      'focusMinutes': focusMinutes.value,
      'restMinutes': restMinutes.value,
      'repeatCount': repeatCount.value,
      'ambientModeEnabled': true,
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

  Future<void> resetAdminMode() async {
    await AdService().enableAdsForDevice();
    isAdminMode.value = false;
    Get.snackbar(
      "설정 변경",
      "일반 모드로 전환되었습니다. 이제 광고가 표시됩니다.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void playTestSound(String filename) async {
    if (filename == 'silent') return;
    String target = filename;
    if (target == 'default' || target == 'focus_end.wav')
      target = 'ding_ding.mp3';
    if (target == 'rest_end.wav') target = 'ding_ring.mp3';

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$target'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
