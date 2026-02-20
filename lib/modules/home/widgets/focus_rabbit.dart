import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class FloppyEarRabbit extends StatefulWidget {
  const FloppyEarRabbit({super.key});

  @override
  State<FloppyEarRabbit> createState() => _FloppyEarRabbitState();
}

class _FloppyEarRabbitState extends State<FloppyEarRabbit> with TickerProviderStateMixin {
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
                  painter: FloppyEarRabbitPainter(
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
                painter: StaticBookPainter(),
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

class FloppyEarRabbitPainter extends CustomPainter {
  final double eyeX;
  final double earProgress; 
  final bool isSurprised;

  FloppyEarRabbitPainter({
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
  bool shouldRepaint(covariant FloppyEarRabbitPainter oldDelegate) => true;
}

class StaticBookPainter extends CustomPainter {
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
