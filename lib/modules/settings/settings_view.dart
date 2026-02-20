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
                   _buildSlider("집중 시간 (분)", controller.focusMinutes, 5, 60, divisions: 11),
                   _buildSlider("휴식 시간 (분)", controller.restMinutes, 5, 30, divisions: 5),
                   _buildSlider("반복 횟수 (사이클)", controller.repeatCount, 1, 10, divisions: 9),
                   
                   const SizedBox(height: 16),
                   Obx(() => SwitchListTile(
                     title: const Text("달빛 모드", style: TextStyle(fontWeight: FontWeight.bold)),
                     subtitle: const Text("항상 켜져 있으며 1분간 터치가 없으면 어두운 화면으로 전환됩니다."),
                     value: controller.ambientModeEnabled.value,
                     onChanged: (val) {
                       controller.ambientModeEnabled.value = val;
                       controller.saveSilently();
                     },
                     activeThumbColor: AppColors.primary,
                     contentPadding: EdgeInsets.zero,
                   )),
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

  Widget _buildSlider(String label, RxInt rxValue, double min, double max, {int? divisions}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text("$label: ${rxValue.value}")),
        Obx(() => Slider(
          value: rxValue.value.toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withOpacity(0.3),
          onChanged: (val) {
            rxValue.value = val.toInt();
            controller.saveSilently();
          },
        )),
      ],
    );
  }
}
