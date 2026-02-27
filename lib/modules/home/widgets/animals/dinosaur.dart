import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

// ==========================================
// Focus Mode: FocusDino (공부하는 공룡)
// ==========================================
class FocusDino extends StatefulWidget {
  const FocusDino({super.key});

  @override
  State<FocusDino> createState() => _FocusDinoState();
}

class _FocusDinoState extends State<FocusDino> with TickerProviderStateMixin {
  late AnimationController _eyeController;
  late AnimationController _spikeController;
  late Animation<double> _eyeAnimation;
  late Animation<double> _spikeAnimation;
  bool _isSurprised = false;

  @override
  void initState() {
    super.initState();
    _eyeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _eyeAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(CurvedAnimation(parent: _eyeController, curve: Curves.easeInOut));
    _spikeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _spikeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _spikeController, curve: Curves.elasticOut));
  }

  void _onTapDino() async {
    if (_isSurprised) return;
    setState(() => _isSurprised = true);
    await _spikeController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      await _spikeController.reverse();
      setState(() => _isSurprised = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapDino,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_eyeController, _spikeController]),
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(150, 150),
                  painter: _FocusDinoPainter(
                    eyeX: _eyeAnimation.value,
                    spikeProgress: _spikeAnimation.value,
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
    _spikeController.dispose();
    super.dispose();
  }
}

class _FocusDinoPainter extends CustomPainter {
  final double eyeX, spikeProgress;
  final bool isSurprised;

