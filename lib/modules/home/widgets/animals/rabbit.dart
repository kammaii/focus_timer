import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

// ==========================================
// Focus Mode: FocusRabbit
// ==========================================
class FocusRabbit extends StatefulWidget {
  const FocusRabbit({super.key});

  @override
  State<FocusRabbit> createState() => _FocusRabbitState();
}

class _FocusRabbitState extends State<FocusRabbit> with TickerProviderStateMixin {
  late AnimationController _eyeController;
  late AnimationController _earController;
  
  late Animation<double> _eyeAnimation;
  late Animation<double> _earAnimation;

  bool _isSurprised = false;

  @override
  void initState() {
    super.initState();

    _eyeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _eyeAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _eyeController, curve: Curves.easeInOut)
    );

    // 귀 애니메이션: 0(처짐) -> 1(쫑긋)
    _earController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _earAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _earController, curve: Curves.elasticOut)
    );
  }

  void _onTapRabbit() async {
    if (_isSurprised) return;

    setState(() => _isSurprised = true);
    await _earController.forward(); // 귀가 회전하며 솟음
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      await _earController.reverse(); // 다시 아래로 회전하며 처짐
      setState(() => _isSurprised = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapRabbit,
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
                  painter: _FocusRabbitPainter(
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

class _FocusRabbitPainter extends CustomPainter {
  final double eyeX;
  final double earProgress; 
  final bool isSurprised;

  _FocusRabbitPainter({
    required this.eyeX, 
    required this.earProgress, 
    required this.isSurprised
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.white;
    final strokePaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
    
    canvas.translate(size.width / 2, size.height / 2 - 30);

    // 1. 귀 그리기 (머리 옆면을 축으로 회전)
    _drawEar(canvas, bodyPaint, strokePaint, isLeft: true);
    _drawEar(canvas, bodyPaint, strokePaint, isLeft: false);

    // 2. 몸통
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-40, -30, 80, 75), const Radius.circular(30)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-40, -30, 80, 75), const Radius.circular(30)), strokePaint);

    // 3. 발
    canvas.drawCircle(const Offset(-22, 40), 10, bodyPaint); canvas.drawCircle(const Offset(-22, 40), 10, strokePaint);
    canvas.drawCircle(const Offset(22, 40), 10, bodyPaint); canvas.drawCircle(const Offset(22, 40), 10, strokePaint);

    // 4. 얼굴 (안경/눈)
    if (isSurprised) {
      canvas.drawCircle(const Offset(-16, -15), 9, strokePaint);
      canvas.drawCircle(const Offset(16, -15), 9, strokePaint);
      canvas.drawCircle(const Offset(-16, -15), 3, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(16, -15), 3, Paint()..color = Colors.black);
      canvas.drawOval(Rect.fromLTWH(-5, 5, 10, 15), Paint()..color = Colors.pink[100]!);
    } else {
      canvas.drawCircle(const Offset(-17, -10), 12, strokePaint);
      canvas.drawCircle(const Offset(17, -10), 12, strokePaint);
      canvas.drawLine(const Offset(-5, -10), const Offset(5, -10), strokePaint);
      canvas.drawCircle(Offset(-17 + eyeX, -10), 2.5, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(17 + eyeX, -10), 2.5, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(0, 5), 3, Paint()..color = Colors.pink[100]!);
    }
  }

  void _drawEar(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    canvas.save();
    
    // 귀가 머리에 붙어있는 지점 (머리 위쪽 모서리 부근)
    double startX = isLeft ? -30 : 30;
    double startY = -20;
    
    canvas.translate(startX, startY);
    
    // 각도 설정 (라디안)
    // 평소 처진 각도: 왼쪽은 시계 방향 7시, 오른쪽은 5시 방향
    // 쫑긋한 각도: 0 (수직 위)
    double startAngle = isLeft ? -0.75 * math.pi : 0.75 * math.pi;
    double currentAngle = startAngle * (1 - earProgress);
    
    canvas.rotate(currentAngle);
    
    // 귀 모양 그리기 (중심축 기준으로 위로 뻗은 타원)
    Rect earRect = const Rect.fromLTWH(-11, -65, 22, 70);
    canvas.drawOval(earRect, fill);
    canvas.drawOval(earRect, stroke);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FocusRabbitPainter oldDelegate) => true;
}

