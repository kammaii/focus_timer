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
                ? "${widget.animal.name}이(가) 알에서 태어났습니다! 🎉"
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
                        ? SizedBox.expand(child: AnimalView(animal: widget.animal, state: TimerState.idle))
                        : Stack(
                            alignment: Alignment.center,
                            fit: StackFit.expand,
                            children: [
                              EggWidget(grade: widget.animal.grade),
                              if (_tapCount > 0) 
                                CustomPaint(
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
    
    // 이전에 120x150 캔버스에 맞춰졌던 좌표를 현재 size에 비례하여 변환
    double h(double val) => val * size.height / 150;
    double w(double val) => val * size.width / 120;
    final cx = size.width / 2;

    if (tapCount >= 1) {
      path.moveTo(cx, h(20));
      path.lineTo(cx - w(15), h(40));
    }
    if (tapCount >= 2) {
      path.lineTo(cx + w(10), h(60));
      path.lineTo(cx - w(20), h(80));
    }
    if (tapCount >= 3) {
      path.lineTo(cx + w(15), h(110));
      path.lineTo(cx - w(10), h(130));
    }
    if (tapCount >= 4) {
      // 옆면 추가 파편
      path.moveTo(cx - w(15), h(40));
      path.lineTo(cx - w(40), h(50));
      
      path.moveTo(cx + w(10), h(60));
      path.lineTo(cx + w(35), h(75));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CrackPainter oldDelegate) => oldDelegate.tapCount != tapCount;
}
