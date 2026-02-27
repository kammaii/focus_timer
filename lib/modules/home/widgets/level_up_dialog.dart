import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/animal.dart';
import '../home_controller.dart';
import 'animal_view.dart';
import 'dart:math' as math;

class LevelUpDialog extends StatefulWidget {
  final Animal animal;
  final AnimalLevel previousLevel;
  final AnimalLevel currentLevel;

  const LevelUpDialog({
    super.key,
    required this.animal,
    required this.previousLevel,
    required this.currentLevel,
  });

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog> with TickerProviderStateMixin {
  int _tapCount = 0;
  bool _isFlashing = false;
  bool _isHatched = false;

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onTap() async {
    if (_isHatched || _isFlashing) return;

    HapticFeedback.heavyImpact();
    
    // 흔들림 애니메이션 재생
    await _shakeController.forward(from: 0.0);
    
    setState(() {
      _tapCount++;
    });

    if (_tapCount >= 5) {
      _hatch();
    }
  }

  void _hatch() async {
    setState(() {
      _isFlashing = true;
    });
    
    // 하얀색 섬광
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _isFlashing = false;
      _isHatched = true;
    });
    
    HapticFeedback.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFlashing) {
      return const Scaffold(
        backgroundColor: Colors.white,
      );
    }

    // 진화 전 동물 모형용 임시 동물 객체 (사용 안함)

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isHatched 
                ? "알에서 깨어났어요! 🎉"
                : "터치해서 알을 깨워주세요!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 60),
            GestureDetector(
              onTap: _onTap,
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  // 진동 효과 계산
                  final sineValue = math.sin(_shakeController.value * math.pi * 4);
                  final dx = _shakeController.isAnimating ? sineValue * 10 : 0.0;
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: child,
                  );
                },
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isHatched)
                        // 축하 폭죽 효과 대용
                        const Positioned.fill(
                          child: Icon(Icons.star, color: Colors.amber, size: 250),
                        ),
                      _isHatched
                        ? AnimalView(animal: widget.animal, state: TimerState.idle)
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              const EggWidget(),
                              if (_tapCount > 0) 
                                CustomPaint(
                                  size: const Size(120, 150),
                                  painter: CrackPainter(_tapCount),
                                )
                            ],
                          ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
            if (_isHatched)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.orangeAccent,
                ),
                onPressed: () {
                  Get.back();
                },
                child: const Text("계속하기", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              )
          ],
        ),
      ),
    );
  }
}

class CrackPainter extends CustomPainter {
  final int tapCount;
  CrackPainter(this.tapCount);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    if (tapCount >= 1) {
      path.moveTo(size.width / 2, 20);
      path.lineTo(size.width / 2 - 15, 40);
    }
    if (tapCount >= 2) {
      path.lineTo(size.width / 2 + 10, 60);
      path.lineTo(size.width / 2 - 20, 80);
    }
    if (tapCount >= 3) {
      path.lineTo(size.width / 2 + 15, 110);
      path.lineTo(size.width / 2 - 10, 130);
    }
    if (tapCount >= 4) {
      // 옆면 추가 파편
      path.moveTo(size.width / 2 - 15, 40);
      path.lineTo(size.width / 2 - 40, 50);
      
      path.moveTo(size.width / 2 + 10, 60);
      path.lineTo(size.width / 2 + 35, 75);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CrackPainter oldDelegate) => oldDelegate.tapCount != tapCount;
}
