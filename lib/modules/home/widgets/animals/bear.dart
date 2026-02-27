import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

// ==========================================
// Focus Mode: FocusBear (공부하는 곰)
// ==========================================
class FocusBear extends StatefulWidget {
  const FocusBear({super.key});

  @override
  State<FocusBear> createState() => _FocusBearState();
}

class _FocusBearState extends State<FocusBear> with TickerProviderStateMixin {
  late AnimationController _eyeController;
  late AnimationController _earController;
  late Animation<double> _eyeAnimation;
  late Animation<double> _earAnimation;
  bool _isSurprised = false;

  @override
  void initState() {
    super.initState();
    _eyeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _eyeAnimation = Tween<double>(begin: -2.5, end: 2.5).animate(CurvedAnimation(parent: _eyeController, curve: Curves.easeInOut));
    _earController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _earAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _earController, curve: Curves.elasticOut));
  }

  void _onTapBear() async {
    if (_isSurprised) return;
    setState(() => _isSurprised = true);
    await _earController.forward(); // 귀가 쫑긋하는 연출
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      await _earController.reverse();
      setState(() => _isSurprised = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapBear,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_eyeController, _earController]),
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(150, 150),
                  painter: _FocusBearPainter(
                    eyeX: _eyeAnimation.value,
                    earProgress: _earAnimation.value,
                    isSurprised: _isSurprised,
                  ),
                );
              },
            ),
            Positioned(
              bottom: 10,
              child: CustomPaint(
                size: const Size(110, 60),
                painter: _StaticBookPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eyeController.dispose();
    _earController.dispose();
    super.dispose();
  }
}

class _FocusBearPainter extends CustomPainter {
  final double eyeX, earProgress;
  final bool isSurprised;

  _FocusBearPainter({required this.eyeX, required this.earProgress, required this.isSurprised});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.brown[600]!;
    final muzzlePaint = Paint()..color = Colors.brown[200]!;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 - 25);

    // 1. 둥근 귀 (터치 시 살짝 커짐)
    for (int i in [-1, 1]) {
      canvas.drawCircle(Offset(i * 35, -25 - (earProgress * 5)), 15 + (earProgress * 3), bodyPaint);
      canvas.drawCircle(Offset(i * 35, -25 - (earProgress * 5)), 15 + (earProgress * 3), strokePaint);
    }

    // 2. 몸통 (듬직한 사각형 형태)
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-50, -30, 100, 85), const Radius.circular(35)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-50, -30, 100, 85), const Radius.circular(35)), strokePaint);

    // 3. 머즐 (입가 밝은 부분)
    canvas.drawOval(const Rect.fromLTWH(-20, 5, 40, 30), muzzlePaint);

    // 4. 얼굴
    if (isSurprised) {
      canvas.drawCircle(const Offset(-18, -10), 8, strokePaint);
      canvas.drawCircle(const Offset(18, -10), 8, strokePaint);
      canvas.drawCircle(const Offset(-18, -10), 3, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(18, -10), 3, Paint()..color = Colors.black);
    } else {
      // 안경
      canvas.drawCircle(const Offset(-18, -10), 14, strokePaint);
      canvas.drawCircle(const Offset(18, -10), 14, strokePaint);
      canvas.drawLine(const Offset(-4, -10), const Offset(4, -10), strokePaint);
      canvas.drawCircle(Offset(-18 + eyeX, -10), 3, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(18 + eyeX, -10), 3, Paint()..color = Colors.black);
    }
    // 코
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, 8, 10, 6), const Radius.circular(3)), Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _FocusBearPainter oldDelegate) => true;
}

// ==========================================
// Rest Mode: RestBear (꿀 먹는 곰)
// ==========================================
class RestBear extends StatefulWidget {
  const RestBear({super.key});

  @override
  State<RestBear> createState() => _RestBearState();
}

