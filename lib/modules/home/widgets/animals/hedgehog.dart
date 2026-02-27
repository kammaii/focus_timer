import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

// ==========================================
// Focus Mode: FocusHedgehog (공부하는 고슴도치)
// ==========================================
class FocusHedgehog extends StatefulWidget {
  const FocusHedgehog({super.key});

  @override
  State<FocusHedgehog> createState() => _FocusHedgehogState();
}

class _FocusHedgehogState extends State<FocusHedgehog> with TickerProviderStateMixin {
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

  void _onTapHedgehog() async {
    if (_isSurprised) return;
    setState(() => _isSurprised = true);
    await _earController.forward(); // 가시가 움찔하는 연출로 활용
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      await _earController.reverse();
      setState(() => _isSurprised = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapHedgehog,
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
                  painter: _FocusHedgehogPainter(
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

class _FocusHedgehogPainter extends CustomPainter {
  final double eyeX;
  final double earProgress;
  final bool isSurprised;

  _FocusHedgehogPainter({required this.eyeX, required this.earProgress, required this.isSurprised});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.brown[200]!;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 - 20);

    // 1. 가시 (몸통 뒤쪽)
    _drawSpikes(canvas, strokePaint, earProgress);

    // 2. 몸통 (둥글둥글한 모양)
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 10), width: 90, height: 80), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 10), width: 90, height: 80), strokePaint);

    // 3. 얼굴 (안경/눈)
    if (isSurprised) {
      canvas.drawCircle(const Offset(-16, -5), 9, strokePaint);
      canvas.drawCircle(const Offset(16, -5), 9, strokePaint);
      canvas.drawCircle(const Offset(-16, -5), 3, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(16, -5), 3, Paint()..color = Colors.black);
    } else {
      // 돋보기안경 느낌
      canvas.drawCircle(const Offset(-18, -5), 13, strokePaint);
      canvas.drawCircle(const Offset(18, -5), 13, strokePaint);
      canvas.drawLine(const Offset(-5, -5), const Offset(5, -5), strokePaint);
      canvas.drawCircle(Offset(-18 + eyeX, -5), 2.5, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(18 + eyeX, -5), 2.5, Paint()..color = Colors.black);
    }
    // 코 (고슴도치 특유의 뾰족한 코 끝)
    canvas.drawCircle(const Offset(0, 15), 4, Paint()..color = Colors.black);
  }

  void _drawSpikes(Canvas canvas, Paint stroke, double progress) {
    // 위쪽 반원을 따라 가시 배치
    for (double i = -math.pi; i <= 0; i += 0.25) {
      double x1 = math.cos(i) * 40;
      double y1 = math.sin(i) * 40 + 10;
      // 터치 시 가시가 살짝 더 길어지거나 서는 연출
      double length = 15 + (progress * 10);
      double x2 = math.cos(i) * (40 + length);
      double y2 = math.sin(i) * (40 + length) + 10;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _FocusHedgehogPainter oldDelegate) => true;
}

// ==========================================
// Rest Mode: RestHedgehog (사과 먹는 고슴도치)
// ==========================================
class RestHedgehog extends StatefulWidget {
  const RestHedgehog({super.key});

  @override
  State<RestHedgehog> createState() => _RestHedgehogState();
}

class _RestHedgehogState extends State<RestHedgehog> with TickerProviderStateMixin {
  late AnimationController _munchController;
  late AnimationController _shareController;
  late Animation<double> _munchAnimation;
  late Animation<double> _shareAnimation;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _munchController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))..repeat(reverse: true);
    _munchAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(CurvedAnimation(parent: _munchController, curve: Curves.easeInOut));
    _shareController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shareAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _shareController, curve: Curves.elasticOut));
  }

  void _onTapHedgehog() async {
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
      onTap: _onTapHedgehog,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_munchController, _shareController]),
          builder: (context, child) {
            return CustomPaint(
              size: const Size(150, 150),
              painter: _RestHedgehogPainter(
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

class _RestHedgehogPainter extends CustomPainter {
  final double munchOffset;
  final double shareProgress;
  final bool isSharing;

  _RestHedgehogPainter({required this.munchOffset, required this.shareProgress, required this.isSharing});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.brown[200]!;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 + 10);
    canvas.scale(0.8, 0.8);

    // 1. 가시
    _drawSpikes(canvas, stroke, 0.0);

    // 2. 몸통
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 0), width: 100, height: 90), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 0), width: 100, height: 90), stroke);

    // 3. 얼굴 (행복한 눈)
    for (int i in [-1, 1]) {
      canvas.drawPath(Path()..moveTo(i * 20 - 7, -15)..quadraticBezierTo(i * 20, -22, i * 20 + 7, -15), stroke);
    }
    // 오물거리는 코/입
    canvas.drawCircle(Offset(0, 5 + (munchOffset * 0.5)), 4, Paint()..color = Colors.black);

    // 4. 사과 & 앞발
    canvas.save();
    canvas.translate(0, 15 * shareProgress);
    canvas.scale(1.0 + (0.15 * shareProgress));

    _drawApple(canvas, stroke);

    // 앞발
    canvas.drawCircle(const Offset(-25, 10), 10, bodyPaint); canvas.drawCircle(const Offset(-25, 10), 10, stroke);
    canvas.drawCircle(const Offset(25, 10), 10, bodyPaint); canvas.drawCircle(const Offset(25, 10), 10, stroke);
    canvas.restore();
  }

  void _drawSpikes(Canvas canvas, Paint stroke, double progress) {
    for (double i = -math.pi * 1.1; i <= 0.1; i += 0.2) {
      double x1 = math.cos(i) * 45;
      double y1 = math.sin(i) * 40;
      double x2 = math.cos(i) * 60;
      double y2 = math.sin(i) * 55;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), stroke);
    }
  }

  void _drawApple(Canvas canvas, Paint stroke) {
    final applePaint = Paint()..color = Colors.redAccent;
    canvas.drawCircle(const Offset(0, 25), 15, applePaint);
    canvas.drawCircle(const Offset(0, 25), 15, stroke);
    // 꼭지
    canvas.drawLine(const Offset(0, 10), const Offset(0, 5), stroke..strokeWidth = 2);
    canvas.drawOval(const Rect.fromLTWH(0, 3, 8, 4), Paint()..color = Colors.green);
  }

  @override
  bool shouldRepaint(covariant _RestHedgehogPainter oldDelegate) => true;
}

