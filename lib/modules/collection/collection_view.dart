import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../data/models/animal.dart';
import '../home/damagotchi_controller.dart';
import '../home/widgets/animal_view.dart';
import '../home/home_controller.dart';
import '../home/widgets/animals/animal_registry.dart';
import '../../core/theme/app_colors.dart';

class CollectionView extends GetView<DamagotchiController> {
  CollectionView({super.key});

  final ScreenshotController _screenshotController = ScreenshotController();

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
                    Animal? collectedAnimal;
                    if (isCollected) {
                      collectedAnimal = collection.firstWhere((animal) => animal.type == type);
                    }
                    
                    // 스페셜 알인지 확인
                    final isSpecial = AnimalRegistry.getGrade(type) == AnimalGrade.special;

                    // 보여줄 임시 동물 모델
                    final animalModel = collectedAnimal ?? Animal(type: type, grade: isSpecial ? AnimalGrade.special : AnimalGrade.normal, currentExpMinutes: 1200);

                    return GestureDetector(
                      onTap: isCollected ? () => _showAnimalDetails(context, collectedAnimal!) : null,
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: isCollected
                                    ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Transform.scale(
                                          scale: 0.65,
                                          child: AnimalView(animal: animalModel, state: TimerState.idle),
                                        ),
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
                                        child: Transform.scale(
                                          scale: 0.65,
                                          child: AnimalView(animal: animalModel, state: TimerState.idle),
                                        ),
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
                              // Card XP Progress Bar at the top (Moved to last to be on top)
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: LinearProgressIndicator(
                                  value: isCollected ? animalModel.currentLevelProgress : 0,
                                  minHeight: 6,
                                  backgroundColor: Colors.black.withOpacity(0.05),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isCollected ? AppColors.primary : Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          ),                    )));
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
      case AnimalType.dog: return "강아지";
      case AnimalType.cat: return "고양이";
      case AnimalType.hedgehog: return "고슴도치";
      case AnimalType.squirrel: return "다람쥐";
      case AnimalType.bear: return "곰";
      case AnimalType.dinosaur: return "공룡";
      case AnimalType.lion: return "사자";
      case AnimalType.tiger: return "호랑이";
      case AnimalType.turtle: return "거북이";
    }
  }

  void _showAnimalDetails(BuildContext context, Animal animal) {
    final hours = animal.currentExpMinutes ~/ 60;
    final minutes = animal.currentExpMinutes % 60;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "나의 ${animal.name}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 150,
                child: Transform.scale(
                  scale: 0.9,
                  child: AnimalView(animal: animal, state: TimerState.idle),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      "함께 집중한 시간",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${hours}시간 ${minutes}분",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text("자랑하기", style: TextStyle(fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _shareAnimalImage(animal),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.favorite, size: 18),
                      label: const Text("함께 집중", style: TextStyle(fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        controller.setCompanion(animal);
                        Get.back(); // 도감 다이얼로그 닫기
                        Get.back(); // 도감 뷰 자체 닫기 -> 홈으로 이동
                        Get.snackbar(
                          "동반 모드 시작",
                          "${animal.name}와(과) 함께 집중을 시작합니다!",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.white,
                          colorText: AppColors.text,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareAnimalImage(Animal animal) async {
    final hours = animal.currentExpMinutes ~/ 60;
    final minutes = animal.currentExpMinutes % 60;
    
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // 캡처용 위젯 생성 및 안정성 보강 (Material/Directionality 추가)
      final widget = Material(
        color: Colors.transparent,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: _buildShareCard(animal, hours, minutes),
        ),
      );
      
      final image = await _screenshotController.captureFromWidget(
        widget,
        context: Get.context,
        pixelRatio: 2.0, // 고해상도
        delay: const Duration(milliseconds: 500), // 위젯 렌더링 대기 시간 증가
      );

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/share_animal.png').create();
      await file.writeAsBytes(image);

      if (Get.isDialogOpen ?? false) Get.back(); // 로딩 닫기

      // 스토어 링크 설정
      String storeLink = "";
      if (Platform.isAndroid) {
        storeLink = "https://play.google.com/store/apps";
      } else if (Platform.isIOS) {
        storeLink = "https://apps.apple.com/app";
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '나는 포커스 타이머에서 ${animal.name}와(과) 함께 총 ${hours}시간 ${minutes}분을 집중했어요! ⏱️✨\n\n앱 확인하기: $storeLink',
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // 로딩 닫기
      debugPrint("Error generating share image: $e");
      Get.snackbar("에러", "공유 이미지 생성 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
    }
  }

  Widget _buildShareCard(Animal animal, int hours, int minutes) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amber, size: 40),
          const SizedBox(height: 10),
          const Text(
            "집중 완료!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.text, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 30),
          Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Transform.scale(
                scale: 1.2,
                child: AnimalView(animal: animal, state: TimerState.idle),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "나의 ${animal.name}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text, decoration: TextDecoration.none),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              "누적 집중: ${hours}시간 ${minutes}분",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary, decoration: TextDecoration.none),
            ),
          ),
          const SizedBox(height: 40),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, color: Colors.grey, size: 16),
              SizedBox(width: 5),
              Text(
                "포커스 타이머",
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal, decoration: TextDecoration.none),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
