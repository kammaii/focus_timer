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
  var activeCompanionId = RxnString(null);

  Animal? get activeAnimal {
    if (activeCompanionId.value != null) {
      return collection.firstWhereOrNull((a) => a.id == activeCompanionId.value);
    }
    return currentAnimal.value;
  }

  bool get isCompanionMode => activeCompanionId.value != null;

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
    activeCompanionId.value = data.activeCompanionId;
  }

  Future<void> saveData() async {
    damagotchiData.value.currentAnimal = currentAnimal.value;
    damagotchiData.value.collection = collection.toList();
    damagotchiData.value.activeCompanionId = activeCompanionId.value;
    await storageProvider.saveDamagotchiData(damagotchiData.value);
  }

  Future<void> setCompanion(Animal animal) async {
    activeCompanionId.value = animal.id;
    await saveData();
  }

  Future<void> clearCompanion() async {
    activeCompanionId.value = null;
    await saveData();
  }

  // 다이얼로그를 띄우고 보상을 받은 후의 총 경험치를 반환하는 함수
  Future<int> showExpProgressAndGetReward(int baseMinutes) async {
    if (activeAnimal == null) return baseMinutes;

    final completer = Completer<int>();

    Get.dialog(
      ExpProgressDialog(
        animal: activeAnimal!,
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
    if (activeAnimal == null) return;
    
    Animal animal = activeAnimal!;
    
    // 컴패니언 모드인 경우
    if (isCompanionMode) {
      animal.addExp(totalMinutes);
      // collection 내부의 해당 동물이 업데이트되도록 refresh
      collection.refresh();
      await saveData();
      return; // 컴패니언은 레벨업이나 알 획득 로직을 건너뜀
    }

    // 알 키우기 모드인 경우
    AnimalLevel previousLevel = animal.level;
    bool wasReadyToCollect = animal.isReadyToCollect;
    
    animal.addExp(totalMinutes);
    currentAnimal.refresh(); // UI 업데이트
    await saveData();

    AnimalLevel currentLevel = animal.level;
    bool isReadyToCollect = animal.isReadyToCollect;
    
    // 레벨업 체크 (부화)
    if (previousLevel != currentLevel) {
      _showLevelUpAnimation(animal, previousLevel, currentLevel);
    }
      
    // 수집 기준 도달 체크
    if (!wasReadyToCollect && isReadyToCollect) {
      // 레벨업 축하창 같은 애니메이션 후 띄우기 위해 약간의 딜레이
      Future.delayed(const Duration(seconds: 3), () {
        _showNewEggSelection();
      });
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
      // 기존 동물을 컬렉션에 추가 (수집 가능한 경우만)
      if (currentAnimal.value!.isReadyToCollect) {
        collection.add(currentAnimal.value!);
      }
    }
    
    // 새 알 획득
    currentAnimal.value = Animal(type: type, grade: grade);
    await saveData();
  }
}
