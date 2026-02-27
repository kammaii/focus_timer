import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

// ==========================================
// Focus Mode: FocusSquirrel (공부하는 다람쥐)
// ==========================================
class FocusSquirrel extends StatefulWidget {
  const FocusSquirrel({super.key});

  @override
  State<FocusSquirrel> createState() => _FocusSquirrelState();
}

class _FocusSquirrelState extends State<FocusSquirrel> with TickerProviderStateMixin {
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
    _earController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _earAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _earController, curve: Curves.elasticOut));
  }

  void _onTapSquirrel() async {
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
      onTap: _onTapSquirrel,
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
                  painter: _FocusSquirrelPainter(
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

class _FocusSquirrelPainter extends CustomPainter {
  final double eyeX, earProgress;
  final bool isSurprised;

  _FocusSquirrelPainter({required this.eyeX, required this.earProgress, required this.isSurprised});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.orange[800]!;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
    canvas.translate(size.width / 2, size.height / 2 - 30);

    _drawTail(canvas, bodyPaint, strokePaint);
    _drawSquirrelEar(canvas, bodyPaint, strokePaint, earProgress, isLeft: true);
    _drawSquirrelEar(canvas, bodyPaint, strokePaint, earProgress, isLeft: false);

    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-40, -30, 80, 80), const Radius.circular(30)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-40, -30, 80, 80), const Radius.circular(30)), strokePaint);

    if (isSurprised) {
      canvas.drawCircle(const Offset(-16, -10), 9, strokePaint);
      canvas.drawCircle(const Offset(16, -10), 9, strokePaint);
      canvas.drawCircle(const Offset(-16, -10), 3, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(16, -10), 3, Paint()..color = Colors.black);
    } else {
      canvas.drawCircle(const Offset(-17, -10), 12, strokePaint);
      canvas.drawCircle(const Offset(17, -10), 12, strokePaint);
      canvas.drawLine(const Offset(-5, -10), const Offset(5, -10), strokePaint);
      canvas.drawCircle(Offset(-17 + eyeX, -10), 2.5, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(17 + eyeX, -10), 2.5, Paint()..color = Colors.black);
    }
    canvas.drawCircle(const Offset(0, 5), 2, Paint()..color = Colors.black);
    _drawWhiskers(canvas, strokePaint);
  }

  void _drawTail(Canvas canvas, Paint fill, Paint stroke) {
    Path p = Path()..moveTo(20, 40)..quadraticBezierTo(70, 20, 60, -40)..quadraticBezierTo(50, -80, 20, -60)..quadraticBezierTo(0, -40, 15, -10)..close();
    canvas.drawPath(p, fill); canvas.drawPath(p, stroke);
  }

  void _drawSquirrelEar(Canvas canvas, Paint fill, Paint stroke, double progress, {required bool isLeft}) {
    canvas.save();
    double x = isLeft ? -30 : 30;
    canvas.translate(x, -25);
    canvas.rotate(isLeft ? -progress * 0.1 : progress * 0.1);
    canvas.drawOval(const Rect.fromLTWH(-10, -20, 20, 25), fill);
    canvas.drawOval(const Rect.fromLTWH(-10, -20, 20, 25), stroke);
    canvas.restore();
  }

  void _drawWhiskers(Canvas canvas, Paint stroke) {
    for (int i in [-1, 1]) {
      canvas.drawLine(Offset(i * 35, 5), Offset(i * 50, 2), stroke);
      canvas.drawLine(Offset(i * 35, 10), Offset(i * 50, 13), stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _FocusSquirrelPainter oldDelegate) => true;
}

// ==========================================
// Rest Mode: RestSquirrel (도토리 먹는 다람쥐)
// ==========================================
class RestSquirrel extends StatefulWidget {
  const RestSquirrel({super.key});

  @override
  State<RestSquirrel> createState() => _RestSquirrelState();
}

class _RestSquirrelState extends State<RestSquirrel> with TickerProviderStateMixin {
  late AnimationController _munchController, _shareController;
  late Animation<double> _munchAnimation, _shareAnimation;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _munchController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))..repeat(reverse: true);
    _munchAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(CurvedAnimation(parent: _munchController, curve: Curves.easeInOut));
    _shareController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shareAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _shareController, curve: Curves.elasticOut));
  }

  void _onTapSquirrel() async {
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
      onTap: _onTapSquirrel,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_munchController, _shareController]),
          builder: (context, child) {
            return CustomPaint(
              size: const Size(150, 150),
              painter: _RestSquirrelPainter(
                munchOffset: _munchAnimation.value,
                shareProgress: _shareAnimation.value,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() { _munchController.dispose(); _shareController.dispose(); super.dispose(); }
}

class _RestSquirrelPainter extends CustomPainter {
  final double munchOffset, shareProgress;

  _RestSquirrelPainter({required this.munchOffset, required this.shareProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.orange[800]!;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
    canvas.translate(size.width / 2, size.height / 2 + 10);
    canvas.scale(0.8, 0.8);

    _drawTail(canvas, bodyPaint, stroke);
    _drawSquirrelEar(canvas, bodyPaint, stroke, shareProgress, isLeft: true);
    _drawSquirrelEar(canvas, bodyPaint, stroke, shareProgress, isLeft: false);

    Rect bodyRect = const Rect.fromLTWH(-50, -60, 100, 110);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(40)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(40)), stroke);

    for (int i in [-1, 1]) {
      canvas.drawPath(Path()..moveTo(i * 25 - 8, -45)..quadraticBezierTo(i * 25, -53, i * 25 + 8, -40), stroke);
    }
    // 입과 수염
    canvas.drawCircle(Offset(0, -25 + (munchOffset * 0.5)), 3, Paint()..color = Colors.pink[100]!);
    _drawWhiskers(canvas, stroke);

    canvas.save();
    canvas.translate(0, 15 * shareProgress);
    canvas.scale(1.0 + (0.15 * shareProgress));
    _drawAcorn(canvas, stroke);
    canvas.drawCircle(const Offset(-20, 10), 12, bodyPaint); canvas.drawCircle(const Offset(-20, 10), 12, stroke);
    canvas.drawCircle(const Offset(20, 10), 12, bodyPaint); canvas.drawCircle(const Offset(20, 10), 12, stroke);
    canvas.restore();
  }

  void _drawTail(Canvas canvas, Paint fill, Paint stroke) {
    Path p = Path()..moveTo(35, 30)..quadraticBezierTo(90, 10, 80, -50)..quadraticBezierTo(70, -90, 40, -70)..quadraticBezierTo(20, -50, 35, -20)..close();
    canvas.drawPath(p, fill); canvas.drawPath(p, stroke);
  }

  void _drawSquirrelEar(Canvas canvas, Paint fill, Paint stroke, double progress, {required bool isLeft}) {
    canvas.save();
    canvas.translate(isLeft ? -35 : 35, -55);
    canvas.rotate(isLeft ? -0.1 + math.sin(progress * 10) * 0.05 : 0.1 + math.sin(progress * 10) * 0.05);
    canvas.drawOval(const Rect.fromLTWH(-10, -15, 20, 22), fill);
    canvas.drawOval(const Rect.fromLTWH(-10, -15, 20, 22), stroke);
    canvas.restore();
  }

  void _drawWhiskers(Canvas canvas, Paint stroke) {
    for (int i in [-1, 1]) {
      // Rest 모드 얼굴 위치에 맞춰 Y축 조정
      canvas.drawLine(Offset(i * 45, -25), Offset(i * 60, -28), stroke);
      canvas.drawLine(Offset(i * 45, -20), Offset(i * 60, -17), stroke);
    }
  }

  void _drawAcorn(Canvas canvas, Paint stroke) {
    final acornBody = Paint()..color = Colors.brown[400]!;
    final acornCap = Paint()..color = Colors.brown[800]!;
    canvas.drawOval(const Rect.fromLTWH(-15, -5, 30, 35), acornBody);
    canvas.drawOval(const Rect.fromLTWH(-15, -5, 30, 35), stroke);
    canvas.drawArc(const Rect.fromLTWH(-18, -10, 36, 25), math.pi, math.pi, true, acornCap);
    canvas.drawArc(const Rect.fromLTWH(-18, -10, 36, 25), math.pi, math.pi, true, stroke);
  }

  @override
  bool shouldRepaint(covariant _RestSquirrelPainter oldDelegate) => true;
}

// ==========================================
// Idle Mode: IdleSquirrel (하트 뿅뿅 다람쥐)
// ==========================================
class IdleSquirrel extends StatefulWidget {
  const IdleSquirrel({super.key});

  @override
  State<IdleSquirrel> createState() => _IdleSquirrelState();
}

class _IdleSquirrelState extends State<IdleSquirrel> with TickerProviderStateMixin {
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
        position: const Offset(0, -50), size: 15, angle: 0,
        speedY: 2, speedX: (math.Random().nextDouble() - 0.5) * 2,
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
            painter: _IdleSquirrelPainter(
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
  void dispose() { _bodyController.dispose(); super.dispose(); }
}

class _IdleSquirrelPainter extends CustomPainter {
  final double bodyOffset;
  final List<HeartParticle> hearts;
  final bool isShowingLove;

  _IdleSquirrelPainter({required this.bodyOffset, required this.hearts, required this.isShowingLove});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.orange[800]!;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
    canvas.translate(size.width / 2, size.height / 2 - 15 + bodyOffset);

    for (var h in hearts) _drawHeart(canvas, h);
    _drawTail(canvas, bodyPaint, stroke);
    _drawSquirrelEar(canvas, bodyPaint, stroke, isLeft: true);
    _drawSquirrelEar(canvas, bodyPaint, stroke, isLeft: false);

    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-40, -30, 80, 85), const Radius.circular(30)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-40, -30, 80, 85), const Radius.circular(30)), stroke);

    if (isShowingLove) {
      _drawHappyFace(canvas, stroke);
    } else {
      canvas.drawCircle(const Offset(-16, -10), 4, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(16, -10), 4, Paint()..color = Colors.black);
    }
    canvas.drawCircle(const Offset(0, 5), 2, Paint()..color = Colors.black);
    _drawWhiskers(canvas, stroke);
  }

  void _drawTail(Canvas canvas, Paint fill, Paint stroke) {
    Path p = Path()..moveTo(25, 35)..quadraticBezierTo(75, 15, 65, -35)..quadraticBezierTo(55, -75, 25, -55)..quadraticBezierTo(5, -35, 20, -10)..close();
    canvas.drawPath(p, fill); canvas.drawPath(p, stroke);
  }

  void _drawSquirrelEar(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    canvas.save();
    canvas.translate(isLeft ? -30 : 30, -25);
    canvas.rotate(isLeft ? -0.1 : 0.1);
    canvas.drawOval(const Rect.fromLTWH(-10, -18, 20, 22), fill);
    canvas.drawOval(const Rect.fromLTWH(-10, -18, 20, 22), stroke);
    canvas.restore();
  }

  void _drawWhiskers(Canvas canvas, Paint stroke) {
    for (int i in [-1, 1]) {
      canvas.drawLine(Offset(i * 35, 5), Offset(i * 50, 2), stroke);
      canvas.drawLine(Offset(i * 35, 10), Offset(i * 50, 13), stroke);
    }
  }

  void _drawHappyFace(Canvas canvas, Paint stroke) {
    for (int i in [-1, 1]) {
      canvas.drawPath(Path()..moveTo(i * 16 - 6, -12)..quadraticBezierTo(i * 16, -18, i * 16 + 6, -12), stroke);
    }
    canvas.drawArc(const Rect.fromLTWH(-5, 5, 10, 10), 0, math.pi, false, stroke);
  }

  void _drawHeart(Canvas canvas, HeartParticle h) {
    final p = Paint()..color = Colors.pinkAccent.withOpacity(h.opacity);
    canvas.save(); canvas.translate(h.position.dx, h.position.dy); canvas.scale(h.size / 20);
    Path path = Path()..moveTo(0, 5)..cubicTo(0, -5, -10, -5, -10, 0)..cubicTo(-10, 10, 0, 15, 0, 20)..cubicTo(0, 15, 10, 10, 10, 0)..cubicTo(10, -5, 0, -5, 0, 5)..close();
    canvas.drawPath(path, p); canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IdleSquirrelPainter oldDelegate) => true;
}

// (이하 도서 페인터 및 입자 클래스 동일)
class _StaticBookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(0, 5, size.width, 40), Paint()..color = Colors.white);
    Path path = Path()..moveTo(0, 5)..lineTo(size.width/2, 12)..lineTo(size.width, 5)..lineTo(size.width, 50)..lineTo(size.width/2, 57)..lineTo(0, 50)..close();
    canvas.drawPath(path, Paint()..color = Colors.blue[800]!);
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