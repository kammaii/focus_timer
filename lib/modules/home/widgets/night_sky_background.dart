import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class NightSkyBackground extends StatefulWidget {
  const NightSkyBackground({super.key});

  @override
  State<NightSkyBackground> createState() => _NightSkyBackgroundState();
}

class _NightSkyBackgroundState extends State<NightSkyBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ShootingStar> _stars = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _controller.addListener(_updateStars);
  }

  void _updateStars() {
    // 랜덤으로 별똥별 추가
    if (_random.nextDouble() < 0.05 && _stars.length < 5) {
      _stars.add(ShootingStar(
        x: _random.nextDouble() * 400 + 100, // 화면 중심 혹은 우측 상단 즈음에서 시작하도록
        y: -50,
        speed: _random.nextDouble() * 5 + 5,
        length: _random.nextDouble() * 50 + 50,
      ));
    }

    // 위치 업데이트 및 화면 밖으로 나가면 제거
    for (int i = _stars.length - 1; i >= 0; i--) {
      var star = _stars[i];
      star.x -= star.speed;
      star.y += star.speed;
      if (star.y > 1000 || star.x < -200) {
        _stars.removeAt(i);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: NightSkyPainter(stars: _stars),
          size: Size.infinite,
        );
      },
    );
  }
}

class ShootingStar {
  double x;
  double y;
  double speed;
  double length;

  ShootingStar({required this.x, required this.y, required this.speed, required this.length});
}

class NightSkyPainter extends CustomPainter {
  final List<ShootingStar> stars;
  final math.Random _random = math.Random(42); // 정지된 별들을 위해 고정된 시드 사용

  NightSkyPainter({required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 달(초승달 디자인) 그리기
    final moonX = size.width * 0.8;
    final moonY = size.height * 0.15;
    // 하얀 원 (달 배경)
    canvas.drawCircle(Offset(moonX, moonY), 40, Paint()..color = Colors.white70);
    // 검은 원 (달을 파먹어 초승달 형태로 만들기 위함)
    canvas.drawCircle(Offset(moonX - 15, moonY - 10), 38, Paint()..color = Colors.black);

    // 2. 배경에 고정된 작은 별 그리기
    final starPaint = Paint()..color = Colors.white.withOpacity(0.4);
    for (int i = 0; i < 50; i++) {
        double sx = _random.nextDouble() * size.width;
        double sy = _random.nextDouble() * size.height * 0.7; // 주로 위쪽 공간에 배치
        canvas.drawCircle(Offset(sx, sy), _random.nextDouble() * 2, starPaint);
    }

    // 3. 떨어지는 별똥별 (Shooting Stars) 애니메이션
    for (var star in stars) {
      final gradient = ui.Gradient.linear(
        Offset(star.x, star.y),
        Offset(star.x + star.length, star.y - star.length),
        [Colors.white.withOpacity(0.8), Colors.transparent],
      );

      final shootingStarPaint = Paint()
        ..shader = gradient
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      // 꼬리는 북동쪽(우상단)으로 향하게 그려짐
      canvas.drawLine(
        Offset(star.x, star.y),
        Offset(star.x + star.length, star.y - star.length),
        shootingStarPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant NightSkyPainter oldDelegate) => true;
}
