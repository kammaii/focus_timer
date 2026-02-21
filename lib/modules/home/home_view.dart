import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'home_controller.dart';
import 'widgets/focus_rabbit.dart';
import 'widgets/rest_rabbit.dart';
import 'widgets/night_sky_background.dart';
import '../../core/theme/app_colors.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final mainContent = Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.currentState.value == TimerState.rest ? "휴식 모드" : "집중 모드",
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.nightlight_round),
            onPressed: controller.toggleAmbientModeForTest,
            tooltip: "달빛 모드 테스트",
            color: AppColors.primary,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Category Dropdown
            Obx(() {
              if (controller.settings.categories.isEmpty) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedCategory.value.isNotEmpty &&
                            controller.settings.categories.contains(controller.selectedCategory.value)
                        ? controller.selectedCategory.value
                        : controller.settings.categories.first,
                    items: controller.settings.categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) controller.selectedCategory.value = newValue;
                    },
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.arrow_drop_down, color: AppColors.text, size: 28),
                    ),
                  ),
                ),
              );
            }),
            
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 디바이스별 반응형 크기 계산
                  final availableHeight = constraints.maxHeight;
                  final radius = (availableHeight * 0.2).clamp(100.0, 150.0);
                  final lottieSize = (availableHeight * 0.25).clamp(120.0, 200.0);
                  final iconSize = (availableHeight * 0.2).clamp(50.0, 80.0);
                  final timerFontSize = (availableHeight * 0.08).clamp(36.0, 64.0);
                  final spacing = (availableHeight * 0.04).clamp(10.0, 40.0);

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: availableHeight),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Circle Progress Timer
                            Obx(() => CircularPercentIndicator(
                                  radius: radius,
                                  lineWidth: radius * 0.12,
                                  animation: true,
                                  animateFromLastPercent: true,
                                  animationDuration: 1000,
                                  percent: controller.progress,
                                  circularStrokeCap: CircularStrokeCap.round,
                                  backgroundColor: AppColors.backgroundDark,
                                  progressColor: controller.currentState.value == TimerState.rest
                                      ? AppColors.rest
                                      : AppColors.focus,
                                  center: Center(
                                    child: Text(
                                      controller.formattedTime,
                                      style: TextStyle(
                                        fontSize: timerFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                )),
                            
                            SizedBox(height: spacing),

                            // Lottie Animation
                            Obx(() => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: lottieSize,
                              width: lottieSize,
                              child: controller.currentState.value == TimerState.rest
                                ? const MouthMunchRabbitV5()
                                : const FloppyEarRabbit(),
                            )),
                            
                            SizedBox(height: spacing),
                            
                            // Controls
                            Obx(() {
                              if (controller.currentState.value == TimerState.idle) {
                                return IconButton(
                                  onPressed: controller.startFocus,
                                  icon: const Icon(Icons.play_circle_fill),
                                  iconSize: iconSize,
                                  color: AppColors.primary,
                                );
                              } else if (controller.currentState.value == TimerState.focus) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: controller.isPaused.value ? controller.resumeTimer : controller.pauseTimer,
                                      icon: Icon(controller.isPaused.value ? Icons.play_circle_fill : Icons.pause_circle_filled),
                                      iconSize: iconSize * 0.9,
                                      color: controller.isPaused.value ? AppColors.primary : AppColors.secondary,
                                    ),
                                    const SizedBox(width: 30),
                                    IconButton(
                                      onPressed: controller.stopTimer,
                                      icon: const Icon(Icons.stop_circle),
                                      iconSize: iconSize * 0.9,
                                      color: AppColors.error,
                                    ),
                                  ],
                                );
                              } else {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: controller.addRestMinute,
                                      icon: const Icon(Icons.add),
                                      label: const Text("1분 추가"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    ElevatedButton.icon(
                                      onPressed: controller.skipRest,
                                      icon: const Icon(Icons.skip_next),
                                      label: const Text("휴식 스킵"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.secondary,
                                        foregroundColor: AppColors.text,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            }),
                            
                            SizedBox(height: spacing * 0.5),
                            Obx(() => controller.currentState.value != TimerState.idle 
                              ? Text("현재 ${controller.currentCycle.value} / ${controller.settings.repeatCount.value} 사이클 진행 중",
                                  style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold))
                              : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    return Stack(
      children: [
        Listener(
          onPointerDown: (_) => controller.resetAmbientTimer(),
          behavior: HitTestBehavior.translucent,
          child: mainContent,
        ),
        Obx(() {
          if (controller.isAmbientMode.value) {
            return Positioned.fill(
              child: GestureDetector(
                onTap: controller.resetAmbientTimer,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    // 검은색 배경 베이스
                    Container(color: Colors.black),
                    
                    // 별똥별과 달이 있는 밤하늘 배경 레이어
                    const Positioned.fill(
                      child: NightSkyBackground()
                    ),
                    
                    // 기존 타이머 텍스트와 실루엣 토끼
                    Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.formattedTime,
                              style: const TextStyle(
                                fontSize: 100,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 50),
                            IgnorePointer(
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF222222), BlendMode.srcATop),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 200,
                                  width: 200,
                                  child: controller.currentState.value == TimerState.rest
                                    ? const MouthMunchRabbitV5()
                                    : const FloppyEarRabbit(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