class _RestBearState extends State<RestBear> with TickerProviderStateMixin {
  late AnimationController _munchController, _shareController;
  late Animation<double> _munchAnimation, _shareAnimation;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _munchController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))..repeat(reverse: true);
    _munchAnimation = Tween<double>(begin: 0.0, end: 5.0).animate(CurvedAnimation(parent: _munchController, curve: Curves.easeInOut));
    _shareController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shareAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _shareController, curve: Curves.elasticOut));
  }

  void _onTapBear() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    await _shareController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      await _shareController.reverse();
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapBear,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_munchController, _shareController]),
          builder: (context, child) {
            return CustomPaint(
              size: const Size(150, 150),
              painter: _RestBearPainter(
                munchOffset: _munchAnimation.value,
                shareProgress: _shareAnimation.value,
                isSharing: _isSharing,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _munchController.dispose();
    _shareController.dispose();
    super.dispose();
  }
}

class _RestBearPainter extends CustomPainter {
  final double munchOffset, shareProgress;
  final bool isSharing;

  _RestBearPainter({required this.munchOffset, required this.shareProgress, required this.isSharing});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.brown[600]!;
    final muzzlePaint = Paint()..color = Colors.brown[200]!;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 + 10);
    canvas.scale(0.85, 0.85);

    // 1. 귀 & 몸통
    for (int i in [-1, 1]) {
      canvas.drawCircle(Offset(i * 40, -55), 18, bodyPaint);
      canvas.drawCircle(Offset(i * 40, -55), 18, stroke);
    }

    Rect bodyRect = const Rect.fromLTWH(-55, -60, 110, 115);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(40)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(40)), stroke);

    // 2. 머즐 & 웃는 표정
    canvas.drawOval(const Rect.fromLTWH(-22, -25, 44, 32), muzzlePaint);
    for (int i in [-1, 1]) {
    canvas.drawPath(Path()..moveTo(i * 25 - 8, -40)..quadraticBezierTo(i * 25, -48, i * 25 + 8, -40), stroke);
    }
    // 오물거리는 코
    canvas.drawCircle(Offset(0, -12 + (munchOffset * 0.4)), 4, Paint()..color = Colors.black);

    // 3. 꿀단지 & 앞발
    canvas.save();
    canvas.translate(0, 15 * shareProgress);
    canvas.scale(1.0 + (0.12 * shareProgress));

    _drawHoneyPot(canvas, stroke);

    // 앞발
    canvas.drawCircle(const Offset(-25, 20), 15, bodyPaint); canvas.drawCircle(const Offset(-25, 20), 15, stroke);
    canvas.drawCircle(const Offset(25, 20), 15, bodyPaint); canvas.drawCircle(const Offset(25, 20), 15, stroke);
    canvas.restore();
  }

  void _drawHoneyPot(Canvas canvas, Paint stroke) {
    final potPaint = Paint()..color = Colors.amber[700]!;
    final honeyPaint = Paint()..color = Colors.yellow[600]!;

    // 단지 몸체
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-20, 10, 40, 35), const Radius.circular(10)), potPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-20, 10, 40, 35), const Radius.circular(10)), stroke);
    // 흘러나오는 꿀
    canvas.drawRect(const Rect.fromLTWH(-15, 10, 10, 15), honeyPaint);
    canvas.drawCircle(const Offset(-10, 25), 5, honeyPaint);
  }

  @override
  bool shouldRepaint(covariant _RestBearPainter oldDelegate) => true;
}

// ==========================================
// Idle Mode: IdleBear (하트 뿅뿅 곰)
// ==========================================
class IdleBear extends StatefulWidget {
  const IdleBear({super.key});

  @override
  State<IdleBear> createState() => _IdleBearState();
}

class _IdleBearState extends State<IdleBear> with TickerProviderStateMixin {
  late AnimationController _bodyController;
  late Animation<double> _bodyAnimation;
  final List<HeartParticle> _hearts = [];
  final math.Random _random = math.Random();
  bool _isShowingLove = false;

  @override
  void initState() {
    super.initState();
    _bodyController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _bodyAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(CurvedAnimation(parent: _bodyController, curve: Curves.easeInOut));
    Timer.periodic(const Duration(milliseconds: 50), (t) => _updateHearts());
  }

