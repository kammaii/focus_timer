import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../data/models/animal.dart';
import '../damagotchi_controller.dart';
import '../home_controller.dart';
import 'animal_view.dart';

class ExpProgressDialog extends StatefulWidget {
  final Animal animal;
  final int baseExp; // 원래 획득할 경험치
  final Function(int) onRewardClaimed; // 경험치 획득 후 콜백 함수

  const ExpProgressDialog({
    super.key,
    required this.animal,
    required this.baseExp,
    required this.onRewardClaimed,
  });

  @override
  State<ExpProgressDialog> createState() => _ExpProgressDialogState();
}

class _ExpProgressDialogState extends State<ExpProgressDialog> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late ConfettiController _confettiController;

  double _initialProgress = 0.0;
  double _targetProgress = 0.0;
  int _displayExp = 0;
  bool _isClaimed = false;
  int _claimMultiplier = 1;
  bool _showExpPop = false;

  @override
  void initState() {
    super.initState();
    _initialProgress = widget.animal.currentLevelProgress;
    _displayExp = widget.animal.currentExpMinutes;
    _progressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // 다이얼로그가 열릴 때 꽃가루 터트리기 및 텍스트 팝업 애니메이션 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      setState(() {
        _showExpPop = true;
      });
    });
  }

  void _animateProgress(int addedExp) {
    // 임시 복사본으로 타겟 프로그레스 계산
    final tempAnimal = Animal.fromJson(widget.animal.toJson());
    tempAnimal.addExp(addedExp);
    
    // 만약 레벨업을 했다면 프로그레스 바가 가득 찬 상태(1.0)로 애니메이션 후 종료
    if (tempAnimal.level != widget.animal.level) {
       _targetProgress = 1.0;
    } else {
       _targetProgress = tempAnimal.currentLevelProgress;
    }

    _progressAnimation = Tween<double>(begin: _initialProgress, end: _targetProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic)
    );
    
    _progressController.addListener(() {
      setState(() {
        // 숫자 롤링 애니메이션
        final progressRatio = _progressController.value;
        _displayExp = widget.animal.currentExpMinutes + (addedExp * progressRatio).toInt();
      });
    });

    _progressController.forward(from: 0.0);
  }

  void _claim(int multiplier) async {
    if (_isClaimed) return;
    setState(() {
      _isClaimed = true;
      _claimMultiplier = multiplier;
    });
    
    int totalAddedExp = widget.baseExp * multiplier;

    if (multiplier > 1) {
      // TODO: 실제 광고 시청 연동
      Get.snackbar("광고 시청 완료!", "경험치를 2배로 획득했습니다! 🎉", snackPosition: SnackPosition.TOP);
    }
    
    // 폭죽 터트리기
    _confettiController.play();
    
    _animateProgress(totalAddedExp);
    
    // 애니메이션이 끝나길 기다림
    await Future.delayed(const Duration(milliseconds: 1800));
    
    // 다이얼로그 닫고 컨트롤러 쪽에 결과 전달
    Get.back();
    widget.onRewardClaimed(totalAddedExp);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
              "집중 완료!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Text(
              "${widget.animal.name}이(가) 경험치를 얻었어요",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            
            // 획득 경험치 강조 표시 (등장 시 팝업, 획득 시 추가 팝업)
            AnimatedScale(
              scale: _isClaimed ? 1.2 : (_showExpPop ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              child: Text(
                "+${widget.baseExp * _claimMultiplier} EXP",
                style: const TextStyle(
                  fontSize: 40, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.orange,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 동물 뷰 
            SizedBox(
              height: 150,
              width: 150,
              child: AnimalView(animal: widget.animal, state: TimerState.idle),
            ),
            
            const SizedBox(height: 30),
            
            // 경험치 바
            Stack(
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    final currentVal = _progressController.isAnimating ? _progressAnimation.value : _initialProgress;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          height: 20,
                          width: constraints.maxWidth * currentVal,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }
                    );
                  }
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // 경험치 텍스트
            Text(
              "$_displayExp / ${widget.animal.maxExpForCurrentLevel} EXP",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            
            const SizedBox(height: 30),
            
            // 버튼 영역
            if (!_isClaimed) ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_outline, color: Colors.white),
                label: Text("광고 보고 ${widget.baseExp * 2} EXP 받기", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _claim(2),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _claim(1),
                child: Text("그냥 ${widget.baseExp} EXP 받기", style: const TextStyle(color: Colors.grey, fontSize: 16)),
              ),
            ] else ...[
              const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
              const SizedBox(height: 12),
              const Text("경험치 흡수 중...", style: TextStyle(color: Colors.grey)),
            ]
          ],
        ),
      ),
      
      // 불꽃놀이 효과 오버레이
      Positioned.fill(
        child: Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, // 사방으로 폭발
            maxBlastForce: 60, // 강하게 멀리 퍼짐
            minBlastForce: 20,
            emissionFrequency: 0.0, // 한 번에 "팡!" 하고 터지기 위해 0 설정
            numberOfParticles: 80, // 파티클 개수 증가 (풍성하게)
            gravity: 0.3, // 약간의 무게감
          ),
        ),
      ),
    ],
  ),
);
  }
}
