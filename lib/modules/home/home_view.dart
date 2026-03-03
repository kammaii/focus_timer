import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../data/models/animal.dart';
import 'home_controller.dart';
import 'damagotchi_controller.dart';
import 'widgets/animal_view.dart';
import 'widgets/night_sky_background.dart';
import 'widgets/new_egg_dialog.dart';
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
          Obx(() {
            if (controller.currentState.value == TimerState.idle) {
              return IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Get.toNamed('/settings'),
                tooltip: "설정",
                color: AppColors.textLight,
              );
            }
            return const SizedBox.shrink();
          }),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  // 디바이스별 반응형 크기 계산 (공간을 좀 더 넓게 쓰도록 조정)
                  final availableHeight = constraints.maxHeight;
                  final radius = (availableHeight * 0.18).clamp(90.0, 140.0);
                  final lottieSize = (availableHeight * 0.22).clamp(110.0, 180.0);
                  final iconSize = (availableHeight * 0.15).clamp(60.0, 80.0);
                  final timerFontSize = (availableHeight * 0.08).clamp(36.0, 56.0);
                  final spacing = (availableHeight * 0.05).clamp(20.0, 50.0);

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: availableHeight),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

                            // Damagotchi Animal View
                            Obx(() {
                              final damagotchiController = Get.find<DamagotchiController>();
                              final animal = damagotchiController.activeAnimal;
                              
                              if (animal == null) return const SizedBox.shrink();

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: lottieSize,
                                    width: lottieSize,
                                    child: AnimalView(
                                      animal: animal,
                                      state: controller.currentState.value,
                                    ),
                                  ),
                                  if (animal.level != AnimalLevel.egg) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      animal.name,
                                      style: TextStyle(
                                        fontSize: (availableHeight * 0.03).clamp(16.0, 24.0),
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                    if (animal.isReadyToCollect && !damagotchiController.isCompanionMode) ...[
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Get.dialog(const NewEggDialog(), barrierDismissible: false);
                                        },
                                        icon: const Icon(Icons.egg, size: 18),
                                        label: const Text("새 알 받기"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                      ),
                                    ],
                                  ],
                                  if (damagotchiController.isCompanionMode) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.favorite, size: 14, color: AppColors.primary),
                                          const SizedBox(width: 4),
                                          const Text("동반 모드", style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () {
                                              damagotchiController.clearCompanion();
                                              Get.snackbar("알림", "알 키우기로 복귀했습니다.");
                                            },
                                            child: const Icon(Icons.cancel, size: 16, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }),
                            
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
                                      onPressed: () {
                                        Get.dialog(
                                          AlertDialog(
                                            title: const Text("타이머 종료", style: TextStyle(fontWeight: FontWeight.bold)),
                                            content: const Text("정말 진행 중인 타이머를 종료하시겠습니까?\n현재 집중 기록은 저장되지 않습니다."),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Get.back(),
                                                child: const Text("취소", style: TextStyle(color: AppColors.textLight)),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Get.back();
                                                  controller.stopTimer();
                                                },
                                                child: const Text("종료", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                          )
                                        );
                                      },
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
                                child: Obx(() {
                                  final damagotchiController = Get.find<DamagotchiController>();
                                  final animal = damagotchiController.activeAnimal;
                                  if (animal == null) return const SizedBox.shrink();

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        height: 200,
                                        width: 200,
                                        child: AnimalView(
                                          animal: animal,
                                          state: controller.currentState.value,
                                        ),
                                      ),
                                      if (animal.level != AnimalLevel.egg) ...[
                                        const SizedBox(height: 10),
                                        Text(
                                          animal.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white54,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                }),
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
