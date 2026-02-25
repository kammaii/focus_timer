import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

// ==========================================
// Focus Mode: FocusDog
// ==========================================
class FocusDog extends StatefulWidget {
  const FocusDog({super.key});

  @override
  State<FocusDog> createState() => _FocusDogState();
}

class _FocusDogState extends State<FocusDog> with TickerProviderStateMixin {
  late AnimationController _eyeController;
  late AnimationController _tailController;
  
  late Animation<double> _eyeAnimation;
  late Animation<double> _tailAnimation;

  bool _isSurprised = false;

  @override
  void initState() {
    super.initState();

    _eyeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _eyeAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _eyeController, curve: Curves.easeInOut)
    );

    // 꼬리 흔들기 애니메이션 (평소에는 천천히, 탭하면 빠르게)
    _tailController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _tailAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _tailController, curve: Curves.easeInOut)
    );
  }

  void _onTapDog() async {
    if (_isSurprised) return;

    setState(() => _isSurprised = true);
    _tailController.duration = const Duration(milliseconds: 200); // 꼬리를 빠르게 흔듦
    _tailController.repeat(reverse: true);
    
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      _tailController.duration = const Duration(milliseconds: 800); // 다시 천천히
      _tailController.repeat(reverse: true);
      setState(() => _isSurprised = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapDog,
      child: Container(
        color: Colors.transparent, 
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_eyeController, _tailController]),
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(150, 150),
                  painter: _FocusDogPainter(
                    eyeX: _eyeAnimation.value,
                    tailWag: _tailAnimation.value,
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
    _tailController.dispose();
    super.dispose();
  }
}

class _FocusDogPainter extends CustomPainter {
  final double eyeX;
  final double tailWag; 
  final bool isSurprised;

  _FocusDogPainter({
    required this.eyeX, 
    required this.tailWag, 
    required this.isSurprised
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyColor = Colors.orange[200]!;
    final spotColor = Colors.brown[400]!;
    
    final bodyPaint = Paint()..color = bodyColor;
    final spotPaint = Paint()..color = spotColor;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
    
    canvas.translate(size.width / 2, size.height / 2 - 30);

    // 1. 꼬리 그리기 (몸통 뒤)
    canvas.save();
    canvas.translate(-40, 20);
    canvas.rotate(tailWag - 0.5); // 꼬리 흔들기
    final tailRect = const Rect.fromLTWH(-5, -5, 45, 12);
    canvas.drawRRect(RRect.fromRectAndRadius(tailRect, const Radius.circular(10)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(tailRect, const Radius.circular(10)), strokePaint);
    canvas.restore();

    // 2. 귀 그리기 (처진 귀)
    _drawEar(canvas, spotPaint, strokePaint, isLeft: true);
    _drawEar(canvas, spotPaint, strokePaint, isLeft: false);

    // 3. 몸통
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-40, -30, 80, 75), const Radius.circular(30)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-40, -30, 80, 75), const Radius.circular(30)), strokePaint);

    // 얼룩 무늬 (가슴)
    canvas.drawOval(const Rect.fromLTWH(-20, 20, 40, 30), Paint()..color = Colors.white.withOpacity(0.7));

    // 4. 발
    canvas.drawCircle(const Offset(-22, 40), 10, spotPaint); canvas.drawCircle(const Offset(-22, 40), 10, strokePaint);
    canvas.drawCircle(const Offset(22, 40), 10, spotPaint); canvas.drawCircle(const Offset(22, 40), 10, strokePaint);

    // 5. 얼굴 (강아지 코와 입)
    canvas.drawOval(const Rect.fromLTWH(-15, -5, 30, 25), Paint()..color = Colors.white); // 머즐
    canvas.drawOval(const Rect.fromLTWH(-15, -5, 30, 25), strokePaint); // 머즐 테두리
    canvas.drawCircle(const Offset(0, 5), 4, Paint()..color = Colors.black); // 코
    
    // 입
    final mouthPath = Path()
      ..moveTo(-8, 12)..quadraticBezierTo(0, 18, 0, 12)..quadraticBezierTo(0, 18, 8, 12);
    canvas.drawPath(mouthPath, strokePaint..strokeWidth = 2);

    // 6. 눈
    if (isSurprised) {
      canvas.drawCircle(const Offset(-16, -15), 5, strokePaint);
      canvas.drawCircle(const Offset(16, -15), 5, strokePaint);
      canvas.drawLine(const Offset(-20, -25), const Offset(-10, -20), strokePaint); // 화들짝 놀란 눈썹
      canvas.drawLine(const Offset(10, -20), const Offset(20, -25), strokePaint);
    } else {
      // 집중하는 안경 (토끼와 동일)
      canvas.drawCircle(const Offset(-17, -15), 10, strokePaint);
      canvas.drawCircle(const Offset(17, -15), 10, strokePaint);
      canvas.drawLine(const Offset(-7, -15), const Offset(7, -15), strokePaint);
      canvas.drawCircle(Offset(-17 + eyeX, -15), 3, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(17 + eyeX, -15), 3, Paint()..color = Colors.black);
    }
  }

  void _drawEar(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    canvas.save();
    double startX = isLeft ? -30 : 30;
    canvas.translate(startX, -15);
    canvas.rotate(isLeft ? 0.3 : -0.3); // 아래로 처진 귀
    final earRect = const Rect.fromLTWH(-15, -10, 30, 50);
    // 강아지 귀는 타원형보다 아래가 넙적한 형태
    final path = Path()
      ..moveTo(-10, -10)..quadraticBezierTo(10, -10, 10, -10)..lineTo(15, 30)..quadraticBezierTo(0, 45, -15, 30)..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FocusDogPainter oldDelegate) => true;
}

