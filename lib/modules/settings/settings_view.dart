import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import '../../core/theme/app_colors.dart';

class SettingsView extends GetView<SettingsController> {
  SettingsView({super.key});

  final TextEditingController _textController = TextEditingController();

  final List<String> soundOptions = [
    'ding_ding.mp3',
    'ding_ring.mp3',
    'yeah.mp3',
    'tada.mp3',
    'ba_bam.wav',
    'ba_ba_bam.wav',
    'chwarara.wav',
    'silent',
  ];
  final Map<String, String> soundLabels = {
    'ding_ding.mp3': '띠딩',
    'ding_ring.mp3': '띠링',
    'yeah.mp3': '예~',
    'tada.mp3': '따단!',
    'ba_bam.wav': '빠밤',
    'ba_ba_bam.wav': '빠바밤',
    'chwarara.wav': '촤라라',
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
                  const Text(
                    "타이머 설정",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSlider(
                    "집중 시간 (분)",
                    controller.focusMinutes,
                    5,
                    60,
                    divisions: 11,
                  ),
                  _buildSlider(
                    "휴식 시간 (분)",
                    controller.restMinutes,
                    5,
                    30,
                    divisions: 5,
                  ),
                  _buildSlider(
                    "반복 횟수 (사이클)",
                    controller.repeatCount,
                    1,
                    10,
                    divisions: 9,
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "알림음 설정",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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
                  const Text(
                    "카테고리 관리",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: controller.categories
                          .map(
                            (category) => Chip(
                              label: Text(category),
                              backgroundColor: AppColors.secondary,
                              onDeleted: () =>
                                  controller.removeCategory(category),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: '새 카테고리 추가...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              controller.addCategory(value.trim());
                              _textController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 관리자 모드 표시 (활성화된 경우만)
          Obx(() {
            if (!controller.isAdminMode.value) return const SizedBox.shrink();
            return Center(
              child: TextButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text("일반 모드로 전환"),
                      content: const Text("관리자 모드를 해제하고 일반 모드(광고 노출)로 전환하시겠습니까?"),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("취소"),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            controller.resetAdminMode();
                          },
                          child: const Text(
                            "전환",
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  "관리자 모드 활성 (탭하여 해제)",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    RxInt rxValue,
    double min,
    double max, {
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text("$label: ${rxValue.value}")),
        Obx(
          () => Slider(
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
          ),
        ),
      ],
    );
  }

  Widget _buildSoundDropdown(String label, RxString rxValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final List<DropdownMenuItem<String>> items = [];

          for (var opt in soundOptions) {
            items.add(
              DropdownMenuItem(value: opt, child: Text(soundLabels[opt]!)),
            );
          }

          String currentValue = rxValue.value;
          if (!items.any((item) => item.value == currentValue)) {
            currentValue = 'ding_ding.mp3';
          }

          return DropdownButtonFormField<String>(
            value: currentValue,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: items,
            onChanged: (val) {
              if (val != null) {
                rxValue.value = val;
                controller.saveSilently();
                controller.playTestSound(val);
              }
            },
          );
        }),
      ],
    );
  }
}
