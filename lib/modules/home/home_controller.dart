import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import '../settings/settings_controller.dart';
import '../records/records_controller.dart';
import 'damagotchi_controller.dart';

enum TimerState { idle, focus, rest }

class HomeController extends GetxController with WidgetsBindingObserver {
  final SettingsController settings;
  final RecordsController records;

  HomeController({required this.settings, required this.records});

  var currentState = TimerState.idle.obs;
  var isPaused = false.obs;
  var remainingSeconds = 0.obs;
  var currentTotalSeconds = 0.obs;
  var selectedCategory = "".obs;
  var currentCycle = 1.obs;
  bool isTestMode = false;
  
  // Ambient Mode
  var isAmbientMode = false.obs;
  Timer? _ambientTimer;

  Timer? _timer;
  
  // Audio Player for simple local sound
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Background tracking
  DateTime? _pausedTime;
  int _pausedRemainingSeconds = 0;

  int get totalSeconds {
    if (currentState.value == TimerState.idle) {
      return settings.focusMinutes.value * 60;
    }
    return currentTotalSeconds.value;
  }

  double get progress {
    if (totalSeconds == 0) return 0.0;
    double p = 1.0 - (remainingSeconds.value / totalSeconds);
    return p.clamp(0.0, 1.0);
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
    currentTotalSeconds.value = settings.focusMinutes.value * 60;
    remainingSeconds.value = currentTotalSeconds.value;
    _startCountdown();
    resetAmbientTimer();
  }

  void startRest() {
    currentState.value = TimerState.rest;
    isPaused.value = false;
    currentTotalSeconds.value = isTestMode ? 5 : settings.restMinutes.value * 60;
    remainingSeconds.value = currentTotalSeconds.value;
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

  void _playSound(String soundType, TimerState state) async {
    if (soundType == 'silent') return;
    String filename = soundType;
    if (filename == 'default' || filename == 'focus_end.wav') {
      filename = state == TimerState.focus ? 'ding_ding.mp3' : 'ding_ring.mp3';
    } else if (filename == 'rest_end.wav') {
      filename = 'ding_ring.mp3';
    }
    
    try {
      await _audioPlayer.play(AssetSource('sounds/$filename'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  void _onTimeFinished() async {
    final finishedState = currentState.value;
    if (finishedState == TimerState.focus) {
      // Save record
      records.addRecord(settings.focusMinutes.value * 60, selectedCategory.value);
      
      _playSound(settings.focusEndSound.value, finishedState);

      // Damagotchi 다이얼로그 띄우고 보상 기다리기 (타이머는 일시정지 상태처럼 대기)
      final damagotchiController = Get.find<DamagotchiController>();
      int baseExp = isTestMode ? 60 : settings.focusMinutes.value;
      int finalExp = await damagotchiController.showExpProgressAndGetReward(baseExp);
      
      // 실제 반영
      await damagotchiController.gainExpAfterReward(finalExp);
      
      if (currentCycle.value < (isTestMode ? 2 : settings.repeatCount.value)) {
        startRest();
      } else {
        stopTimer();
        currentCycle.value = 1;
        Get.snackbar("완료!", "모든 집중 사이클을 완료했습니다! 🎉", snackPosition: SnackPosition.BOTTOM);
      }
    } else if (finishedState == TimerState.rest) {
      _playSound(settings.restEndSound.value, finishedState);
      currentCycle.value++;
      startFocus();
    }
    resetAmbientTimer();
  }

  void stopTimer() {
    _timer?.cancel();
    _audioPlayer.stop();
    currentState.value = TimerState.idle;
    isTestMode = false;
    isPaused.value = false;
    currentTotalSeconds.value = 0;
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
      _audioPlayer.stop();
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
      _audioPlayer.stop();
      currentCycle.value++;
      startFocus();
    }
  }

  void addRestMinute() {
    if (currentState.value == TimerState.rest) {
      remainingSeconds.value += 60;
      currentTotalSeconds.value += 60;
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

  void startQuickTest() {
    isTestMode = true;
    if (selectedCategory.value.isEmpty && settings.categories.isNotEmpty) {
      selectedCategory.value = settings.categories.first;
    }
    currentState.value = TimerState.focus;
    isPaused.value = false;
    currentCycle.value = 1;
    currentTotalSeconds.value = 5;
    remainingSeconds.value = 5;
    _startCountdown();
    resetAmbientTimer();
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
    _audioPlayer.dispose();
    WakelockPlus.disable();
    super.onClose();
  }
}
