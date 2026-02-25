import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/animal.dart';
import '../home/damagotchi_controller.dart';
import '../home/widgets/animal_view.dart';
import '../home/home_controller.dart';
import '../../core/theme/app_colors.dart';

class CollectionView extends GetView<DamagotchiController> {
  const CollectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("나의 동물 도감", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Obx(() {
          final collection = controller.collection;
          final totalTypes = AnimalType.values.length;
          
          // 동물 타입별로 컬렉션에 이미 있는지 여부 계산
          final collectedCount = AnimalType.values.where((type) {
            return collection.any((animal) => animal.type == type);
          }).length;
          
          return Column(
            children: [
              // 진행률 표시 바
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("도감 완성도", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("$collectedCount / $totalTypes", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: totalTypes == 0 ? 0 : collectedCount / totalTypes,
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 도감 그리드
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: AnimalType.values.length,
                  itemBuilder: (context, index) {
                    final type = AnimalType.values[index];
                    final isCollected = collection.any((animal) => animal.type == type);
                    
                    // 스페셜 알인지 확인
                    final isSpecial = [AnimalType.bear, AnimalType.tiger, AnimalType.elephant, AnimalType.dinosaur].contains(type);

                    // 보여줄 임시 동물 모델
                    final animalModel = Animal(type: type, grade: isSpecial ? AnimalGrade.special : AnimalGrade.normal, currentExpMinutes: 1200);

                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Stack(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: isCollected
                                ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AnimalView(animal: animalModel, state: TimerState.idle),
                                    // 약간의 애니메이션을 위해 투명색으로 감싸줌
                                    Container(color: Colors.transparent),
                                  ],
                                )
                                // 실루엣 표시 (ColorFiltered 사용)
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.matrix([
                                      0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0,
                                      0, 0, 0, 0.4, 0, // 알파값을 조절하여 그림자처럼 표시
                                    ]),
                                    child: AnimalView(animal: animalModel, state: TimerState.idle),
                                  ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Text(
                              isCollected ? _getAnimalName(type) : "???",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          if (isSpecial)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text("스페셜", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _getAnimalName(AnimalType type) {
    switch (type) {
      case AnimalType.rabbit: return "토끼";
      case AnimalType.squirrel: return "다람쥐";
      case AnimalType.bird: return "작은 새";
      case AnimalType.bear: return "곰";
      case AnimalType.tiger: return "호랑이";
      case AnimalType.elephant: return "코끼리";
      case AnimalType.dinosaur: return "공룡";
      case AnimalType.dog: return "강아지";

    }
  }
}
