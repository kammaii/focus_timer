import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

// ==========================================
// Focus Mode: FocusTiger (공부하는 호랑이)
// ==========================================
class FocusTiger extends StatefulWidget {
  const FocusTiger({super.key});

  @override
  State<FocusTiger> createState() => _FocusTigerState();
}

class _FocusTigerState extends State<FocusTiger> with TickerProviderStateMixin {
  late AnimationController _eyeController;
  late AnimationController _stripeController;
  late Animation<double> _eyeAnimation;
  late Animation<double> _stripeAnimation;
  bool _isSurprised = false;

  @override
  void initState() {
    super.initState();
    _eyeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _eyeAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(CurvedAnimation(parent: _eyeController, curve: Curves.easeInOut));
    _stripeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _stripeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _stripeController, curve: Curves.elasticOut));
  }

  void _onTapTiger() async {
    if (_isSurprised) return;
    setState(() => _isSurprised = true);
    await _stripeController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      await _stripeController.reverse();
      setState(() => _isSurprised = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapTiger,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_eyeController, _stripeController]),
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(150, 150),
                  painter: _FocusTigerPainter(
                    eyeX: _eyeAnimation.value,
                    stripeProgress: _stripeAnimation.value,
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
    _stripeController.dispose();
    super.dispose();
  }
}

class _FocusTigerPainter extends CustomPainter {
  final double eyeX, stripeProgress;
  final bool isSurprised;

  _FocusTigerPainter({required this.eyeX, required this.stripeProgress, required this.isSurprised});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.orange[700]!;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 - 25);

    // 1. 귀
    for (int i in [-1, 1]) {
      canvas.drawCircle(Offset(i * 35, -35), 15, bodyPaint);
      canvas.drawCircle(Offset(i * 35, -35), 15, strokePaint);
    }

    // 2. 몸통
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-45, -30, 90, 85), const Radius.circular(35)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-45, -30, 90, 85), const Radius.circular(35)), strokePaint);

    // 3. 통합 무늬 (이마 王 + 볼 줄무늬)
    _drawUnifiedStripes(canvas, strokePaint, stripeProgress);

    // 4. 얼굴
    if (isSurprised) {
      canvas.drawCircle(const Offset(-18, -10), 9, strokePaint);
      canvas.drawCircle(const Offset(18, -10), 9, strokePaint);
      canvas.drawCircle(const Offset(-18, -10), 3, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(18, -10), 3, Paint()..color = Colors.black);
      canvas.drawArc(const Rect.fromLTWH(-10, 5, 20, 15), 0, math.pi, true, Paint()..color = Colors.pink[100]!);
    } else {
      canvas.drawCircle(const Offset(-18, -10), 14, strokePaint);
      canvas.drawCircle(const Offset(18, -10), 14, strokePaint);
      canvas.drawLine(const Offset(-4, -10), const Offset(4, -10), strokePaint);
      canvas.drawCircle(Offset(-18 + eyeX, -10), 2.5, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(18 + eyeX, -10), 2.5, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(0, 5), 3, Paint()..color = Colors.black);
    }
  }

  void _drawUnifiedStripes(Canvas canvas, Paint stroke, double progress) {
    // 이마 '王'자 무늬 (Idle 위치와 동일하게 적용)
    canvas.drawLine(const Offset(-6, -22), const Offset(6, -22), stroke);
    canvas.drawLine(const Offset(-4, -17), const Offset(4, -17), stroke);
    canvas.drawLine(const Offset(0, -24), const Offset(0, -15), stroke);

    // 볼 무늬 (Focus 스타일 적용)
    double s = 5 * progress;
    for (int i in [-1, 1]) {
      canvas.drawLine(Offset(i * 45, -10), Offset(i * (30 - s), -5), stroke);
      canvas.drawLine(Offset(i * 45, 10), Offset(i * (30 - s), 15), stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _FocusTigerPainter oldDelegate) => true;
}

// ==========================================
// Rest Mode: RestTiger (고기 먹는 호랑이)
// ==========================================
class RestTiger extends StatefulWidget {
  const RestTiger({super.key});

  @override
  State<RestTiger> createState() => _RestTigerState();
}

class _RestTigerState extends State<RestTiger> with TickerProviderStateMixin {
  late AnimationController _munchController, _shareController;
  late Animation<double> _munchAnimation, _shareAnimation;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _munchController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250))..repeat(reverse: true);
    _munchAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(CurvedAnimation(parent: _munchController, curve: Curves.easeInOut));
    _shareController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shareAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _shareController, curve: Curves.elasticOut));
  }

  void _onTapTiger() async {
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
      onTap: _onTapTiger,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_munchController, _shareController]),
          builder: (context, child) {
            return CustomPaint(
              size: const Size(150, 150),
              painter: _RestTigerPainter(
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

class _RestTigerPainter extends CustomPainter {
  final double munchOffset, shareProgress;
  final bool isSharing;

  _RestTigerPainter({required this.munchOffset, required this.shareProgress, required this.isSharing});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.orange[700]!;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 + 10);
    canvas.scale(0.85, 0.85);

    for (int i in [-1, 1]) {
      canvas.drawCircle(Offset(i * 40, -55), 15, bodyPaint);
      canvas.drawCircle(Offset(i * 40, -55), 15, stroke);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-50, -60, 100, 110), const Radius.circular(40)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-50, -60, 100, 110), const Radius.circular(40)), stroke);

    // 통합 무늬 & 얼굴
    _drawUnifiedRestFace(canvas, stroke, shareProgress);

    canvas.save();
    canvas.translate(0, 15 * shareProgress);
    canvas.scale(1.0 + (0.12 * shareProgress));
    _drawSteak(canvas, stroke);
    canvas.drawCircle(const Offset(-22, 15), 12, bodyPaint); canvas.drawCircle(const Offset(-22, 15), 12, stroke);
    canvas.drawCircle(const Offset(22, 15), 12, bodyPaint); canvas.drawCircle(const Offset(22, 15), 12, stroke);
    canvas.restore();
  }

  void _drawUnifiedRestFace(Canvas canvas, Paint stroke, double progress) {
    // 이마 '王'자 무늬 (Idle 위치와 동일하게 적용)
    canvas.drawLine(const Offset(-6, -50), const Offset(6, -50), stroke);
    canvas.drawLine(const Offset(-4, -45), const Offset(4, -45), stroke);
    canvas.drawLine(const Offset(0, -52), const Offset(0, -43), stroke);

    double s = 5 * progress;
    for (int i in [-1, 1]) {
      canvas.drawPath(Path()..moveTo(i * 22 - 7, -40)..quadraticBezierTo(i * 22, -48, i * 22 + 7, -40), stroke);
      // 볼 무늬 (Focus 스타일 적용)
      canvas.drawLine(Offset(i * 50, -25), Offset(i * (35 - s), -20), stroke);
      canvas.drawLine(Offset(i * 50, -5), Offset(i * (35 - s), 0), stroke);
    }
    // 오물거리는 코
    canvas.drawCircle(Offset(0, -15 + (munchOffset * 0.5)), 4, Paint()..color = Colors.black);
  }

  void _drawSteak(Canvas canvas, Paint stroke) {
    final meatPaint = Paint()..color = Colors.redAccent;
    canvas.drawOval(const Rect.fromLTWH(-25, 20, 50, 35), meatPaint);
    canvas.drawOval(const Rect.fromLTWH(-25, 20, 50, 35), stroke);
    canvas.drawCircle(const Offset(15, 37), 8, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(15, 37), 8, stroke);
  }

  @override
  bool shouldRepaint(covariant _RestTigerPainter oldDelegate) => true;
}

