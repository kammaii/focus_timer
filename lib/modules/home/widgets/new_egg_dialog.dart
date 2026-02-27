import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/animal.dart';
import '../damagotchi_controller.dart';
import 'dart:math';

class NewEggDialog extends StatelessWidget {
  const NewEggDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("새로운 알 선택", style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text("어떤 알을 부화시킬까요?\n(현재는 테스트 모드로 즉시 획득합니다)"),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.egg, color: Colors.brown, size: 50),
              onPressed: () {
                _selectEgg(AnimalGrade.normal);
              },
            ),
            const Text("일반알\n(광고 시청)", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.egg, color: Colors.amber, size: 50),
              onPressed: () {
                _selectEgg(AnimalGrade.special);
              },
            ),
            const Text("스페셜알\n(인앱 결제)", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  void _selectEgg(AnimalGrade grade) async {
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
      selectedType = normalTypes[random.nextInt(normalTypes.length)];
    } else {
      final specialTypes = [
        AnimalType.dog,
        AnimalType.turtle,
        AnimalType.tiger,
        AnimalType.lion,
        AnimalType.bear,
        AnimalType.dinosaur,
      ];
      selectedType = specialTypes[random.nextInt(specialTypes.length)];
    }
    
    await controller.acquireNewEgg(selectedType, grade);
    
    Get.back(); // 닫기
    Get.snackbar("새 알 획득!", "새로운 알을 얻었습니다. 열심히 집중해서 키워보세요!", snackPosition: SnackPosition.TOP);
  }
}
