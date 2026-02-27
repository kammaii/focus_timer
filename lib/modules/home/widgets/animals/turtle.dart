import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

// ==========================================
// Focus Mode: FocusTurtle (공부하는 거북이)
// ==========================================
class FocusTurtle extends StatefulWidget {
  const FocusTurtle({super.key});

  @override
  State<FocusTurtle> createState() => _FocusTurtleState();
}

class _FocusTurtleState extends State<FocusTurtle> with TickerProviderStateMixin {
  late AnimationController _eyeController;
  late AnimationController _hideController;
  late Animation<double> _eyeAnimation;
  late Animation<double> _hideAnimation;
  bool _isHidden = false;

  @override
  void initState() {
    super.initState();
    _eyeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _eyeAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(CurvedAnimation(parent: _eyeController, curve: Curves.easeInOut));

    _hideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _hideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _hideController, curve: Curves.easeInOut));
  }

  void _onTapTurtle() async {
    if (_isHidden) return;
    setState(() => _isHidden = true);
    await _hideController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      await _hideController.reverse();
      setState(() => _isHidden = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapTurtle,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_eyeController, _hideController]),
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(150, 150),
                  painter: _FocusTurtlePainter(
                    eyeX: _eyeAnimation.value,
                    hideProgress: _hideAnimation.value,
                    isHidden: _isHidden,
                  ),
                );
              },
            ),
            Positioned(
              bottom: 5, // 책을 약간 더 아래로 배치
              child: CustomPaint(
                size: const Size(110, 50),
                painter: _ThickBookPainter(),
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
    _hideController.dispose();
    super.dispose();
  }
}

class _FocusTurtlePainter extends CustomPainter {
  final double eyeX, hideProgress;
  final bool isHidden;

  _FocusTurtlePainter({required this.eyeX, required this.hideProgress, required this.isHidden});