// ==========================================
// Idle Mode: IdleHedgehog (하트 뿅뿅 고슴도치)
// ==========================================
class IdleHedgehog extends StatefulWidget {
  const IdleHedgehog({super.key});

  @override
  State<IdleHedgehog> createState() => _IdleHedgehogState();
}

class _IdleHedgehogState extends State<IdleHedgehog> with TickerProviderStateMixin {
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
        position: const Offset(0, -40), size: 15, angle: 0,
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
            painter: _IdleHedgehogPainter(
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

class _IdleHedgehogPainter extends CustomPainter {
  final double bodyOffset;
  final List<HeartParticle> hearts;
  final bool isShowingLove;

  _IdleHedgehogPainter({required this.bodyOffset, required this.hearts, required this.isShowingLove});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.brown[200]!;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 - 10 + bodyOffset);

    // 하트
    for (var h in hearts) _drawHeart(canvas, h);

    // 가시
    for (double i = -math.pi * 1.05; i <= 0.05; i += 0.3) {
      double x1 = math.cos(i) * 40;
      double y1 = math.sin(i) * 35;
      double x2 = math.cos(i) * 52;
      double y2 = math.sin(i) * 47;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), stroke);
    }

    // 몸통
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 10), width: 85, height: 75), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 10), width: 85, height: 75), stroke);

    // 얼굴
    if (isShowingLove) {
      for (int i in [-1, 1]) {
        canvas.drawPath(Path()..moveTo(i * 15 - 5, -5)..quadraticBezierTo(i * 15, -10, i * 15 + 5, -5), stroke);
      }
      canvas.drawArc(const Rect.fromLTWH(-5, 5, 10, 8), 0, math.pi, false, stroke);
    } else {
      canvas.drawCircle(const Offset(-15, -5), 4, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(15, -5), 4, Paint()..color = Colors.black);
    }
    canvas.drawCircle(const Offset(0, 15), 4, Paint()..color = Colors.black);
  }

  void _drawHeart(Canvas canvas, HeartParticle h) {
    final p = Paint()..color = Colors.pinkAccent.withOpacity(h.opacity);
    canvas.save(); canvas.translate(h.position.dx, h.position.dy); canvas.scale(h.size / 20);
    Path path = Path()..moveTo(0, 5)..cubicTo(0, -5, -10, -5, -10, 0)..cubicTo(-10, 10, 0, 15, 0, 20)..cubicTo(0, 15, 10, 10, 10, 0)..cubicTo(10, -5, 0, -5, 0, 5)..close();
    canvas.drawPath(path, p); canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IdleHedgehogPainter oldDelegate) => true;
}

// ---------------------------------------------------------
// 도서 페인터 (고슴도치는 갈색과 어울리는 붉은색 도서)
class _StaticBookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(0, 5, size.width, 40), Paint()..color = Colors.white);
    Path path = Path()
      ..moveTo(0, 5)..lineTo(size.width/2, 12)..lineTo(size.width, 5)
      ..lineTo(size.width, 50)..lineTo(size.width/2, 57)..lineTo(0, 50)..close();
    canvas.drawPath(path, Paint()..color = Colors.red[400]!);
    canvas.drawPath(path, stroke);
    canvas.drawLine(Offset(size.width/2, 12), Offset(size.width/2, 57), stroke);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 하트 파티클 클래스
class HeartParticle {
  Offset position; double size; double angle; double opacity; double speedY; double speedX;
  HeartParticle({required this.position, required this.size, required this.angle, this.opacity = 1.0, required this.speedY, required this.speedX});
}