  void _updateHearts() {
    if (!mounted || _hearts.isEmpty) return;
    setState(() {
      for (int i = _hearts.length - 1; i >= 0; i--) {
        _hearts[i].position += Offset(_hearts[i].speedX, -_hearts[i].speedY);
        _hearts[i].opacity -= 0.02;
        if (_hearts[i].opacity <= 0) _hearts.removeAt(i);
      }
    });
  }

  void _onTap() {
    setState(() => _isShowingLove = true);
    for (int i = 0; i < 3; i++) {
      _hearts.add(HeartParticle(
        position: const Offset(0, -45), size: 16, angle: 0,
        speedY: 1.5 + _random.nextDouble(), speedX: (_random.nextDouble() - 0.5) * 2,
      ));
    }
    Future.delayed(const Duration(milliseconds: 800), () => setState(() => _isShowingLove = false));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _bodyController,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(150, 150),
            painter: _IdleBearPainter(
              bodyOffset: _bodyAnimation.value,
              hearts: _hearts,
              isShowingLove: _isShowingLove,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }
}

class _IdleBearPainter extends CustomPainter {
  final double bodyOffset;
  final List<HeartParticle> hearts;
  final bool isShowingLove;

  _IdleBearPainter({required this.bodyOffset, required this.hearts, required this.isShowingLove});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = Colors.brown[600]!;
    final muzzlePaint = Paint()
      ..color = Colors.brown[200]!;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 - 15 + bodyOffset);

    for (var h in hearts)
      _drawHeart(canvas, h);

    // 귀 & 몸통
    for (int i in [-1, 1]) {
      canvas.drawCircle(Offset(i * 35, -28), 16, bodyPaint);
      canvas.drawCircle(Offset(i * 35, -28), 16, stroke);
    }

    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-45, -30, 90, 90), const Radius.circular(32)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-45, -30, 90, 90), const Radius.circular(32)), stroke);

    // 머즐
    canvas.drawOval(const Rect.fromLTWH(-18, 5, 36, 26), muzzlePaint);

    if (isShowingLove) {
    for (int i in [-1, 1]) {
    canvas.drawPath(Path()..moveTo(i * 18 - 6, -12)..quadraticBezierTo(i * 18, -18, i * 18 + 6, -12), stroke);
    }
    canvas.drawArc(const Rect.fromLTWH(-5, 12, 10, 8), 0, math.pi, false, stroke);
    } else {
    canvas.drawCircle(const Offset(-18, -10), 4.5, Paint()..color = Colors.black);
    canvas.drawCircle(const Offset(18, -10), 4.5, Paint()..color = Colors.black);
    }
    canvas.drawCircle(const Offset(0, 12), 4, Paint()..color = Colors.black);
  }

  void _drawHeart(Canvas canvas, HeartParticle h) {
    final p = Paint()..color = Colors.pinkAccent.withOpacity(h.opacity);
    canvas.save(); canvas.translate(h.position.dx, h.position.dy); canvas.scale(h.size / 20);
    Path path = Path()..moveTo(0, 5)..cubicTo(0, -5, -10, -5, -10, 0)..cubicTo(-10, 10, 0, 15, 0, 20)..cubicTo(0, 15, 10, 10, 10, 0)..cubicTo(10, -5, 0, -5, 0, 5)..close();
    canvas.drawPath(path, p); canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IdleBearPainter oldDelegate) => true;
}

// ---------------------------------------------------------
// 기존 도서 페인터 재활용 (곰은 자연과 어울리는 녹색 도서)
class _StaticBookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(0, 5, size.width, 40), Paint()..color = Colors.white);
    Path path = Path()
      ..moveTo(0, 5)..lineTo(size.width/2, 12)..lineTo(size.width, 5)
      ..lineTo(size.width, 50)..lineTo(size.width/2, 57)..lineTo(0, 50)..close();
    canvas.drawPath(path, Paint()..color = Colors.green[800]!);
    canvas.drawPath(path, stroke);
    canvas.drawLine(Offset(size.width/2, 12), Offset(size.width/2, 57), stroke);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HeartParticle {
  Offset position; double size; double angle; double opacity; double speedY; double speedX;
  HeartParticle({required this.position, required this.size, required this.angle, this.opacity = 1.0, required this.speedY, required this.speedX});
}