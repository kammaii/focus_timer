import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/animal.dart';
import '../damagotchi_controller.dart';
import '../../../core/services/ad_service.dart';
import 'dart:math';

class NewEggDialog extends StatelessWidget {
  const NewEggDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DamagotchiController>();
    final collection = controller.collection;
    final specialTypes = [
      AnimalType.dog,
      AnimalType.turtle,
      AnimalType.tiger,
      AnimalType.lion,
      AnimalType.bear,
      AnimalType.dinosaur,
    ];
    final uncollectedSpecialTypes = specialTypes.where((type) {
      final inCollection = collection.any((animal) => animal.type == type);
      final isCurrent = controller.currentAnimal.value?.type == type;
      return !inCollection && !isCurrent;
    }).toList();
    final allSpecialCollected = uncollectedSpecialTypes.isEmpty;

    final normalTypes = [
      AnimalType.rabbit,
      AnimalType.cat,
      AnimalType.squirrel,
      AnimalType.hedgehog,
    ];
    final uncollectedNormalTypes = normalTypes.where((type) {
      final inCollection = collection.any((animal) => animal.type == type);
      final isCurrent = controller.currentAnimal.value?.type == type;
      return !inCollection && !isCurrent;
    }).toList();
    final allNormalCollected = uncollectedNormalTypes.isEmpty;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.eco, color: Colors.lightGreen, size: 28),
                    const SizedBox(width: 8),
                    const Text("새로운 여정", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text("집중할 알을 선택하고 어떤 친구가\n태어날지 확인해보세요!", 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13)
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildEggCard(
                        context: context,
                        title: "일반 알",
                        subtitle: "일반 친구들",
                        eggIcon: Icons.egg,
                        eggColor: Colors.blueGrey.shade200,
                        buttonLabel: allNormalCollected ? "수집 완료" : "일반 부화",
                        buttonIcon: Icons.ad_units,
                        buttonColor: Colors.grey.shade100,
                        buttonTextColor: Colors.black,
                        isDisabled: allNormalCollected,
                        onTap: () => _selectEgg(AnimalGrade.normal),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildEggCard(
                        context: context,
                        title: "스페셜 알",
                        subtitle: "희귀 & 전설",
                        eggIcon: Icons.egg,
                        eggColor: Colors.amber,
                        badgeIcon: Icons.star,
                        buttonLabel: allSpecialCollected ? "수집 완료" : "무료로 받기",
                        buttonIcon: Icons.card_giftcard,
                        buttonColor: Colors.greenAccent.shade400,
                        buttonTextColor: Colors.white,
                        borderColor: Colors.greenAccent.shade100,
                        isDisabled: allSpecialCollected,
                        onTap: () => _selectEgg(AnimalGrade.special),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.timer, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text("새로운 동물친구를 부화시키기 위해 집중하세요! 일반알은 1시간의 집중이 필요합니다.", 
                          style: TextStyle(color: Colors.green, fontSize: 11)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEggCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData eggIcon,
    required Color eggColor,
    IconData? badgeIcon,
    required String buttonLabel,
    required IconData buttonIcon,
    required Color buttonColor,
    required Color buttonTextColor,
    Color? borderColor,
    bool isDisabled = false,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor ?? Colors.grey.shade200, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: eggColor.withOpacity(0.2),
                      shape: BoxShape.circle, 
                    ),
                  ),
                  Icon(eggIcon, size: 60, color: eggColor),
                  if (badgeIcon != null)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                        ),
                        child: Icon(badgeIcon, size: 16, color: Colors.orange),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 36,
          child: ElevatedButton.icon(
            onPressed: isDisabled ? null : onTap,
            icon: Icon(buttonIcon, size: 14, color: buttonTextColor),
            label: Text(buttonLabel, style: TextStyle(color: buttonTextColor, fontWeight: FontWeight.bold, fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled ? Colors.grey.shade300 : buttonColor,
              disabledBackgroundColor: Colors.grey.shade300,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  void _selectEgg(AnimalGrade grade) async {
    await AdService().showRewardedAd(onRewardEarned: () async {
      final controller = Get.find<DamagotchiController>();
      
      // 랜덤으로 동물 종류 선택
      final random = Random();
      AnimalType selectedType;
      
      if (grade == AnimalGrade.normal) {
        final normalTypes = [
          AnimalType.rabbit,
          AnimalType.cat,
          AnimalType.squirrel,
          AnimalType.hedgehog,
        ];
        final uncollectedNormalTypes = normalTypes.where((type) {
          final inCollection = controller.collection.any((animal) => animal.type == type);
          final isCurrent = controller.currentAnimal.value?.type == type;
          return !inCollection && !isCurrent;
        }).toList();
        if (uncollectedNormalTypes.isEmpty) {
          Get.snackbar("알림", "모든 일반 동물을 수집했습니다.");
          return;
        }
        selectedType = uncollectedNormalTypes[random.nextInt(uncollectedNormalTypes.length)];
      } else {
        final specialTypes = [
          AnimalType.dog,
          AnimalType.turtle,
          AnimalType.tiger,
          AnimalType.lion,
          AnimalType.bear,
          AnimalType.dinosaur,
        ];
        final uncollectedSpecialTypes = specialTypes.where((type) {
          final inCollection = controller.collection.any((animal) => animal.type == type);
          final isCurrent = controller.currentAnimal.value?.type == type;
          return !inCollection && !isCurrent;
        }).toList();
        if (uncollectedSpecialTypes.isEmpty) {
          Get.snackbar("알림", "모든 스페셜 동물을 수집했습니다.");
          return;
        }
        selectedType = uncollectedSpecialTypes[random.nextInt(uncollectedSpecialTypes.length)];
      }
      
      await controller.acquireNewEgg(selectedType, grade);
      
      Get.back(); // 닫기
      Get.snackbar("새 알 획득!", "새로운 알을 얻었습니다. 열심히 집중해서 키워보세요!", snackPosition: SnackPosition.TOP);
    });
  }
}
