import 'package:flutter/material.dart';
import '../../../data/models/animal.dart';
import '../home_controller.dart';
import 'animals/animal_registry.dart';

class AnimalView extends StatelessWidget {
  final Animal animal;
  final TimerState state;

  const AnimalView({super.key, required this.animal, required this.state});

  @override
  Widget build(BuildContext context) {
    if (animal.level == AnimalLevel.egg) {
      return const EggWidget();
    }
    
    return AnimalRegistry.getWidget(animal.type, state);
  }
}

class EggWidget extends StatelessWidget {
  const EggWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 둥근 알 모양
    return CustomPaint(
      size: const Size(120, 150),
      painter: EggPainter(),
    );
  }
}

class EggPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.orange[100]!;
    final strokePaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // 타원형 알 모양
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height,
    );
    
    // 알 형태의 윤곽선을 그림
    final path = Path()
      ..addOval(rect);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
    
    // 무늬
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.4), 10, Paint()..color = Colors.orange[200]!);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), 15, Paint()..color = Colors.orange[200]!);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.65), 12, Paint()..color = Colors.orange[200]!);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