  _FocusDinoPainter({required this.eyeX, required this.spikeProgress, required this.isSurprised});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.lime[700]!;
    final bellyPaint = Paint()..color = Colors.lime[100]!;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 - 20);

    // 1. 꼬리와 등/머리 골판 (뿔)
    _drawTailAndSpikes(canvas, bodyPaint, strokePaint, spikeProgress);

    // 2. 몸통
    Path bodyPath = Path();
    bodyPath.moveTo(-45, 50);
    bodyPath.quadraticBezierTo(-50, -40, 0, -50);
    bodyPath.quadraticBezierTo(50, -40, 45, 50);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(bodyPath, strokePaint);

    // 배 부분
    canvas.drawOval(const Rect.fromLTWH(-25, 10, 50, 40), bellyPaint);

    // 3. 얼굴
    if (isSurprised) {
      canvas.drawCircle(const Offset(-18, -15), 9, strokePaint);
      canvas.drawCircle(const Offset(18, -15), 9, strokePaint);
      canvas.drawCircle(const Offset(-18, -15), 3, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(18, -15), 3, Paint()..color = Colors.black);
    } else {
      canvas.drawCircle(const Offset(-18, -15), 14, strokePaint);
      canvas.drawCircle(const Offset(18, -15), 14, strokePaint);
      canvas.drawLine(const Offset(-4, -15), const Offset(4, -15), strokePaint);
      canvas.drawCircle(Offset(-18 + eyeX, -15), 2.5, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(18 + eyeX, -15), 2.5, Paint()..color = Colors.black);
    }
    canvas.drawCircle(const Offset(-4, 0), 1.5, Paint()..color = Colors.black);
    canvas.drawCircle(const Offset(4, 0), 1.5, Paint()..color = Colors.black);
  }

  void _drawTailAndSpikes(Canvas canvas, Paint body, Paint stroke, double progress) {
    // 꼬리
    Path tail = Path()
      ..moveTo(-30, 30)
      ..quadraticBezierTo(-70, 40, -60, 10)
      ..quadraticBezierTo(-55, 0, -35, 10)..close();
    canvas.drawPath(tail, body);
    canvas.drawPath(tail, stroke);

    // 골판 (머리 위 뿔 포함)
    final spikePaint = Paint()..color = Colors.orange[800]!;
    for (int i = 0; i < 3; i++) {
      double x = -15.0 + (i * 15);
      double y = -45.0 - (i * 2);
      Path p = Path()
        ..moveTo(x, y)
        ..lineTo(x + 7, y - 15 - (progress * 10))
        ..lineTo(x + 14, y)..close();
      canvas.drawPath(p, spikePaint);
      canvas.drawPath(p, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _FocusDinoPainter oldDelegate) => true;
}

// ==========================================
// Rest Mode: RestDino (나뭇잎 먹는 공룡)
// ==========================================
class RestDino extends StatefulWidget {
  const RestDino({super.key});

  @override
  State<RestDino> createState() => _RestDinoState();
}

class _RestDinoState extends State<RestDino> with TickerProviderStateMixin {
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

  void _onTapDino() async {
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
      onTap: _onTapDino,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_munchController, _shareController]),
          builder: (context, child) {
            return CustomPaint(
              size: const Size(150, 150),
              painter: _RestDinoPainter(
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

class _RestDinoPainter extends CustomPainter {
  final double munchOffset, shareProgress;
  final bool isSharing;

  _RestDinoPainter({required this.munchOffset, required this.shareProgress, required this.isSharing});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.lime[700]!;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 + 10);
    canvas.scale(0.85, 0.85);

    // 1. 머리 뿔 (Idle에서 가져옴)
    _drawHeadSpikes(canvas, stroke);

    // 2. 꼬리와 몸통
    _drawDinoBody(canvas, bodyPaint, stroke);

    // 3. 얼굴
    for (int i in [-1, 1]) {
      canvas.drawPath(Path()..moveTo(i * 22 - 7, -35)..quadraticBezierTo(i * 22, -43, i * 22 + 7, -35), stroke);
    }
    canvas.drawCircle(Offset(0, -10 + (munchOffset * 0.5)), 3, Paint()..color = Colors.black);

    // 4. 나뭇잎 & 앞발
    canvas.save();
    canvas.translate(0, 15 * shareProgress);
    canvas.scale(1.0 + (0.15 * shareProgress));
    _drawLargeLeaf(canvas, stroke);
    canvas.drawCircle(const Offset(-15, 10), 8, bodyPaint); canvas.drawCircle(const Offset(-15, 10), 8, stroke);
    canvas.drawCircle(const Offset(15, 10), 8, bodyPaint); canvas.drawCircle(const Offset(15, 10), 8, stroke);
    canvas.restore();
  }

  void _drawHeadSpikes(Canvas canvas, Paint stroke) {
    final sPaint = Paint()..color = Colors.orange[800]!;
    for (int i = 0; i < 3; i++) {
      double x = -15.0 + (i * 15);
      Path p = Path()..moveTo(x, -60)..lineTo(x + 5, -75)..lineTo(x + 10, -60)..close();
      canvas.drawPath(p, sPaint); canvas.drawPath(p, stroke);
    }
  }

  void _drawDinoBody(Canvas canvas, Paint body, Paint stroke) {
    Path tail = Path()..moveTo(35, 20)..quadraticBezierTo(75, 35, 70, 0)..quadraticBezierTo(65, -15, 45, -5)..close();
    canvas.drawPath(tail, body); canvas.drawPath(tail, stroke);
    Rect bodyRect = const Rect.fromLTWH(-45, -60, 90, 110);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(35)), body);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(35)), stroke);
  }

  void _drawLargeLeaf(Canvas canvas, Paint stroke) {
    final leafPaint = Paint()..color = Colors.green[600]!;
    Path leaf = Path()..moveTo(0, 35)..quadraticBezierTo(-25, 15, 0, -5)..quadraticBezierTo(25, 15, 0, 35)..close();
    canvas.drawPath(leaf, leafPaint);
    canvas.drawPath(leaf, stroke);
    canvas.drawLine(const Offset(0, 35), const Offset(0, 5), stroke);
  }

  @override
  bool shouldRepaint(covariant _RestDinoPainter oldDelegate) => true;
}

