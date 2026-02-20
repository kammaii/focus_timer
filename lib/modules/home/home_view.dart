import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'home_controller.dart';
import '../../core/theme/app_colors.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.currentState.value == TimerState.rest ? "휴식 모드" : "집중 모드",
        )),
        actions: [
          if (controller.settings.categories.isNotEmpty)
            Obx(() => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedCategory.value.isNotEmpty &&
                        controller.settings.categories.contains(controller.selectedCategory.value)
                    ? controller.selectedCategory.value
                    : controller.settings.categories.first,
                items: controller.settings.categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) controller.selectedCategory.value = newValue;
                },
                icon: const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.arrow_drop_down, color: AppColors.text),
                ),
              ),
            )),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation Container
              Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.currentState.value == TimerState.rest
                      ? AppColors.rest
                      : AppColors.focus,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: LottieBuilder.network(
                    controller.currentState.value == TimerState.rest
                     ? 'https://assets2.lottiefiles.com/packages/lf20_syqnfe7c.json' // 임시 휴식 애니메이션 (고양이 잠)
                     : 'https://assets5.lottiefiles.com/packages/lf20_w51pcehl.json', // 임시 공부 애니메이션 (타이핑)
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.pets, size: 80, color: Colors.white),
                  ),
                ),
              )),
              
              const SizedBox(height: 40),
              
              // Timer Text
              Obx(() => Text(
                controller.formattedTime,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              )),
              
              const SizedBox(height: 10),
              
              // Controls
              Obx(() {
                if (controller.currentState.value == TimerState.idle) {
                  return ElevatedButton.icon(
                    onPressed: controller.startFocus,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("집중 시작"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  );
                } else if (controller.currentState.value == TimerState.focus) {
                  return ElevatedButton.icon(
                    onPressed: controller.stopTimer,
                    icon: const Icon(Icons.stop),
                    label: const Text("포기하기"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: controller.skipRest,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.text),
                        child: const Text("휴식 종료"),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: controller.addRestMinute,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text("+1분 연장"),
                      ),
                    ],
                  );
                }
              }),
              
              const SizedBox(height: 20),
              Obx(() => controller.currentState.value != TimerState.idle 
                ? Text("현재 ${controller.currentCycle.value} / ${controller.settings.repeatCount.value} 사이클 진행 중",
                    style: const TextStyle(color: AppColors.textLight))
                : const SizedBox.shrink()
              ),
            ],
          ),
        ),
      ),
    );
  }
}
