import 'package:flutter/material.dart';
import 'dart:math' as math;

class MouthMunchRabbitV5 extends StatefulWidget {
  const MouthMunchRabbitV5({super.key});

  @override
  State<MouthMunchRabbitV5> createState() => _MouthMunchRabbitV5State();
}

class _MouthMunchRabbitV5State extends State<MouthMunchRabbitV5> with TickerProviderStateMixin {
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
                painter: MouthMunchPainterV5(
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

class MouthMunchPainterV5 extends CustomPainter {
  final double munchOffset;
  final double shareProgress;
  final bool isSharing;

  MouthMunchPainterV5({
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
  bool shouldRepaint(covariant MouthMunchPainterV5 oldDelegate) => true;
}
