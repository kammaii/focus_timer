import 'dart:async';
import 'package:get/get.dart';
import '../settings/settings_controller.dart';
import '../records/records_controller.dart';

enum TimerState { idle, focus, rest }

class HomeController extends GetxController {
  final SettingsController settings;
  final RecordsController records;

  HomeController({required this.settings, required this.records});

  var currentState = TimerState.idle.obs;
  var isPaused = false.obs;
  var remainingSeconds = 0.obs;
  var selectedCategory = "".obs;
  var currentCycle = 1.obs;
  
  Timer? _timer;

  int get totalSeconds {
    if (currentState.value == TimerState.rest) return settings.restMinutes.value * 60;
    return settings.focusMinutes.value * 60;
  }

  double get progress {
    if (totalSeconds == 0) return 0;
    return 1.0 - (remainingSeconds.value / totalSeconds);
  }

  @override
  void onInit() {
    super.onInit();
    // Default config update trigger
    ever(settings.focusMinutes, (_) => _resetTimer());
    _resetTimer();
    
    // Set default category
    if (settings.categories.isNotEmpty) {
      selectedCategory.value = settings.categories.first;
    }
    ever(settings.categories, (List<String> cats) {
      if (cats.isNotEmpty && !cats.contains(selectedCategory.value)) {
        selectedCategory.value = cats.first;
      }
    });
  }

  void _resetTimer() {
    if (currentState.value == TimerState.idle) {
      remainingSeconds.value = settings.focusMinutes.value * 60;
    }
  }

  void startFocus() {
    if (selectedCategory.value.isEmpty && settings.categories.isNotEmpty) {
      selectedCategory.value = settings.categories.first;
    }
    currentState.value = TimerState.focus;
    isPaused.value = false;
    remainingSeconds.value = settings.focusMinutes.value * 60;
    _startCountdown();
  }

  void startRest() {
    currentState.value = TimerState.rest;
    isPaused.value = false;
    remainingSeconds.value = settings.restMinutes.value * 60;
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        _onTimeFinished();
      }
    });
  }

  void _onTimeFinished() {
    if (currentState.value == TimerState.focus) {
      // Save record
      records.addRecord(settings.focusMinutes.value * 60, selectedCategory.value);
      
      if (currentCycle.value < settings.repeatCount.value) {
        startRest();
      } else {
        stopTimer();
        currentCycle.value = 1;
        Get.snackbar("완료!", "모든 집중 사이클을 완료했습니다! 🎉", snackPosition: SnackPosition.BOTTOM);
      }
    } else if (currentState.value == TimerState.rest) {
      currentCycle.value++;
      startFocus();
    }
  }

  void stopTimer() {
    _timer?.cancel();
    currentState.value = TimerState.idle;
    isPaused.value = false;
    currentCycle.value = 1;
    _resetTimer();
  }
  
  void pauseTimer() {
    if (currentState.value != TimerState.idle && !isPaused.value) {
      isPaused.value = true;
      _timer?.cancel();
    }
  }

  void resumeTimer() {
    if (currentState.value != TimerState.idle && isPaused.value) {
      isPaused.value = false;
      _startCountdown();
    }
  }
  
  void skipRest() {
    if (currentState.value == TimerState.rest) {
      _timer?.cancel();
      currentCycle.value++;
      startFocus();
    }
  }

  void addRestMinute() {
    if (currentState.value == TimerState.rest) {
      remainingSeconds.value += 60;
    }
  }

  String get formattedTime {
    int minutes = remainingSeconds.value ~/ 60;
    int seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