class _StaticBookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(0, 5, size.width, 40), Paint()..color = Colors.white);
    Path path = Path()
      ..moveTo(0, 5)..lineTo(size.width/2, 12)..lineTo(size.width, 5)
      ..lineTo(size.width, 50)..lineTo(size.width/2, 57)..lineTo(0, 50)..close();
    canvas.drawPath(path, Paint()..color = Colors.blue[400]!);
    canvas.drawPath(path, stroke);
    canvas.drawLine(Offset(size.width/2, 12), Offset(size.width/2, 57), stroke);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


// ==========================================
// Rest Mode: RestRabbit
// ==========================================
class RestRabbit extends StatefulWidget {
  const RestRabbit({super.key});

  @override
  State<RestRabbit> createState() => _RestRabbitState();
}

class _RestRabbitState extends State<RestRabbit> with TickerProviderStateMixin {
  late AnimationController _munchController; // 입 오물거림
  late AnimationController _shareController; // 당근 내밀기 & 귀 흔들기
  
  late Animation<double> _munchAnimation;
  late Animation<double> _shareAnimation; // 0.0 (평소) -> 1.0 (내밀기)

  bool _isSharing = false;

  @override
  void initState() {
    super.initState();

    // 1. 입 오물거리는 루핑 애니메이션
    _munchController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))..repeat(reverse: true);
    _munchAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _munchController, curve: Curves.easeInOut)
    );

    // 2. 터치 시 당근 내밀기 애니메이션
    _shareController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shareAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shareController, curve: Curves.elasticOut)
    );
  }

  void _onTapRabbit() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
    await _shareController.forward(); // 당근을 슥 내밀며 귀를 흔듦
    await Future.delayed(const Duration(milliseconds: 1200)); // 상태 유지
    
    if (mounted) {
      await _shareController.reverse(); // 다시 제자리로
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapRabbit,
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_munchController, _shareController]),
            builder: (context, child) {
              return CustomPaint(
                size: const Size(150, 150),
                painter: _RestRabbitPainter(
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

class _RestRabbitPainter extends CustomPainter {
  final double munchOffset;
  final double shareProgress;
  final bool isSharing;

  _RestRabbitPainter({
    required this.munchOffset, 
    required this.shareProgress, 
    required this.isSharing
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.white;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final carrotPaint = Paint()..color = Colors.deepOrange;
    final leafPaint = Paint()..color = Colors.green[600]!;
    final cheekPaint = Paint()..color = Colors.pink[100]!.withOpacity(0.6);

    // 150x150 캔버스 스케일링 일치
    canvas.translate(size.width / 2, size.height / 2 + 10);
    canvas.scale(0.8, 0.8);

    // 1. 귀 (공유 중일 때 살랑살랑 흔들림)
    _drawWaggleEar(canvas, bodyPaint, stroke, isLeft: true);
    _drawWaggleEar(canvas, bodyPaint, stroke, isLeft: false);

    // 2. 몸통 & 얼굴
    _drawRabbitBody(canvas, bodyPaint, stroke, cheekPaint);
    _drawMunchingMouth(canvas, stroke);

    // 3. 당근 & 앞발 (shareProgress에 따라 앞으로 내밀어짐)
    canvas.save();
    // 당근이 사용자 쪽으로 더 가까워지도록 이동 (마지막 사이즈 조정을 위해 scale 추가 연동)
    canvas.translate(0, 15 * shareProgress);
    canvas.scale(1.0 + (0.15 * shareProgress)); 

    _drawStaticCarrot(canvas, carrotPaint, leafPaint, stroke);
    
    // 앞발
    canvas.drawCircle(const Offset(-18, 5), 13, bodyPaint); canvas.drawCircle(const Offset(-18, 5), 13, stroke);
    canvas.drawCircle(const Offset(18, 5), 13, bodyPaint); canvas.drawCircle(const Offset(18, 5), 13, stroke);
    
    canvas.restore();
  }

  void _drawWaggleEar(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    canvas.save();
    canvas.translate(isLeft ? -25 : 25, -60);
    
    // 평소 처진 각도에서 터치 시 살랑살랑 흔들리는 각도 추가
    double baseAngle = isLeft ? -0.2 : 0.2;
    double waggle = isSharing ? math.sin(shareProgress * math.pi * 4) * 0.2 : 0.0;
    
    canvas.rotate(baseAngle + waggle);
    canvas.drawOval(const Rect.fromLTWH(-12, -70, 24, 75), fill);
    canvas.drawOval(const Rect.fromLTWH(-12, -70, 24, 75), stroke);
    canvas.restore();
  }

  void _drawMunchingMouth(Canvas canvas, Paint stroke) {
    canvas.drawCircle(Offset(0, -30 + (munchOffset * 0.5)), 4, Paint()..color = Colors.pink[200]!);
    Path mouthPath = Path()
      ..moveTo(0, -26 + (munchOffset * 0.5))
      ..lineTo(-3 - munchOffset, -20 + munchOffset)
      ..moveTo(0, -26 + (munchOffset * 0.5))
      ..lineTo(3 + munchOffset, -20 + munchOffset);
    canvas.drawPath(mouthPath, stroke..strokeWidth = 2);
  }

  void _drawRabbitBody(Canvas canvas, Paint body, Paint stroke, Paint cheek) {
    Rect bodyRect = const Rect.fromLTWH(-50, -60, 100, 110);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(40)), body);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(40)), stroke);
    
    // 눈 (행복하게 감은 눈)
    for (int i in [-1, 1]) {
      canvas.save();
      canvas.translate(i * 25, -45);
      canvas.drawPath(Path()..moveTo(-8, 0)..quadraticBezierTo(0, -8, 8, 0), stroke);
      canvas.restore();
    }
    // 볼
    canvas.drawCircle(const Offset(-30, -35), 8, cheek);
    canvas.drawCircle(const Offset(30, -35), 8, cheek);
    
    // 발
    _drawFoot(canvas, body, stroke, isLeft: true);
    _drawFoot(canvas, body, stroke, isLeft: false);
  }
  
  void _drawFoot(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    double x = isLeft ? -35 : 35;
    canvas.drawOval(Rect.fromLTWH(x - 15, 35, 30, 20), fill);
    canvas.drawOval(Rect.fromLTWH(x - 15, 35, 30, 20), stroke);
  }

  void _drawStaticCarrot(Canvas canvas, Paint carrotPaint, Paint leaf, Paint stroke) {
    canvas.save();
    canvas.translate(0, -5);
    canvas.rotate(-math.pi / 12);
    Path carrotBody = Path()
      ..moveTo(15, -10)..lineTo(-5, 40)
      ..quadraticBezierTo(-10, 45, -15, 40)..lineTo(-25, -10)
      ..quadraticBezierTo(-5, -20, 15, -10)..close();
    canvas.drawPath(carrotBody, carrotPaint);
    canvas.drawPath(carrotBody, stroke..strokeWidth=2);
    // 단순화된 잎사귀
    for (double x in [-8, 0, 8]) {
      canvas.drawOval(Rect.fromLTWH(x, -22, 10, 15), leaf);
      canvas.drawOval(Rect.fromLTWH(x, -22, 10, 15), stroke..strokeWidth=1);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RestRabbitPainter oldDelegate) => true;
}


// ==========================================
// Idle Mode: IdleRabbit
// ==========================================
class HeartParticle {
  Offset position; // 현재 위치
  double size;     // 크기
  double angle;    // 회전 각도
  double opacity;  // 투명도
  double speedY;   // 상승 속도
  double speedX;   // 좌우 흔들림 속도

  HeartParticle({
    required this.position,
    required this.size,
    required this.angle,
    this.opacity = 1.0,
    required this.speedY,
    required this.speedX,
  });
}

class IdleRabbit extends StatefulWidget {
  const IdleRabbit({super.key});

  @override
  State<IdleRabbit> createState() => _IdleRabbitState();
}

class _IdleRabbitState extends State<IdleRabbit> with TickerProviderStateMixin {
  late AnimationController _bodyController;  // 숨쉬기
  late AnimationController _heartTickController; // 하트 움직임 프레임 담당

  late Animation<double> _bodyAnimation;
  
  final List<HeartParticle> _hearts = []; // 활성화된 하트 목록
  final math.Random _random = math.Random();

  bool _isShowingLove = false; // 터치 시 행복한 표정
  bool _isBlinking = false;
  Timer? _blinkTimer;
  Timer? _loveTimer;

  @override
  void initState() {
    super.initState();

    // 1. 숨쉬기 애니메이션
    _bodyController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _bodyAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _bodyController, curve: Curves.easeInOut)
    );

    // 2. 하트 애니메이션용 티커 (매 프레임 하트 상태 업데이트)
    _heartTickController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _heartTickController.addListener(_updateHearts);

    _startBlinkRoutine();
  }

  // 매 프레임 호출되어 하트들의 위치와 투명도를 업데이트
  void _updateHearts() {
    if (_hearts.isEmpty) return;

    setState(() {
      for (int i = _hearts.length - 1; i >= 0; i--) {
        final heart = _hearts[i];
        heart.position += Offset(heart.speedX, -heart.speedY); // 위로 이동 및 좌우 흔들림
        heart.opacity -= 0.02; // 점점 투명해짐
        heart.angle += 0.05; // 살짝 회전

        // 투명해지면 리스트에서 제거
        if (heart.opacity <= 0) {
          _hearts.removeAt(i);
        }
      }
    });
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

  // 터치 시 하트 생성
  void _onTapRabbit() {
    _loveTimer?.cancel();
    setState(() => _isShowingLove = true);

    // 하트 3~5개 랜덤 생성
    int count = 3 + _random.nextInt(3);
    for (int i = 0; i < count; i++) {
      _hearts.add(HeartParticle(
        position: const Offset(0, -60), // 머리 위에서 시작
        size: 15.0 + _random.nextDouble() * 15.0, // 크기 랜덤
        angle: (_random.nextDouble() - 0.5) * 0.5, // 초기 각도 랜덤
        speedY: 2.0 + _random.nextDouble() * 2.0, // 상승 속도 랜덤
        speedX: (_random.nextDouble() - 0.5) * 2.0, // 좌우 속도 랜덤
      ));
    }

    // 잠시 후 표정 복귀
    _loveTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isShowingLove = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapRabbit,
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: AnimatedBuilder(
            animation: _bodyController, // 숨쉬기에 맞춰 다시 그림
            builder: (context, child) {
              return CustomPaint(
                size: const Size(150, 150),
                painter: _IdleRabbitPainter(
                  bodyOffset: _bodyAnimation.value,
                  hearts: _hearts,
                  isShowingLove: _isShowingLove,
                  isBlinking: _isBlinking,
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
    _bodyController.dispose();
    _heartTickController.dispose();
    _blinkTimer?.cancel();
    _loveTimer?.cancel();
    super.dispose();
  }
}

class _IdleRabbitPainter extends CustomPainter {
  final double bodyOffset;
  final List<HeartParticle> hearts;
  final bool isShowingLove, isBlinking;

  _IdleRabbitPainter({
    required this.bodyOffset, required this.hearts,
    required this.isShowingLove, required this.isBlinking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.white;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
    
    // 집중 모드(도착 150x150)와 높이감을 맞추기 위해 Y축 중심을 살짝 위로(-15) 올림
    canvas.translate(size.width / 2, size.height / 2 - 15 + bodyOffset);

    // 1. 하트 그리기 (토끼 뒤/위에 그려지도록 먼저 그림)
    for (var heart in hearts) {
      _drawHeart(canvas, heart);
    }

    // 2. 토끼 그리기 (대기 상태 기반)
    // 귀 (처진 상태)
    _drawFloppyEar(canvas, bodyPaint, stroke, isLeft: true);
    _drawFloppyEar(canvas, bodyPaint, stroke, isLeft: false);

    // 몸통
    Rect bodyRect = const Rect.fromLTWH(-40, -30, 80, 85);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(30)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(30)), stroke);

    // 발
    canvas.drawCircle(const Offset(-20, 50), 10, bodyPaint); canvas.drawCircle(const Offset(-20, 50), 10, stroke);
    canvas.drawCircle(const Offset(20, 50), 10, bodyPaint); canvas.drawCircle(const Offset(20, 50), 10, stroke);

    // 얼굴 표정
    if (isShowingLove) {
      // 사랑에 빠진 표정 (발그레 + 웃음)
      canvas.drawCircle(const Offset(-25, 0), 8, Paint()..color = Colors.pink[200]!.withOpacity(0.8)); // 진한 볼터치
      canvas.drawCircle(const Offset(25, 0), 8, Paint()..color = Colors.pink[200]!.withOpacity(0.8));
      _drawHappyEye(canvas, stroke, isLeft: true); // ^^ 눈
      _drawHappyEye(canvas, stroke, isLeft: false);
      canvas.drawArc(const Rect.fromLTWH(-5, 5, 10, 10), 0, math.pi, false, stroke); // 웃는 입
    } else if (isBlinking) {
      canvas.drawLine(const Offset(-22, -10), const Offset(-10, -10), stroke);
      canvas.drawLine(const Offset(10, -10), const Offset(22, -10), stroke);
    } else {
      canvas.drawCircle(const Offset(-16, -10), 4, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(16, -10), 4, Paint()..color = Colors.black);
      canvas.drawCircle(const Offset(0, 5), 3, Paint()..color = Colors.pink[100]!);
    }
  }

  // 하트 그리기 헬퍼
  void _drawHeart(Canvas canvas, HeartParticle heart) {
    final heartPaint = Paint()..color = Colors.pinkAccent.withOpacity(heart.opacity);
    canvas.save();
    canvas.translate(heart.position.dx, heart.position.dy);
    canvas.rotate(heart.angle);
    canvas.scale(heart.size / 20); // 기본 사이즈 기준으로 스케일링

    // 하트 모양 Path
    Path path = Path();
    path.moveTo(0, 5);
    path.cubicTo(0, -5, -10, -5, -10, 0);
    path.cubicTo(-10, 10, 0, 15, 0, 20);
    path.cubicTo(0, 15, 10, 10, 10, 0);
    path.cubicTo(10, -5, 0, -5, 0, 5);
    path.close();
    
    canvas.drawPath(path, heartPaint);
    canvas.restore();
  }

  void _drawHappyEye(Canvas canvas, Paint stroke, {required bool isLeft}) {
    canvas.save();
    canvas.translate(isLeft ? -16 : 16, -10);
    canvas.drawPath(Path()..moveTo(-7, 0)..quadraticBezierTo(0, -7, 7, 0), stroke);
    canvas.restore();
  }

  void _drawFloppyEar(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    canvas.save();
    double startX = isLeft ? -30 : 30;
    canvas.translate(startX, -20);
    canvas.rotate(isLeft ? -0.7 * math.pi : 0.7 * math.pi);
    canvas.drawOval(const Rect.fromLTWH(-11, -65, 22, 65), fill);
    canvas.drawOval(const Rect.fromLTWH(-11, -65, 22, 65), stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IdleRabbitPainter oldDelegate) => true;
}
