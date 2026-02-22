import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/notification_service.dart';

class SettingsView extends GetView<SettingsController> {
  SettingsView({super.key});

  final TextEditingController _textController = TextEditingController();

  final List<String> soundOptions = ['default', 'silent'];
  final Map<String, String> soundLabels = {
    'default': '기본 푸시 알림음',
    'silent': '무음 (진동/화면표시만)',
  };

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
                   
                   const SizedBox(height: 16),
                   const Text("알림음 설정", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   _buildSoundDropdown("집중 완료 시", controller.focusEndSound),
                   _buildSoundDropdown("휴식 완료 시", controller.restEndSound),
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

  Widget _buildSoundDropdown(String label, RxString rxValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight)),
        const SizedBox(height: 8),
        Obx(() {
          final List<DropdownMenuItem<String>> items = [];
          
          for (var opt in soundOptions) {
            items.add(DropdownMenuItem(value: opt, child: Text(soundLabels[opt]!)));
          }

          String currentValue = rxValue.value;
          if (!items.any((item) => item.value == currentValue)) {
            currentValue = 'default';
          }
          
          return DropdownButtonFormField<String>(
            value: currentValue,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(), 
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)
            ),
            items: items,
            onChanged: (val) {
              if (val != null) {
                rxValue.value = val;
                controller.saveSilently();
                _playTestSound(val);
              }
            },
          );
        }),
      ]
    );
  }
  
  void _playTestSound(String type) {
    if (type == 'silent') return;
    NotificationService().showImmediateNotification(
      999, // test id
      "알림음 테스트",
      "이 소리로 알림이 울립니다.",
      type,
    );
  }
}