  @override
  void paint(Canvas canvas, Size size) {
    final shellPaint = Paint()..color = Colors.green[900]!;
    final skinPaint = Paint()..color = Colors.lightGreen[400]!;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    // 전체 위치를 살짝 위로 이동하여 가시성 확보
    canvas.translate(size.width / 2, size.height / 2 + 30);

    // 1. 다리 (안으로 쏙)
    double legOffset = 15 * hideProgress;
    for (int i in [-1, 1]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(i * (35 - legOffset), 35 - legOffset), width: 22, height: 16), skinPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(i * (35 - legOffset), 35 - legOffset), width: 22, height: 16), strokePaint);
    }

    // 2. 머리 (가시성 개선: 기존보다 15px 더 위로 배치)
    canvas.save();
    double headY = 45 * hideProgress;
    canvas.translate(0, headY);
    if (headY < 40) {
      Offset headPos = const Offset(0, -55); // 머리 위치를 더 위로 올림
      canvas.drawCircle(headPos, 28, skinPaint);
      canvas.drawCircle(headPos, 28, strokePaint);

      // 안경과 눈
      canvas.drawCircle(headPos + const Offset(-15, -5), 11, strokePaint);
      canvas.drawCircle(headPos + const Offset(15, -5), 11, strokePaint);
      canvas.drawLine(headPos + const Offset(-4, -5), headPos + const Offset(4, -5), strokePaint);
      canvas.drawCircle(headPos + Offset(-15 + eyeX, -5), 2.5, Paint()..color = Colors.black);
      canvas.drawCircle(headPos + Offset(15 + eyeX, -5), 2.5, Paint()..color = Colors.black);
    }
    canvas.restore();

    // 3. 등껍질
    _drawShell(canvas, shellPaint, strokePaint);
  }

  void _drawShell(Canvas canvas, Paint fill, Paint stroke) {
    Rect shellRect = Rect.fromCenter(center: const Offset(0, 10), width: 115, height: 90);
    canvas.drawOval(shellRect, fill);
    canvas.drawOval(shellRect, stroke);

    canvas.save();
    canvas.clipPath(Path()..addOval(shellRect));
    final patternPaint = Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 1.5;
    for (double i = -50; i <= 50; i += 25) {
      canvas.drawLine(Offset(-60, i + 10), Offset(60, i + 10), patternPaint);
      canvas.drawLine(Offset(i, -50), Offset(i, 60), patternPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FocusTurtlePainter oldDelegate) => true;
}

// ==========================================
// Rest Mode: RestTurtle (상추 먹는 거북이)
// ==========================================
class RestTurtle extends StatefulWidget {
  const RestTurtle({super.key});

  @override
  State<RestTurtle> createState() => _RestTurtleState();
}

class _RestTurtleState extends State<RestTurtle> with TickerProviderStateMixin {
  late AnimationController _munchController, _shareController;
  late Animation<double> _munchAnimation, _shareAnimation;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _munchController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350))..repeat(reverse: true);
    _munchAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(CurvedAnimation(parent: _munchController, curve: Curves.easeInOut));
    _shareController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shareAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _shareController, curve: Curves.elasticOut));
  }

  void _onTapTurtle() async {
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
      onTap: _onTapTurtle,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_munchController, _shareController]),
          builder: (context, child) {
            return CustomPaint(
              size: const Size(150, 150),
              painter: _RestTurtlePainter(
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

class _RestTurtlePainter extends CustomPainter {
  final double munchOffset, shareProgress;
  final bool isSharing;

  _RestTurtlePainter({required this.munchOffset, required this.shareProgress, required this.isSharing});

  @override
  void paint(Canvas canvas, Size size) {
    final shellPaint = Paint()..color = Colors.green[900]!;
    final skinPaint = Paint()..color = Colors.lightGreen[400]!;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 + 10);
    canvas.scale(0.85, 0.85);

    // 머리
    canvas.drawCircle(Offset(0, -55 + munchOffset), 25, skinPaint);
    canvas.drawCircle(Offset(0, -55 + munchOffset), 25, stroke);
    for (int i in [-1, 1]) {
      canvas.drawPath(Path()..moveTo(i * 12 - 6, -62)..quadraticBezierTo(i * 12, -68, i * 12 + 6, -62), stroke);
    }

    // 몸통
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 0), width: 115, height: 95), shellPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 0), width: 115, height: 95), stroke);

    // 상추 & 앞발
    canvas.save();
    canvas.translate(0, 12 * shareProgress);
    _drawLettuce(canvas, stroke);
    canvas.drawCircle(const Offset(-32, 22), 14, skinPaint); canvas.drawCircle(const Offset(-32, 22), 14, stroke);
    canvas.drawCircle(const Offset(32, 22), 14, skinPaint); canvas.drawCircle(const Offset(32, 22), 14, stroke);
    canvas.restore();
  }

  void _drawLettuce(Canvas canvas, Paint stroke) {
    final leafPaint = Paint()..color = Colors.greenAccent[400]!;
    Path leaf = Path()..moveTo(-22, 12)..quadraticBezierTo(-35, 35, 0, 55)..quadraticBezierTo(35, 35, 22, 12)..quadraticBezierTo(0, 2, -22, 12)..close();
    canvas.drawPath(leaf, leafPaint);
    canvas.drawPath(leaf, stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant _RestTurtlePainter oldDelegate) => true;
}

// ==========================================
// Idle Mode: IdleTurtle (새롭게 디자인된 거북이)
// ==========================================
class IdleTurtle extends StatefulWidget {
  const IdleTurtle({super.key});

  @override
  State<IdleTurtle> createState() => _IdleTurtleState();
}

class _IdleTurtleState extends State<IdleTurtle> with TickerProviderStateMixin {
  late AnimationController _bodyController;
  late Animation<double> _bodyAnimation;
  final List<HeartParticle> _hearts = [];
  bool _isShowingLove = false;
  bool _isBlinking = false;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _bodyController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _bodyAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(CurvedAnimation(parent: _bodyController, curve: Curves.easeInOut));

    _startBlinkRoutine();
    Timer.periodic(const Duration(milliseconds: 50), (t) => _updateHearts());
  }

  void _startBlinkRoutine() {
    _blinkTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (mounted && !_isShowingLove) {
        setState(() => _isBlinking = true);
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) setState(() => _isBlinking = false);
      }
    });
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
        position: const Offset(0, -50), size: 16, angle: 0,
        speedY: 2.0, speedX: (math.Random().nextDouble() - 0.5) * 2.0,
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
            painter: _IdleTurtlePainter(
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
    _blinkTimer?.cancel();
    super.dispose();
  }
}

class _IdleTurtlePainter extends CustomPainter {
  final double bodyOffset;
  final List<HeartParticle> hearts;
  final bool isShowingLove, isBlinking;

