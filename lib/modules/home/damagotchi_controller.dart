import 'dart:async';

import 'package:get/get.dart';
import '../../data/models/animal.dart';
import '../../data/models/damagotchi_data.dart';
import '../../data/providers/local_storage_provider.dart';
import 'widgets/level_up_dialog.dart';
import 'widgets/new_egg_dialog.dart';
import 'widgets/exp_progress_dialog.dart';

class DamagotchiController extends GetxController {
  final LocalStorageProvider storageProvider;

  DamagotchiController({required this.storageProvider});

  var damagotchiData = DamagotchiData().obs;
  
  // 상태 변수
  var currentAnimal = Rxn<Animal>();
  var collection = <Animal>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    final data = await storageProvider.loadDamagotchiData();
    
    // 현재 보유 중인 알이 없다면 새로운 일반 알을 하나 지급 (초기 실행 시)
    if (data.currentAnimal == null) {
      data.currentAnimal = Animal(type: AnimalType.rabbit, grade: AnimalGrade.normal);
      await storageProvider.saveDamagotchiData(data);
    }

    damagotchiData.value = data;
    currentAnimal.value = data.currentAnimal;
    collection.value = data.collection;
  }

  Future<void> saveData() async {
    damagotchiData.value.currentAnimal = currentAnimal.value;
    damagotchiData.value.collection = collection.toList();
    await storageProvider.saveDamagotchiData(damagotchiData.value);
  }

  // 다이얼로그를 띄우고 보상을 받은 후의 총 경험치를 반환하는 함수
  Future<int> showExpProgressAndGetReward(int baseMinutes) async {
    if (currentAnimal.value == null) return baseMinutes;

    final completer = Completer<int>();

    Get.dialog(
      ExpProgressDialog(
        animal: currentAnimal.value!,
        baseExp: baseMinutes,
        onRewardClaimed: (totalExp) {
          completer.complete(totalExp);
        },
      ),
      barrierDismissible: false,
    );

    return completer.future;
  }

  Future<void> gainExpAfterReward(int totalMinutes) async {
    if (currentAnimal.value == null) return;
    
    Animal animal = currentAnimal.value!;
    AnimalLevel previousLevel = animal.level;
    
    animal.addExp(totalMinutes);
    currentAnimal.refresh(); // UI 업데이트
    await saveData();

    AnimalLevel currentLevel = animal.level;
    
    // 레벨업 체크
    if (previousLevel != currentLevel) {
      _showLevelUpAnimation(animal, previousLevel, currentLevel);
      
      // 어른이 되었다면 알 선택 창을 띄우거나 처리
      if (currentLevel == AnimalLevel.adult) {
        // 부화 애니메이션 후 띄우기 위해 약간의 딜레이
        Future.delayed(const Duration(seconds: 3), () {
          _showNewEggSelection();
        });
      }
    }
  }
  
  void _showLevelUpAnimation(Animal animal, AnimalLevel prev, AnimalLevel curr) {
    Get.to(
      () => LevelUpDialog(animal: animal, previousLevel: prev, currentLevel: curr),
      fullscreenDialog: true,
      transition: Transition.fadeIn,
    );
  }

  void _showNewEggSelection() {
    Get.dialog(const NewEggDialog(), barrierDismissible: false);
  }

  Future<void> acquireNewEgg(AnimalType type, AnimalGrade grade) async {
    if (currentAnimal.value != null) {
      // 기존 동물을 컬렉션에 추가 (어른인 경우만)
      if (currentAnimal.value!.isAdult) {
        collection.add(currentAnimal.value!);
      }
    }
    
    // 새 알 획득
    currentAnimal.value = Animal(type: type, grade: grade);
    await saveData();
  }
}
