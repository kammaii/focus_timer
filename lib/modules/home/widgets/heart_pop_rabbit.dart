import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

// 하트 파티클 클래스 정의
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

class HeartPopRabbit extends StatefulWidget {
  const HeartPopRabbit({super.key});

  @override
  _HeartPopRabbitState createState() => _HeartPopRabbitState();
}

class _HeartPopRabbitState extends State<HeartPopRabbit> with TickerProviderStateMixin {
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
                painter: HeartPopRabbitPainter(
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

class HeartPopRabbitPainter extends CustomPainter {
  final double bodyOffset;
  final List<HeartParticle> hearts;
  final bool isShowingLove, isBlinking;

  HeartPopRabbitPainter({
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
  bool shouldRepaint(covariant HeartPopRabbitPainter oldDelegate) => true;
}