class _StaticBookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(0, 5, size.width, 40), Paint()..color = Colors.white);
    Path path = Path()
      ..moveTo(0, 5)..lineTo(size.width/2, 12)..lineTo(size.width, 5)
      ..lineTo(size.width, 50)..lineTo(size.width/2, 57)..lineTo(0, 50)..close();
    canvas.drawPath(path, Paint()..color = Colors.green[400]!); // 강아지는 초록색 책
    canvas.drawPath(path, stroke);
    canvas.drawLine(Offset(size.width/2, 12), Offset(size.width/2, 57), stroke);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


// ==========================================
// Rest Mode: RestDog
// ==========================================
class RestDog extends StatefulWidget {
  const RestDog({super.key});

  @override
  State<RestDog> createState() => _RestDogState();
}

class _RestDogState extends State<RestDog> with TickerProviderStateMixin {
  late AnimationController _munchController; 
  late AnimationController _shareController; 
  
  late Animation<double> _munchAnimation;
  late Animation<double> _shareAnimation; 

  bool _isSharing = false;

  @override
  void initState() {
    super.initState();

    _munchController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250))..repeat(reverse: true);
    _munchAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _munchController, curve: Curves.easeInOut)
    );

    _shareController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shareAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shareController, curve: Curves.elasticOut)
    );
  }

  void _onTapDog() async {
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
      onTap: _onTapDog,
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_munchController, _shareController]),
            builder: (context, child) {
              return CustomPaint(
                size: const Size(150, 150),
                painter: _RestDogPainter(
                  munchOffset: _munchAnimation.value,
                  shareProgress: _shareAnimation.value,
                  isSharing: _isSharing,
                ),
              );
            },
          ),
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

class _RestDogPainter extends CustomPainter {
  final double munchOffset;
  final double shareProgress;
  final bool isSharing;

