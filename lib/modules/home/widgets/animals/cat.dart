import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:focus_timer/modules/home/widgets/animals/rabbit.dart';

// ==========================================
// Focus Mode: FocusCat (공부하는 고양이)
// ==========================================
class FocusCat extends StatefulWidget {
  const FocusCat({super.key});

  @override
  State<FocusCat> createState() => _FocusCatState();
}

class _FocusCatState extends State<FocusCat> with TickerProviderStateMixin {
  late AnimationController _eyeController;
  late AnimationController _earController;
  late Animation<double> _eyeAnimation;
  late Animation<double> _earAnimation;
  bool _isSurprised = false;

  @override
  void initState() {
    super.initState();
    _eyeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _eyeAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(CurvedAnimation(parent: _eyeController, curve: Curves.easeInOut));
    _earController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _earAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _earController, curve: Curves.elasticOut));
  }

  void _onTapCat() async {
    if (_isSurprised) return;
    setState(() => _isSurprised = true);
    await _earController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      await _earController.reverse();
      setState(() => _isSurprised = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapCat,
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
                  painter: _FocusCatPainter(
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

class _FocusCatPainter extends CustomPainter {
  final double eyeX;
  final double earProgress;
  final bool isSurprised;

  _FocusCatPainter({required this.eyeX, required this.earProgress, required this.isSurprised});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.white;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 - 30);

    // 1. 뾰족한 귀 (토끼와 달리 짧고 삼각형)
    _drawCatEar(canvas, bodyPaint, strokePaint, isLeft: true);
    _drawCatEar(canvas, bodyPaint, strokePaint, isLeft: false);

    // 2. 몸통
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-45, -30, 90, 80), const Radius.circular(35)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-45, -30, 90, 80), const Radius.circular(35)), strokePaint);

    // 3. 수염
    _drawWhiskers(canvas, strokePaint);

    // 4. 얼굴
    if (isSurprised) {
      canvas.drawCircle(const Offset(-18, -10), 9, strokePaint);
      canvas.drawCircle(const Offset(18, -10), 9, strokePaint);
      canvas.drawCircle(const Offset(-18, -10), 3, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(18, -10), 3, Paint()..color = Colors.black);
    } else {
      // 안경
      canvas.drawCircle(const Offset(-18, -10), 13, strokePaint);
      canvas.drawCircle(const Offset(18, -10), 13, strokePaint);
      canvas.drawLine(const Offset(-5, -10), const Offset(5, -10), strokePaint);
      canvas.drawCircle(Offset(-18 + eyeX, -10), 2.5, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(18 + eyeX, -10), 2.5, Paint()..color = Colors.black);
    }
    // 코 (삼각형)
    _drawCatNose(canvas);
  }

  void _drawCatEar(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    canvas.save();
    double x = isLeft ? -35 : 35;
    canvas.translate(x, -25);
    // 놀랐을 때 귀가 살짝 쫑긋하며 회전
    canvas.rotate(isLeft ? -earProgress * 0.2 : earProgress * 0.2);

    Path path = Path();
    path.moveTo(-15, 0);
    path.lineTo(0, -35);
    path.lineTo(15, 0);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    canvas.restore();
  }

  void _drawWhiskers(Canvas canvas, Paint stroke) {
    for (int i in [-1, 1]) { // 좌우
      double x = i * 45;
      canvas.drawLine(Offset(x, 0), Offset(x + (i * 15), -5), stroke);
      canvas.drawLine(Offset(x, 5), Offset(x + (i * 15), 5), stroke);
    }
  }

  void _drawCatNose(Canvas canvas) {
    Paint nosePaint = Paint()..color = Colors.pink[100]!;
    Path path = Path();
    path.moveTo(-4, 2); path.lineTo(4, 2); path.lineTo(0, 7); path.close();
    canvas.drawPath(path, nosePaint);
  }

  @override
  bool shouldRepaint(covariant _FocusCatPainter oldDelegate) => true;
}

// ==========================================
// Rest Mode: RestCat (생선 먹는 고양이)
// ==========================================
class RestCat extends StatefulWidget {
  const RestCat({super.key});

  @override
  State<RestCat> createState() => _RestCatState();
}

