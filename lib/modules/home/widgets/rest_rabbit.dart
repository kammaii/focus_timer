import 'package:flutter/material.dart';
import 'dart:math' as math;

class MouthMunchRabbitV5 extends StatefulWidget {
  const MouthMunchRabbitV5({super.key});

  @override
  State<MouthMunchRabbitV5> createState() => _MunchRabbitV5State();
}

class _MunchRabbitV5State extends State<MouthMunchRabbitV5> with SingleTickerProviderStateMixin {
  late AnimationController _munchController;
  late Animation<double> _munchAnimation;

  @override
  void initState() {
    super.initState();
    // 입만 빠르게 오물거리는 애니메이션
    _munchController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))..repeat(reverse: true);
    _munchAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _munchController, curve: Curves.easeInOut)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: AnimatedBuilder(
            animation: _munchController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(200, 200),
                painter: MouthMunchPainterV5(munchOffset: _munchAnimation.value),
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
    super.dispose();
  }
}

class MouthMunchPainterV5 extends CustomPainter {
  final double munchOffset;
  MouthMunchPainterV5({required this.munchOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.white;
    final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final carrotPaint = Paint()..color = Colors.deepOrange;
    final carrotTexturePaint = Paint()..color = Colors.black12..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final leafPaint = Paint()..color = Colors.green[600]!;
    // 잎사귀 테두리도 단순하게 변경
    final leafStroke = Paint()..color = Colors.green[800]!..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final cheekPaint = Paint()..color = Colors.pink[100]!.withOpacity(0.6);

    // 버튼 영역과 겹치지 않도록 Y축 중심을 위로 올림 (+50 -> +20)
    canvas.translate(size.width / 2, size.height / 2 + 20);

    // 1. 몸통 & 귀 (고정)
    _drawStaticBody(canvas, bodyPaint, stroke, cheekPaint);

    // 2. 당근 (위치를 아래로 내림)
    _drawStaticCarrot(canvas, carrotPaint, carrotTexturePaint, leafPaint, leafStroke, stroke);

    // 3. 앞발 (당근을 따라 아래로 내려감)
    // 기존 y: -25 -> 변경 y: 0 (25픽셀 내림)
    canvas.drawCircle(const Offset(-18, 10), 13, bodyPaint); canvas.drawCircle(const Offset(-18, 10), 13, stroke);
    canvas.drawCircle(const Offset(18, 10), 13, bodyPaint); canvas.drawCircle(const Offset(18, 10), 13, stroke);

    // 4. 오물거리는 입 (위치 고정, 애니메이션만 적용)
    // 당근이 내려가서 입이 잘 보임
    _drawMunchingMouth(canvas, stroke);
  }

  // 입만 우물우물 움직이는 부분
  void _drawMunchingMouth(Canvas canvas, Paint stroke) {
    // 코 위치
    canvas.drawCircle(Offset(0, -30 + (munchOffset * 0.5)), 4, Paint()..color = Colors.pink[200]!);
    
    // 입술 선 (Y자 모양)
    Path mouthPath = Path()
      ..moveTo(0, -26 + (munchOffset * 0.5))
      ..lineTo(-3 - munchOffset, -20 + munchOffset)
      ..moveTo(0, -26 + (munchOffset * 0.5))
      ..lineTo(3 + munchOffset, -20 + munchOffset);
    
    canvas.drawPath(mouthPath, stroke..strokeWidth = 2);
  }

  void _drawStaticCarrot(Canvas canvas, Paint carrotPaint, Paint texture, Paint leaf, Paint leafStroke, Paint stroke) {
    canvas.save();
    // 당근 위치 이동: 기존 -30에서 -5로 변경 (아래로 25픽셀 이동)
    canvas.translate(0, 10); 
    canvas.rotate(-math.pi / 12);

    // 당근 몸통
    Path carrotBody = Path()
      ..moveTo(15, -10)..lineTo(-5, 40)
      ..quadraticBezierTo(-10, 45, -15, 40)..lineTo(-25, -10)
      ..quadraticBezierTo(-5, -20, 15, -10)..close();
    canvas.drawPath(carrotBody, carrotPaint);
    canvas.drawPath(carrotBody, stroke..strokeWidth=2);

    // 당근 질감
    canvas.drawLine(const Offset(-20, 0), const Offset(10, -2), texture);
    canvas.drawLine(const Offset(-15, 15), const Offset(5, 12), texture);

    // --- 당근 잎사귀 (단순한 이전 버전으로 롤백) ---
    // 중앙 잎
    canvas.drawOval(const Rect.fromLTWH(0, -25, 12, 20), leaf);
    canvas.drawOval(const Rect.fromLTWH(0, -25, 12, 20), leafStroke);
    // 오른쪽 잎
    canvas.drawOval(const Rect.fromLTWH(8, -22, 10, 15), leaf);
    canvas.drawOval(const Rect.fromLTWH(8, -22, 10, 15), leafStroke);
    // 왼쪽 잎
    canvas.drawOval(const Rect.fromLTWH(-8, -22, 10, 15), leaf);
    canvas.drawOval(const Rect.fromLTWH(-8, -22, 10, 15), leafStroke);
    
    canvas.restore();
  }

  void _drawStaticBody(Canvas canvas, Paint bodyPaint, Paint stroke, Paint cheekPaint) {
    // 몸통
    Rect bodyRect = const Rect.fromLTWH(-50, -60, 100, 110);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(40)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(40)), stroke);
    // 발
    _drawFoot(canvas, bodyPaint, stroke, isLeft: true);
    _drawFoot(canvas, bodyPaint, stroke, isLeft: false);
    // 귀
    _drawStaticEar(canvas, bodyPaint, stroke, isLeft: true);
    _drawStaticEar(canvas, bodyPaint, stroke, isLeft: false);
    // 눈 (행복)
    _drawHappyEye(canvas, stroke, isLeft: true);
    _drawHappyEye(canvas, stroke, isLeft: false);
    // 볼
    canvas.drawCircle(const Offset(-30, -35), 8, cheekPaint);
    canvas.drawCircle(const Offset(30, -35), 8, cheekPaint);
  }

  void _drawFoot(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    double x = isLeft ? -35 : 35;
    canvas.drawOval(Rect.fromLTWH(x - 15, 35, 30, 20), fill);
    canvas.drawOval(Rect.fromLTWH(x - 15, 35, 30, 20), stroke);
  }

  void _drawStaticEar(Canvas canvas, Paint fill, Paint stroke, {required bool isLeft}) {
    canvas.save();
    canvas.translate(isLeft ? -25 : 25, -60);
    canvas.rotate(isLeft ? -0.2 : 0.2);
    canvas.drawOval(const Rect.fromLTWH(-12, -70, 24, 75), fill);
    canvas.drawOval(const Rect.fromLTWH(-12, -70, 24, 75), stroke);
    canvas.restore();
  }

  void _drawHappyEye(Canvas canvas, Paint stroke, {required bool isLeft}) {
    canvas.save();
    canvas.translate(isLeft ? -25 : 25, -45);
    canvas.drawPath(Path()..moveTo(-8, 0)..quadraticBezierTo(0, -8, 8, 0), stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MouthMunchPainterV5 oldDelegate) => true;
}