// ==========================================
// Idle Mode: IdleDino (하트 뿅뿅 공룡)
// ==========================================
class IdleDino extends StatefulWidget {
  const IdleDino({super.key});

  @override
  State<IdleDino> createState() => _IdleDinoState();
}

class _IdleDinoState extends State<IdleDino> with TickerProviderStateMixin {
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
        position: const Offset(0, -50), size: 15, angle: 0,
        speedY: 2 + _random.nextDouble(), speedX: (_random.nextDouble() - 0.5) * 2,
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
            painter: _IdleDinoPainter(
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

class _IdleDinoPainter extends CustomPainter {
  final double bodyOffset;
  final List<HeartParticle> hearts;
  final bool isShowingLove;

  _IdleDinoPainter({required this.bodyOffset, required this.hearts, required this.isShowingLove});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.lime[700]!;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 - 15 + bodyOffset);

    for (var h in hearts) _drawHeart(canvas, h);

    // 꼬리와 머리 뿔 (Spikes)
    _drawTailAndSpikes(canvas, bodyPaint, stroke);

    // 몸통
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-40, -30, 80, 85), const Radius.circular(30)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-40, -30, 80, 85), const Radius.circular(30)), stroke);

    // 얼굴
    if (isShowingLove) {
      _drawHappyFace(canvas, stroke);
    } else {
      canvas.drawCircle(const Offset(-16, -10), 4, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(16, -10), 4, Paint()..color = Colors.black);
    }
    canvas.drawCircle(const Offset(-3, 2), 1.5, Paint()..color = Colors.black);
    canvas.drawCircle(const Offset(3, 2), 1.5, Paint()..color = Colors.black);
  }

  void _drawTailAndSpikes(Canvas canvas, Paint fill, Paint stroke) {
    Path tail = Path()..moveTo(-30, 35)..quadraticBezierTo(-65, 45, -55, 15)..quadraticBezierTo(-50, 5, -30, 15)..close();
    canvas.drawPath(tail, fill); canvas.drawPath(tail, stroke);

    final sPaint = Paint()..color = Colors.orange[800]!;
    for (int i = 0; i < 3; i++) {
      double x = -10.0 + (i * 12);
      Path p = Path()..moveTo(x, -30)..lineTo(x + 5, -42)..lineTo(x + 10, -30)..close();
      canvas.drawPath(p, sPaint); canvas.drawPath(p, stroke);
    }
  }

  void _drawHappyFace(Canvas canvas, Paint stroke) {
    for (int i in [-1, 1]) {
      canvas.drawPath(Path()..moveTo(i * 16 - 6, -12)..quadraticBezierTo(i * 16, -18, i * 16 + 6, -12), stroke);
    }
    canvas.drawArc(const Rect.fromLTWH(-5, 8, 10, 10), 0, math.pi, false, stroke);
  }

  void _drawHeart(Canvas canvas, HeartParticle h) {
    final p = Paint()..color = Colors.pinkAccent.withOpacity(h.opacity);
    canvas.save(); canvas.translate(h.position.dx, h.position.dy); canvas.scale(h.size / 20);
    Path path = Path()..moveTo(0, 5)..cubicTo(0, -5, -10, -5, -10, 0)..cubicTo(-10, 10, 0, 15, 0, 20)..cubicTo(0, 15, 10, 10, 10, 0)..cubicTo(10, -5, 0, -5, 0, 5)..close();
    canvas.drawPath(path, p); canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IdleDinoPainter oldDelegate) => true;
}

// ---------------------------------------------------------
class _StaticBookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(0, 5, size.width, 40), Paint()..color = Colors.white);
    Path path = Path()..moveTo(0, 5)..lineTo(size.width/2, 12)..lineTo(size.width, 5)..lineTo(size.width, 50)..lineTo(size.width/2, 57)..lineTo(0, 50)..close();
    canvas.drawPath(path, Paint()..color = Colors.teal[600]!);
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