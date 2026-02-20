import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import '../../core/theme/app_colors.dart';

class SettingsView extends GetView<SettingsController> {
  SettingsView({super.key});

  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text("타이머 설정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 16),
                   _buildSlider("집중 시간 (분)", controller.focusMinutes, 5, 120),
                   _buildSlider("휴식 시간 (분)", controller.restMinutes, 1, 30),
                   _buildSlider("반복 횟수 (사이클)", controller.repeatCount, 1, 10),
                   
                   const SizedBox(height: 16),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: () {
                         int f = controller.focusMinutes.value;
                         int r = controller.restMinutes.value;
                         int c = controller.repeatCount.value;
                         controller.saveSettings(f, r, c);
                       },
                       child: const Text("설정 저장"),
                     ),
                   )
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("카테고리 관리", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Obx(() => Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: controller.categories.map((category) => Chip(
                      label: Text(category),
                      backgroundColor: AppColors.secondary,
                      onDeleted: () => controller.removeCategory(category),
                    )).toList(),
                  )),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: '새 카테고리 추가...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onSubmitted: (value) {
                            if(value.trim().isNotEmpty) {
                              controller.addCategory(value.trim());
                              _textController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, RxInt rxValue, double min, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text("$label: ${rxValue.value}")),
        Obx(() => Slider(
          value: rxValue.value.toDouble(),
          min: min,
          max: max,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withOpacity(0.3),
          onChanged: (val) => rxValue.value = val.toInt(),
        )),
      ],
    );
  }
}