  _IdleTurtlePainter({required this.bodyOffset, required this.hearts, required this.isShowingLove, required this.isBlinking});

  @override
  void paint(Canvas canvas, Size size) {
    final shellPaint = Paint()..color = Colors.green[900]!;
    final skinPaint = Paint()..color = Colors.lightGreen[400]!;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.translate(size.width / 2, size.height / 2 - 15 + bodyOffset);

    // 하트 파티클
    for (var h in hearts) _drawHeart(canvas, h);

    // 머리
    Offset headPos = const Offset(0, -35);
    canvas.drawCircle(headPos, 28, skinPaint);
    canvas.drawCircle(headPos, 28, stroke);

    // 얼굴 디자인 (Idle 전용: 더 큰 눈과 볼터치)
    if (isShowingLove) {
      _drawHappyFace(canvas, headPos, stroke);
    } else if (isBlinking) {
      canvas.drawLine(headPos + const Offset(-18, -5), headPos + const Offset(-8, -5), stroke);
      canvas.drawLine(headPos + const Offset(8, -5), headPos + const Offset(18, -5), stroke);
    } else {
      // 반짝이는 큰 눈
      canvas.drawCircle(headPos + const Offset(-14, -5), 6, Paint()..color = Colors.black);
      canvas.drawCircle(headPos + const Offset(14, -5), 6, Paint()..color = Colors.black);
      canvas.drawCircle(headPos + const Offset(-16, -7), 2, Paint()..color = Colors.white);
      canvas.drawCircle(headPos + const Offset(12, -7), 2, Paint()..color = Colors.white);
      // 귀여운 입
      canvas.drawArc(Rect.fromCenter(center: headPos + const Offset(0, 8), width: 10, height: 8), 0, math.pi, false, stroke);
    }
    // 볼터치
    canvas.drawCircle(headPos + const Offset(-20, 5), 5, Paint()..color = Colors.pink[100]!.withOpacity(0.6));
    canvas.drawCircle(headPos + const Offset(20, 5), 5, Paint()..color = Colors.pink[100]!.withOpacity(0.6));

    // 몸통(등껍질)
    Rect shellRect = Rect.fromCenter(center: const Offset(0, 15), width: 105, height: 85);
    canvas.drawOval(shellRect, shellPaint);
    canvas.drawOval(shellRect, stroke);
  }

  void _drawHappyFace(Canvas canvas, Offset headPos, Paint stroke) {
    for (int i in [-1, 1]) {
      canvas.drawPath(Path()..moveTo(headPos.dx + (i * 15) - 7, headPos.dy - 8)..quadraticBezierTo(headPos.dx + (i * 15), headPos.dy - 15, headPos.dx + (i * 15) + 7, headPos.dy - 8), stroke);
    }
    canvas.drawArc(Rect.fromCenter(center: headPos + const Offset(0, 10), width: 12, height: 10), 0, math.pi, false, stroke);
  }

  void _drawHeart(Canvas canvas, HeartParticle h) {
    final p = Paint()..color = Colors.pinkAccent.withOpacity(h.opacity);
    canvas.save(); canvas.translate(h.position.dx, h.position.dy); canvas.scale(h.size / 20);
    Path path = Path()..moveTo(0, 5)..cubicTo(0, -5, -10, -5, -10, 0)..cubicTo(-10, 10, 0, 15, 0, 20)..cubicTo(0, 15, 10, 10, 10, 0)..cubicTo(10, -5, 0, -5, 0, 5)..close();
    canvas.drawPath(path, p); canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IdleTurtlePainter oldDelegate) => true;
}

// ---------------------------------------------------------
class _ThickBookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
    canvas.drawRect(Rect.fromLTWH(5, 10, size.width - 10, 35), Paint()..color = Colors.white);
    Path path = Path()..moveTo(0, 5)..lineTo(size.width/2, 15)..lineTo(size.width, 5)..lineTo(size.width, 45)..lineTo(size.width/2, 55)..lineTo(0, 45)..close();
    canvas.drawPath(path, Paint()..color = Colors.indigo[900]!);
    canvas.drawPath(path, stroke);
    canvas.drawLine(Offset(size.width/2, 15), Offset(size.width/2, 55), stroke);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HeartParticle {
  Offset position; double size; double angle; double opacity; double speedY; double speedX;
  HeartParticle({required this.position, required this.size, required this.angle, this.opacity = 1.0, required this.speedY, required this.speedX});
}