  _RestDogPainter({
    required this.munchOffset, 
    required this.shareProgress, 
    required this.isSharing
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyColor = Colors.orange[200]!;
    final spotColor = Colors.brown[400]!;
    
    final bodyPaint = Paint()..color = bodyColor;
    final spotPaint = Paint()..color = spotColor;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final bonePaint = Paint()..color = Colors.white;

    canvas.translate(size.width / 2, size.height / 2 + 10);
    canvas.scale(0.8, 0.8);

    // 1. 귀 그리기 (공유할 때 펄럭)
    _drawWaggleEar(canvas, spotPaint, stroke, isLeft: true);
    _drawWaggleEar(canvas, spotPaint, stroke, isLeft: false);

    // 2. 몸통 & 얼굴
    _drawDogBody(canvas, bodyPaint, spotPaint, stroke);
    _drawMunchingMuzzle(canvas, stroke);

    // 3. 뼈다귀 & 앞발 (내밀어짐)
    canvas.save();
    canvas.translate(0, 15 * shareProgress);
    canvas.scale(1.0 + (0.15 * shareProgress)); 

    _drawStaticBone(canvas, bonePaint, stroke);
    
    // 앞발
    canvas.drawCircle(const Offset(-20, 10), 12, spotPaint); canvas.drawCircle(const Offset(-20, 10), 12, stroke);
    canvas.drawCircle(const Offset(20, 10), 12, spotPaint); canvas.drawCircle(const Offset(20, 10), 12, stroke);
    
    canvas.restore();
  }

  void _drawWaggleEar(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    canvas.save();
    canvas.translate(isLeft ? -25 : 25, -40);
    
    double baseAngle = isLeft ? 0.4 : -0.4;
    double waggle = isSharing ? math.sin(shareProgress * math.pi * 6) * 0.3 : 0.0;
    
    canvas.rotate(baseAngle + waggle);
    final path = Path()
      ..moveTo(-10, -10)..lineTo(10, -10)..lineTo(15, 30)..quadraticBezierTo(0, 45, -15, 30)..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    canvas.restore();
  }

  void _drawDogBody(Canvas canvas, Paint body, Paint spot, Paint stroke) {
    Rect bodyRect = const Rect.fromLTWH(-50, -60, 100, 110);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(40)), body);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(40)), stroke);
    
    // 배 얼룩
    canvas.drawOval(const Rect.fromLTWH(-25, -5, 50, 40), Paint()..color = Colors.white.withOpacity(0.7));

    // 눈 (행복하게 감은 눈)
    for (int i in [-1, 1]) {
      canvas.save();
      canvas.translate(i * 25, -35);
      canvas.drawPath(Path()..moveTo(-8, 0)..quadraticBezierTo(0, -8, 8, 0), stroke);
      canvas.restore();
    }
    
    // 발
    _drawFoot(canvas, spot, stroke, isLeft: true);
    _drawFoot(canvas, spot, stroke, isLeft: false);
  }

  void _drawMunchingMuzzle(Canvas canvas, Paint stroke) {
    // 머즐 바탕
    canvas.drawOval(const Rect.fromLTWH(-20, -20, 40, 30), Paint()..color = Colors.white);
    canvas.drawOval(const Rect.fromLTWH(-20, -20, 40, 30), stroke);
    
    // 코 (오물거릴때 위아래로 약간)
    canvas.drawCircle(Offset(0, -12 + (munchOffset * 0.3)), 5, Paint()..color = Colors.black);

    // 입 (오물거림)
    Path mouthPath = Path()
      ..moveTo(0, -5 + (munchOffset * 0.5))
      ..lineTo(-6 - munchOffset, 2 + munchOffset)
      ..moveTo(0, -5 + (munchOffset * 0.5))
      ..lineTo(6 + munchOffset, 2 + munchOffset);
    canvas.drawPath(mouthPath, stroke..strokeWidth = 2.5);
  }
  
  void _drawFoot(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    double x = isLeft ? -35 : 35;
    canvas.drawOval(Rect.fromLTWH(x - 15, 35, 30, 20), fill);
    canvas.drawOval(Rect.fromLTWH(x - 15, 35, 30, 20), stroke);
  }

  void _drawStaticBone(Canvas canvas, Paint bonePaint, Paint stroke) {
    canvas.save();
    canvas.translate(0, 5);
    canvas.rotate(-math.pi / 16);
    
    // 뼈다귀 모양 (가운데 막대 + 양끝 동그라미 4개)
    final rect = const Rect.fromLTWH(-25, -5, 50, 10);
    canvas.drawRect(rect, bonePaint);
    canvas.drawRect(rect, stroke..strokeWidth=2);
    
    final circles = [
      const Offset(-25, -8), const Offset(-25, 8),
      const Offset(25, -8), const Offset(25, 8),
    ];
    
    for (var center in circles) {
      canvas.drawCircle(center, 7, bonePaint);
      canvas.drawCircle(center, 7, stroke..strokeWidth=2);
    }
    canvas.drawRect(rect, bonePaint); // 선 덮기
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RestDogPainter oldDelegate) => true;
}


// ==========================================
// Idle Mode: IdleDog
// ==========================================
class IdleDog extends StatefulWidget {
  const IdleDog({super.key});

  @override
  State<IdleDog> createState() => _IdleDogState();
}

class _IdleDogState extends State<IdleDog> with TickerProviderStateMixin {
  late AnimationController _pantController; 
  late AnimationController _tailController; 
  
  late Animation<double> _pantAnimation;
  late Animation<double> _tailAnimation;

  bool _isHappy = false; 
  Timer? _happyTimer;