class _RestCatState extends State<RestCat> with TickerProviderStateMixin {
  late AnimationController _munchController;
  late AnimationController _shareController;
  late Animation<double> _munchAnimation;
  late Animation<double> _shareAnimation;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _munchController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250))..repeat(reverse: true);
    _munchAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(CurvedAnimation(parent: _munchController, curve: Curves.easeInOut));
    _shareController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shareAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _shareController, curve: Curves.elasticOut));
  }

  void _onTapCat() async {
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
      onTap: _onTapCat,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_munchController, _shareController]),
          builder: (context, child) {
            return CustomPaint(
              size: const Size(150, 150),
              painter: _RestCatPainter(
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

class _RestCatPainter extends CustomPainter {
  final double munchOffset;
  final double shareProgress;
  final bool isSharing;

  _RestCatPainter({required this.munchOffset, required this.shareProgress, required this.isSharing});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.white;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final fishColor = Colors.orange[300]!;

    canvas.translate(size.width / 2, size.height / 2 + 10);
    canvas.scale(0.85, 0.85);

    // 1. 귀 & 몸통
    _drawCatEarStatic(canvas, bodyPaint, stroke, isLeft: true);
    _drawCatEarStatic(canvas, bodyPaint, stroke, isLeft: false);

    Rect bodyRect = const Rect.fromLTWH(-50, -60, 100, 110);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(40)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(40)), stroke);

    // 수염 & 얼굴
    _drawWhiskers(canvas, stroke);
    _drawHappyEyes(canvas, stroke);

    // 2. 입 오물거림 (생선 먹는 느낌)
    canvas.drawCircle(Offset(0, -20 + (munchOffset * 0.5)), 3, Paint()..color = Colors.pink[100]!);

    // 3. 생선 & 앞발 (Share)
    canvas.save();
    canvas.translate(0, 15 * shareProgress);
    canvas.scale(1.0 + (0.1 * shareProgress));

    _drawStaticFish(canvas, fishColor, stroke);

    // 앞발
    canvas.drawCircle(const Offset(-20, 15), 12, bodyPaint); canvas.drawCircle(const Offset(-20, 15), 12, stroke);
    canvas.drawCircle(const Offset(20, 15), 12, bodyPaint); canvas.drawCircle(const Offset(20, 15), 12, stroke);
    canvas.restore();
  }

  void _drawCatEarStatic(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    canvas.save();
    canvas.translate(isLeft ? -35 : 35, -55);
    Path path = Path()..moveTo(-15, 0)..lineTo(0, -30)..lineTo(15, 0)..close();
    canvas.drawPath(path, fill); canvas.drawPath(path, stroke);
    canvas.restore();
  }

  void _drawStaticFish(Canvas canvas, Color color, Paint stroke) {
    Paint fishPaint = Paint()..color = color;
    Path fish = Path()
      ..moveTo(20, 0)..quadraticBezierTo(0, -15, -20, 0)
      ..quadraticBezierTo(0, 15, 20, 0)..close();
    canvas.drawPath(fish, fishPaint);
    canvas.drawPath(fish, stroke);
    // 꼬리
    Path tail = Path()..moveTo(-20, 0)..lineTo(-30, -10)..lineTo(-30, 10)..close();
    canvas.drawPath(tail, fishPaint);
    canvas.drawPath(tail, stroke);
  }

  void _drawHappyEyes(Canvas canvas, Paint stroke) {
    for (int i in [-1, 1]) {
      canvas.drawPath(Path()..moveTo(i * 25 - 8, -40)..quadraticBezierTo(i * 25, -48, i * 25 + 8, -40), stroke);
    }
  }

  void _drawWhiskers(Canvas canvas, Paint stroke) {
    for (int i in [-1, 1]) {
      double x = i * 50;
      canvas.drawLine(Offset(x, -25), Offset(x + (i * 12), -28), stroke);
      canvas.drawLine(Offset(x, -20), Offset(x + (i * 12), -20), stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _RestCatPainter oldDelegate) => true;
}

// ==========================================
// Idle Mode: IdleCat (멍 때리는 고양이)
// ==========================================
class IdleCat extends StatefulWidget {
  const IdleCat({super.key});

  @override
  State<IdleCat> createState() => _IdleCatState();
}

class _IdleCatState extends State<IdleCat> with TickerProviderStateMixin {
  late AnimationController _bodyController;
  late AnimationController _heartTickController;
  late Animation<double> _bodyAnimation;
  final List<HeartParticle> _hearts = [];
  final math.Random _random = math.Random();
  bool _isShowingLove = false;
  bool _isBlinking = false;

  @override
  void initState() {
    super.initState();
    _bodyController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _bodyAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(CurvedAnimation(parent: _bodyController, curve: Curves.easeInOut));
    _heartTickController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _heartTickController.addListener(_updateHearts);
    _startBlinkRoutine();
  }

  void _updateHearts() {
    if (_hearts.isEmpty) return;
    setState(() {
      for (int i = _hearts.length - 1; i >= 0; i--) {
        final heart = _hearts[i];
        heart.position += Offset(heart.speedX, -heart.speedY);
        heart.opacity -= 0.02;
        if (heart.opacity <= 0) _hearts.removeAt(i);
      }
    });
  }

  void _startBlinkRoutine() {
    Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (mounted && !_isShowingLove) {
        setState(() => _isBlinking = true);
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) setState(() => _isBlinking = false);
      }
    });
  }

  void _onTapCat() {
    setState(() => _isShowingLove = true);
    for (int i = 0; i < 3; i++) {
      _hearts.add(HeartParticle(
        position: const Offset(0, -50),
        size: 15.0 + _random.nextDouble() * 10,
        angle: 0, speedY: 2.0 + _random.nextDouble(),
        speedX: (_random.nextDouble() - 0.5) * 2,
      ));
    }
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isShowingLove = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapCat,
      child: AnimatedBuilder(
        animation: _bodyController,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(150, 150),
            painter: _IdleCatPainter(
              bodyOffset: _bodyAnimation.value,
              hearts: _hearts,
              isShowingLove: _isShowingLove,
              isBlinking: _isBlinking,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _heartTickController.dispose();
    super.dispose();
  }
}

class _IdleCatPainter extends CustomPainter {
  final double bodyOffset;
  final List<HeartParticle> hearts;
  final bool isShowingLove, isBlinking;

  _IdleCatPainter({required this.bodyOffset, required this.hearts, required this.isShowingLove, required this.isBlinking});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.white;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 - 15 + bodyOffset);

    // 하트
    for (var heart in hearts) _drawHeart(canvas, heart);

    // 귀 & 몸통
    _drawCatEar(canvas, bodyPaint, stroke, isLeft: true);
    _drawCatEar(canvas, bodyPaint, stroke, isLeft: false);

    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-40, -30, 80, 85), const Radius.circular(30)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-40, -30, 80, 85), const Radius.circular(30)), stroke);

    // 수염 & 얼굴
    _drawWhiskers(canvas, stroke);

    if (isShowingLove) {
      _drawHappyFace(canvas, stroke);
    } else if (isBlinking) {
      canvas.drawLine(const Offset(-20, -10), const Offset(-10, -10), stroke);
      canvas.drawLine(const Offset(10, -10), const Offset(20, -10), stroke);
    } else {
      canvas.drawCircle(const Offset(-16, -10), 4, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(16, -10), 4, Paint()..color = Colors.black);
    }
    // 코
    _drawNose(canvas);
  }

  void _drawCatEar(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    canvas.save();
    canvas.translate(isLeft ? -30 : 30, -25);
    Path path = Path()..moveTo(-12, 0)..lineTo(0, -25)..lineTo(12, 0)..close();
    canvas.drawPath(path, fill); canvas.drawPath(path, stroke);
    canvas.restore();
  }

  void _drawWhiskers(Canvas canvas, Paint stroke) {
    for (int i in [-1, 1]) {
      double x = i * 40;
      canvas.drawLine(Offset(x, 0), Offset(x + (i * 10), -3), stroke);
      canvas.drawLine(Offset(x, 5), Offset(x + (i * 10), 5), stroke);
    }
  }

  void _drawHappyFace(Canvas canvas, Paint stroke) {
    for (int i in [-1, 1]) {
      canvas.drawPath(Path()..moveTo(i * 16 - 6, -12)..quadraticBezierTo(i * 16, -18, i * 16 + 6, -12), stroke);
    }
    canvas.drawArc(const Rect.fromLTWH(-5, 5, 10, 10), 0, math.pi, false, stroke);
  }

  void _drawNose(Canvas canvas) {
    Paint p = Paint()..color = Colors.pink[100]!;
    canvas.drawPath(Path()..moveTo(-3, 4)..lineTo(3, 4)..lineTo(0, 8)..close(), p);
  }

  void _drawHeart(Canvas canvas, HeartParticle heart) {
    final p = Paint()..color = Colors.pinkAccent.withOpacity(heart.opacity);
    canvas.save();
    canvas.translate(heart.position.dx, heart.position.dy);
    canvas.scale(heart.size / 20);
    Path path = Path()..moveTo(0, 5)..cubicTo(0, -5, -10, -5, -10, 0)..cubicTo(-10, 10, 0, 15, 0, 20)..cubicTo(0, 15, 10, 10, 10, 0)..cubicTo(10, -5, 0, -5, 0, 5)..close();
    canvas.drawPath(path, p);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IdleCatPainter oldDelegate) => true;
}

// ---------------------------------------------------------
// 기존 도서 페인터 재활용
class _StaticBookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(0, 5, size.width, 40), Paint()..color = Colors.white);
    Path path = Path()
      ..moveTo(0, 5)..lineTo(size.width/2, 12)..lineTo(size.width, 5)
      ..lineTo(size.width, 50)..lineTo(size.width/2, 57)..lineTo(0, 50)..close();
    canvas.drawPath(path, Paint()..color = Colors.green[400]!);
    canvas.drawPath(path, stroke);
    canvas.drawLine(Offset(size.width/2, 12), Offset(size.width/2, 57), stroke);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}