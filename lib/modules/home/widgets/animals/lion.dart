import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

// ==========================================
// Focus Mode: FocusLion (공부하는 사자왕)
// ==========================================
class FocusLion extends StatefulWidget {
  const FocusLion({super.key});

  @override
  State<FocusLion> createState() => _FocusLionState();
}

class _FocusLionState extends State<FocusLion> with TickerProviderStateMixin {
  late AnimationController _eyeController;
  late AnimationController _maneController;
  late Animation<double> _eyeAnimation;
  late Animation<double> _maneAnimation;
  bool _isSurprised = false;

  @override
  void initState() {
    super.initState();
    _eyeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _eyeAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(CurvedAnimation(parent: _eyeController, curve: Curves.easeInOut));
    _maneController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _maneAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _maneController, curve: Curves.elasticOut));
  }

  void _onTapLion() async {
    if (_isSurprised) return;
    setState(() => _isSurprised = true);
    await _maneController.forward(); // 갈기가 위엄있게 확장됨
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      await _maneController.reverse();
      setState(() => _isSurprised = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapLion,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_eyeController, _maneController]),
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(150, 150),
                  painter: _FocusLionPainter(
                    eyeX: _eyeAnimation.value,
                    maneScale: _maneAnimation.value,
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
    _maneController.dispose();
    super.dispose();
  }
}

class _FocusLionPainter extends CustomPainter {
  final double eyeX, maneScale;
  final bool isSurprised;

  _FocusLionPainter({required this.eyeX, required this.maneScale, required this.isSurprised});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.amber[400]!;
    final manePaint = Paint()..color = Colors.orange[900]!;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 - 25);

    // 1. 갈기 (Mane - 얼굴 뒤에 위치)
    _drawMane(canvas, manePaint, strokePaint, maneScale);

    // 2. 몸통
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-45, -30, 90, 85), const Radius.circular(35)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-45, -30, 90, 85), const Radius.circular(35)), strokePaint);

    // 3. 왕관 (Crown - 왕의 상징)
    _drawCrown(canvas, strokePaint);

    // 4. 얼굴
    if (isSurprised) {
      canvas.drawCircle(const Offset(-18, -10), 9, strokePaint);
      canvas.drawCircle(const Offset(18, -10), 9, strokePaint);
      canvas.drawCircle(const Offset(-18, -10), 3, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(18, -10), 3, Paint()..color = Colors.black);
      // 포효하는 입
      canvas.drawOval(const Rect.fromLTWH(-10, 5, 20, 15), Paint()..color = Colors.brown[900]!);
    } else {
      // 안경
      canvas.drawCircle(const Offset(-18, -10), 14, strokePaint);
      canvas.drawCircle(const Offset(18, -10), 14, strokePaint);
      canvas.drawLine(const Offset(-4, -10), const Offset(4, -10), strokePaint);
      canvas.drawCircle(Offset(-18 + eyeX, -10), 2.5, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(18 + eyeX, -10), 2.5, Paint()..color = Colors.black);
      // 인자한 입술
      canvas.drawArc(const Rect.fromLTWH(-8, 5, 16, 8), 0, math.pi, false, strokePaint);
    }
    // 코
    canvas.drawCircle(const Offset(0, 5), 4, Paint()..color = Colors.brown[900]!);
  }

  void _drawMane(Canvas canvas, Paint fill, Paint stroke, double scale) {
    canvas.save();
    canvas.scale(scale);
    for (double i = 0; i < 2 * math.pi; i += math.pi / 6) {
      canvas.drawCircle(Offset(math.cos(i) * 52, math.sin(i) * 52), 22, fill);
      canvas.drawCircle(Offset(math.cos(i) * 52, math.sin(i) * 52), 22, stroke);
    }
    canvas.restore();
  }

  void _drawCrown(Canvas canvas, Paint stroke) {
    final goldPaint = Paint()..color = Colors.yellow[700]!;
    Path crown = Path()
      ..moveTo(-15, -45)..lineTo(-20, -60)..lineTo(-10, -53)..lineTo(0, -65)
      ..lineTo(10, -53)..lineTo(20, -60)..lineTo(15, -45)..close();
    canvas.drawPath(crown, goldPaint);
    canvas.drawPath(crown, stroke);
  }

  @override
  bool shouldRepaint(covariant _FocusLionPainter oldDelegate) => true;
}

// ==========================================
// Rest Mode: RestLion (스테이크 먹는 사자)
// ==========================================
class RestLion extends StatefulWidget {
  const RestLion({super.key});

  @override
  State<RestLion> createState() => _RestLionState();
}

class _RestLionState extends State<RestLion> with TickerProviderStateMixin {
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