  @override
  void initState() {
    super.initState();

    // 헥헥거림 (위아래 바운스 + 혀 움직임)
    _pantController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150))..repeat(reverse: true);
    _pantAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _pantController, curve: Curves.easeInOut)
    );

    // 꼬리 흔들기
    _tailController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))..repeat(reverse: true);
    _tailAnimation = Tween<double>(begin: -0.3, end: 0.3).animate(
      CurvedAnimation(parent: _tailController, curve: Curves.easeInOut)
    );
  }

  void _onTapDog() {
    _happyTimer?.cancel();
    setState(() => _isHappy = true);

    _tailController.duration = const Duration(milliseconds: 100);
    _tailController.repeat(reverse: true);

    _happyTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isHappy = false);
        _tailController.duration = const Duration(milliseconds: 200);
        _tailController.repeat(reverse: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapDog,
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_pantController, _tailController]), 
            builder: (context, child) {
              return CustomPaint(
                size: const Size(150, 150),
                painter: _IdleDogPainter(
                  pantOffset: _pantAnimation.value,
                  tailOffset: _tailAnimation.value,
                  isHappy: _isHappy,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pantController.dispose();
    _tailController.dispose();
    _happyTimer?.cancel();
    super.dispose();
  }
}

class _IdleDogPainter extends CustomPainter {
  final double pantOffset;
  final double tailOffset;
  final bool isHappy;

  _IdleDogPainter({
    required this.pantOffset, required this.tailOffset, required this.isHappy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyColor = Colors.orange[200]!;
    final spotColor = Colors.brown[400]!;
    
    final bodyPaint = Paint()..color = bodyColor;
    final spotPaint = Paint()..color = spotColor;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
    
    canvas.translate(size.width / 2, size.height / 2 - 15 + pantOffset);

    // 1. 꼬리 그리기 (등 뒤에서 살랑)
    canvas.save();
    canvas.translate(35, 10);
    canvas.rotate(tailOffset);
    final tailRect = const Rect.fromLTWH(0, -5, 45, 15);
    canvas.drawRRect(RRect.fromRectAndRadius(tailRect, const Radius.circular(10)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(tailRect, const Radius.circular(10)), stroke);
    canvas.restore();

    // 2. 귀 그리기 (처짐)
    _drawEar(canvas, spotPaint, stroke, isLeft: true);
    _drawEar(canvas, spotPaint, stroke, isLeft: false);

    // 3. 몸통
    Rect bodyRect = const Rect.fromLTWH(-40, -30, 80, 85);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(30)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(30)), stroke);

    // 4. 발
    canvas.drawCircle(const Offset(-20, 50), 10, spotPaint); canvas.drawCircle(const Offset(-20, 50), 10, stroke);
    canvas.drawCircle(const Offset(20, 50), 10, spotPaint); canvas.drawCircle(const Offset(20, 50), 10, stroke);

    // 5. 얼굴
    if (isHappy) {
      // 행복한 표정 (하트/별 모션 생략하고 눈웃음)
      _drawHappyEye(canvas, stroke, isLeft: true);
      _drawHappyEye(canvas, stroke, isLeft: false);
      canvas.drawCircle(const Offset(-25, -5), 8, Paint()..color = Colors.pink[200]!.withOpacity(0.8)); 
      canvas.drawCircle(const Offset(25, -5), 8, Paint()..color = Colors.pink[200]!.withOpacity(0.8));
    } else {
      // 기본 땡글 눈
      canvas.drawCircle(const Offset(-16, -10), 4, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(16, -10), 4, Paint()..color = Colors.black);
    }
    
    // 머즐
    canvas.drawOval(const Rect.fromLTWH(-18, 0, 36, 26), Paint()..color = Colors.white);
    canvas.drawOval(const Rect.fromLTWH(-18, 0, 36, 26), stroke);
    canvas.drawCircle(const Offset(0, 7), 5, Paint()..color = Colors.black); // 코
    
    // 입 (헤벌레)
    canvas.drawArc(const Rect.fromLTWH(-10, 10, 20, 10), 0, math.pi, false, stroke);

    // 혀 낼름거림
    canvas.save();
    canvas.translate(5, 20 + pantOffset*0.5); // 혀가 헥헥거림에 맞춰 더 내려감
    final tongueRect = const Rect.fromLTWH(-5, 0, 10, 15);
    canvas.drawRRect(RRect.fromRectAndRadius(tongueRect, const Radius.circular(5)), Paint()..color = Colors.pinkAccent);
    canvas.drawRRect(RRect.fromRectAndRadius(tongueRect, const Radius.circular(5)), stroke..strokeWidth=1.5);
    canvas.drawLine(const Offset(0, 0), const Offset(0, 10), stroke..strokeWidth=1); // 혀 중간선
    canvas.restore();
  }

  void _drawHappyEye(Canvas canvas, Paint stroke, {required bool isLeft}) {
    canvas.save();
    canvas.translate(isLeft ? -16 : 16, -10);
    canvas.drawPath(Path()..moveTo(-7, 0)..quadraticBezierTo(0, -7, 7, 0), stroke);
    canvas.restore();
  }

  void _drawEar(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    canvas.save();
    double startX = isLeft ? -30 : 30;
    canvas.translate(startX, -15);
    canvas.rotate(isLeft ? 0.4 : -0.4); 
    final path = Path()
      ..moveTo(-10, -10)..lineTo(10, -10)..lineTo(15, 30)..quadraticBezierTo(0, 45, -15, 30)..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IdleDogPainter oldDelegate) => true;
}
