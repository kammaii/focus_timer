import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/animal.dart';
import '../damagotchi_controller.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:math';

class NewEggDialog extends StatefulWidget {
  const NewEggDialog({super.key});

  @override
  State<NewEggDialog> createState() => _NewEggDialogState();
}

class _NewEggDialogState extends State<NewEggDialog> {
  AnimalGrade _selectedGrade = AnimalGrade.normal;

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

    // 현재 선택된 등급이 수집 완료된 경우 자동 전환
    if (_selectedGrade == AnimalGrade.normal &&
        allNormalCollected &&
        !allSpecialCollected) {
      _selectedGrade = AnimalGrade.special;
    } else if (_selectedGrade == AnimalGrade.special &&
        allSpecialCollected &&
        !allNormalCollected) {
      _selectedGrade = AnimalGrade.normal;
    }

    final bool isSelectionDisabled =
        (_selectedGrade == AnimalGrade.normal && allNormalCollected) ||
        (_selectedGrade == AnimalGrade.special && allSpecialCollected);

    String buttonLabel = "";
    IconData buttonIcon = Icons.play_arrow;
    Color buttonColor = AppColors.primary;

    if (_selectedGrade == AnimalGrade.normal) {
      buttonLabel = allNormalCollected ? "일반 동물 수집 완료" : "일반 알 선택하여 시작";
      buttonIcon = Icons.egg;
      buttonColor = Colors.blueGrey.shade400;
    } else {
      buttonLabel = allSpecialCollected ? "스페셜 동물 수집 완료" : "광고 보고 스페셜 알 받기";
      buttonIcon = Icons.card_giftcard;
      buttonColor = Colors.amber.shade700;
    }

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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, color: Colors.lightGreen, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "새로운 여정",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "집중할 알을 선택하고 어떤 친구가\n태어날지 확인해보세요!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
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
                        isSelected: _selectedGrade == AnimalGrade.normal,
                        isDisabled: allNormalCollected,
                        onTap: () {
                          if (!allNormalCollected) {
                            setState(() => _selectedGrade = AnimalGrade.normal);
                          }
                        },
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
                        isSelected: _selectedGrade == AnimalGrade.special,
                        isDisabled: allSpecialCollected,
                        onTap: () {
                          if (!allSpecialCollected) {
                            setState(
                              () => _selectedGrade = AnimalGrade.special,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isSelectionDisabled
                        ? null
                        : () => _selectEgg(_selectedGrade),
                    icon: Icon(buttonIcon, size: 20, color: Colors.white),
                    label: Text(
                      buttonLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
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
                        child: Text(
                          "새로운 동물친구를 부화시키기 위해 집중하세요!",
                          style: TextStyle(color: Colors.green, fontSize: 11),
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
    required bool isSelected,
    bool isDisabled = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey.shade50
              : (isSelected ? eggColor.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? eggColor : Colors.grey.shade200,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: eggColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
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
                    color: isDisabled
                        ? Colors.grey.shade200
                        : eggColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  eggIcon,
                  size: 60,
                  color: isDisabled ? Colors.grey : eggColor,
                ),
                if (badgeIcon != null)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        badgeIcon,
                        size: 16,
                        color: isDisabled ? Colors.grey : Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDisabled ? Colors.grey : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _selectEgg(AnimalGrade grade) async {
    if (grade == AnimalGrade.special) {
      final rewardEarned = await AdService().showRewardedAd(
        onRewardEarned: () {},
      );

      if (!rewardEarned) return;
    }

    final controller = Get.find<DamagotchiController>();

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
        final inCollection = controller.collection.any(
          (animal) => animal.type == type,
        );
        final isCurrent = controller.currentAnimal.value?.type == type;
        return !inCollection && !isCurrent;
      }).toList();
      if (uncollectedNormalTypes.isEmpty) {
        Get.snackbar("알림", "모든 일반 동물을 수집했습니다.");
        return;
      }
      selectedType =
          uncollectedNormalTypes[random.nextInt(uncollectedNormalTypes.length)];
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
        final inCollection = controller.collection.any(
          (animal) => animal.type == type,
        );
        final isCurrent = controller.currentAnimal.value?.type == type;
        return !inCollection && !isCurrent;
      }).toList();
      if (uncollectedSpecialTypes.isEmpty) {
        Get.snackbar("알림", "모든 스페셜 동물을 수집했습니다.");
        return;
      }
      selectedType =
          uncollectedSpecialTypes[random.nextInt(
            uncollectedSpecialTypes.length,
          )];
    }

    await controller.acquireNewEgg(selectedType, grade);

    if (Get.isDialogOpen ?? false) Get.back();
    Get.snackbar(
      "새 알 획득!",
      "새로운 알을 얻었습니다. 열심히 집중해서 키워보세요!",
      snackPosition: SnackPosition.TOP,
    );
  }
}