  void _onTapLion() async {
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
      onTap: _onTapLion,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_munchController, _shareController]),
          builder: (context, child) {
            return CustomPaint(
              size: const Size(150, 150),
              painter: _RestLionPainter(
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
}

class _RestLionPainter extends CustomPainter {
  final double munchOffset, shareProgress;
  final bool isSharing;

  _RestLionPainter({required this.munchOffset, required this.shareProgress, required this.isSharing});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.amber[400]!;
    final manePaint = Paint()..color = Colors.orange[900]!;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 + 10);
    canvas.scale(0.85, 0.85);

    // 1. 갈기 & 몸통
    for (double i = 0; i < 2 * math.pi; i += math.pi / 6) {
      canvas.drawCircle(Offset(math.cos(i) * 55, math.sin(i) * 55 - 10), 22, manePaint);
      canvas.drawCircle(Offset(math.cos(i) * 55, math.sin(i) * 55 - 10), 22, stroke);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-50, -60, 100, 110), const Radius.circular(40)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-50, -60, 100, 110), const Radius.circular(40)), stroke);

    // 2. 얼굴 (행복한 눈)
    for (int i in [-1, 1]) {
      canvas.drawPath(Path()..moveTo(i * 22 - 7, -40)..quadraticBezierTo(i * 22, -48, i * 22 + 7, -40), stroke);
    }
    // 오물거리는 코
    canvas.drawCircle(Offset(0, -15 + (munchOffset * 0.4)), 4, Paint()..color = Colors.brown[900]!);

    // 3. 스테이크 & 앞발
    canvas.save();
    canvas.translate(0, 15 * shareProgress);
    canvas.scale(1.0 + (0.12 * shareProgress));

    _drawSteak(canvas, stroke);

    // 앞발
    canvas.drawCircle(const Offset(-25, 20), 15, bodyPaint); canvas.drawCircle(const Offset(-25, 20), 15, stroke);
    canvas.drawCircle(const Offset(25, 20), 15, bodyPaint); canvas.drawCircle(const Offset(25, 20), 15, stroke);
    canvas.restore();
  }

  void _drawSteak(Canvas canvas, Paint stroke) {
    final meatPaint = Paint()..color = Colors.red[800]!;
    final bonePaint = Paint()..color = Colors.white;
    // 고기 부분
    canvas.drawOval(const Rect.fromLTWH(-20, 15, 45, 30), meatPaint);
    canvas.drawOval(const Rect.fromLTWH(-20, 15, 45, 30), stroke);
    // 뼈 부분
    canvas.drawRect(const Rect.fromLTWH(15, 25, 15, 10), bonePaint);
    canvas.drawRect(const Rect.fromLTWH(15, 25, 15, 10), stroke);
  }

  @override
  bool shouldRepaint(covariant _RestLionPainter oldDelegate) => true;
}

// ==========================================
// Idle Mode: IdleLion (하트 뿅뿅 사자)
// ==========================================
class IdleLion extends StatefulWidget {
  const IdleLion({super.key});

  @override
  State<IdleLion> createState() => _IdleLionState();
}

class _IdleLionState extends State<IdleLion> with TickerProviderStateMixin {
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
        speedY: 2.0, speedX: (_random.nextDouble() - 0.5) * 2,
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
            painter: _IdleLionPainter(
              bodyOffset: _bodyAnimation.value,
              hearts: _hearts,
              isShowingLove: _isShowingLove,
            ),
          );
        },
      ),
    );
  }
}

class _IdleLionPainter extends CustomPainter {
  final double bodyOffset;
  final List<HeartParticle> hearts;
  final bool isShowingLove;

  _IdleLionPainter({required this.bodyOffset, required this.hearts, required this.isShowingLove});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.amber[400]!;
    final manePaint = Paint()..color = Colors.orange[900]!;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 - 15 + bodyOffset);

    for (var h in hearts) _drawHeart(canvas, h);

    // 갈기
    for (double i = 0; i < 2 * math.pi; i += math.pi / 5) {
      canvas.drawCircle(Offset(math.cos(i) * 50, math.sin(i) * 50), 20, manePaint);
      canvas.drawCircle(Offset(math.cos(i) * 50, math.sin(i) * 50), 20, stroke);
    }

    // 몸통
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-40, -30, 80, 85), const Radius.circular(30)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-40, -30, 80, 85), const Radius.circular(30)), stroke);

    // 얼굴
    if (isShowingLove) {
      _drawHappyFace(canvas, stroke);
    } else {
      canvas.drawCircle(const Offset(-16, -10), 4.5, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(16, -10), 4.5, Paint()..color = Colors.black);
    }
    canvas.drawCircle(const Offset(0, 5), 4, Paint()..color = Colors.brown[900]!);
  }

  void _drawHappyFace(Canvas canvas, Paint stroke) {
    for (int i in [-1, 1]) {
      canvas.drawPath(Path()..moveTo(i * 18 - 6, -12)..quadraticBezierTo(i * 18, -18, i * 18 + 6, -12), stroke);
    }
    canvas.drawArc(const Rect.fromLTWH(-5, 10, 10, 8), 0, math.pi, false, stroke);
  }

  void _drawHeart(Canvas canvas, HeartParticle h) {
    final p = Paint()..color = Colors.pinkAccent.withOpacity(h.opacity);
    canvas.save(); canvas.translate(h.position.dx, h.position.dy); canvas.scale(h.size / 20);
    Path path = Path()..moveTo(0, 5)..cubicTo(0, -5, -10, -5, -10, 0)..cubicTo(-10, 10, 0, 15, 0, 20)..cubicTo(0, 15, 10, 10, 10, 0)..cubicTo(10, -5, 0, -5, 0, 5)..close();
    canvas.drawPath(path, p); canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IdleLionPainter oldDelegate) => true;
}

// ---------------------------------------------------------
class _StaticBookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(0, 5, size.width, 40), Paint()..color = Colors.white);
    Path path = Path()
      ..moveTo(0, 5)..lineTo(size.width/2, 12)..lineTo(size.width, 5)
      ..lineTo(size.width, 50)..lineTo(size.width/2, 57)..lineTo(0, 50)..close();
    canvas.drawPath(path, Paint()..color = Colors.brown[700]!);
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