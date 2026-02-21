import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../settings/settings_controller.dart';
import '../records/records_controller.dart';

enum TimerState { idle, focus, rest }

class HomeController extends GetxController with WidgetsBindingObserver {
  final SettingsController settings;
  final RecordsController records;

  HomeController({required this.settings, required this.records});

  var currentState = TimerState.idle.obs;
  var isPaused = false.obs;
  var remainingSeconds = 0.obs;
  var selectedCategory = "".obs;
  var currentCycle = 1.obs;
  
  // Ambient Mode
  var isAmbientMode = false.obs;
  Timer? _ambientTimer;

  Timer? _timer;
  
  // Background tracking
  DateTime? _pausedTime;
  int _pausedRemainingSeconds = 0;

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
    WidgetsBinding.instance.addObserver(this);
    
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

    ever(settings.ambientModeEnabled, (bool enabled) {
      if (!enabled) {
        isAmbientMode.value = false;
        _ambientTimer?.cancel();
        WakelockPlus.disable();
      } else if (currentState.value != TimerState.idle && !isPaused.value) {
        resetAmbientTimer();
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
    resetAmbientTimer();
  }

  void startRest() {
    currentState.value = TimerState.rest;
    isPaused.value = false;
    remainingSeconds.value = settings.restMinutes.value * 60;
    _startCountdown();
    resetAmbientTimer();
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
    resetAmbientTimer();
  }

  void stopTimer() {
    _timer?.cancel();
    currentState.value = TimerState.idle;
    isPaused.value = false;
    currentCycle.value = 1;
    _resetTimer();
    isAmbientMode.value = false;
    _ambientTimer?.cancel();
    WakelockPlus.disable();
  }
  
  void pauseTimer() {
    if (currentState.value != TimerState.idle && !isPaused.value) {
      isPaused.value = true;
      _timer?.cancel();
      isAmbientMode.value = false;
      _ambientTimer?.cancel();
      WakelockPlus.disable();
    }
  }

  void resumeTimer() {
    if (currentState.value != TimerState.idle && isPaused.value) {
      isPaused.value = false;
      _startCountdown();
      resetAmbientTimer();
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
      resetAmbientTimer();
    }
  }

  void resetAmbientTimer() {
    isAmbientMode.value = false;
    _ambientTimer?.cancel();
    
    if (settings.ambientModeEnabled.value && currentState.value != TimerState.idle && !isPaused.value) {
      WakelockPlus.enable();
      _ambientTimer = Timer(const Duration(minutes: 1), () {
        isAmbientMode.value = true;
      });
    } else {
      WakelockPlus.disable();
    }
  }

  void toggleAmbientModeForTest() {
    isAmbientMode.value = !isAmbientMode.value;
  }

  String get formattedTime {
    int minutes = remainingSeconds.value ~/ 60;
    int seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pausedTime = DateTime.now();
      _pausedRemainingSeconds = remainingSeconds.value;
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedTime != null && currentState.value != TimerState.idle && !isPaused.value) {
        final elapsed = DateTime.now().difference(_pausedTime!).inSeconds;
        int newRemaining = _pausedRemainingSeconds - elapsed;
        if (newRemaining <= 0) {
          remainingSeconds.value = 0;
          _timer?.cancel();
          _onTimeFinished();
        } else {
          remainingSeconds.value = newRemaining;
        }
      }
      _pausedTime = null;
      if (currentState.value != TimerState.idle && !isPaused.value) {
        resetAmbientTimer();
      }
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _ambientTimer?.cancel();
    WakelockPlus.disable();
    super.onClose();
  }
}