// ==========================================
// Idle Mode: IdleTiger (하트 뿅뿅 호랑이)
// ==========================================
class IdleTiger extends StatefulWidget {
  const IdleTiger({super.key});

  @override
  State<IdleTiger> createState() => _IdleTigerState();
}

class _IdleTigerState extends State<IdleTiger> with TickerProviderStateMixin {
  late AnimationController _bodyController;
  late Animation<double> _bodyAnimation;
  final List<HeartParticle> _hearts = [];
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
        speedY: 2.0, speedX: (math.Random().nextDouble() - 0.5) * 2,
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
            painter: _IdleTigerPainter(
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

class _IdleTigerPainter extends CustomPainter {
  final double bodyOffset;
  final List<HeartParticle> hearts;
  final bool isShowingLove;

  _IdleTigerPainter({required this.bodyOffset, required this.hearts, required this.isShowingLove});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.orange[700]!;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 - 15 + bodyOffset);

    for (var h in hearts) _drawHeart(canvas, h);

    for (int i in [-1, 1]) {
      canvas.drawCircle(Offset(i * 35, -30), 15, bodyPaint);
      canvas.drawCircle(Offset(i * 35, -30), 15, stroke);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-40, -30, 80, 85), const Radius.circular(30)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-40, -30, 80, 85), const Radius.circular(30)), stroke);

    // 통합 무늬 그리기
    _drawUnifiedIdleStripes(canvas, stroke);

    if (isShowingLove) {
      _drawHappyFace(canvas, stroke);
    } else {
      canvas.drawCircle(const Offset(-16, -10), 4.5, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(16, -10), 4.5, Paint()..color = Colors.black);
    }
    canvas.drawCircle(const Offset(0, 5), 4, Paint()..color = Colors.black);
  }

  void _drawUnifiedIdleStripes(Canvas canvas, Paint stroke) {
    // 이마 '王'자 무늬
    canvas.drawLine(const Offset(-6, -22), const Offset(6, -22), stroke);
    canvas.drawLine(const Offset(-4, -17), const Offset(4, -17), stroke);
    canvas.drawLine(const Offset(0, -24), const Offset(0, -15), stroke);

    // 볼 무늬 (Focus 스타일 적용)
    for (int i in [-1, 1]) {
      canvas.drawLine(Offset(i * 45, -10), Offset(i * 30, -5), stroke);
      canvas.drawLine(Offset(i * 45, 10), Offset(i * 30, 15), stroke);
    }
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
  bool shouldRepaint(covariant _IdleTigerPainter oldDelegate) => true;
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
    canvas.drawPath(path, Paint()..color = Colors.orange[900]!);
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