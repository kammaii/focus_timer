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
      return EggWidget(grade: animal.grade);
    }
    
    return AnimalRegistry.getWidget(animal.type, state);
  }
}

class EggWidget extends StatelessWidget {
  final AnimalGrade grade;
  const EggWidget({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    // 둥근 알 모양
    return CustomPaint(
      size: const Size(120, 150),
      painter: EggPainter(grade: grade),
    );
  }
}

class EggPainter extends CustomPainter {
  final AnimalGrade grade;
  EggPainter({required this.grade});

  @override
  void paint(Canvas canvas, Size size) {
    final isSpecial = grade == AnimalGrade.special;

    final paint = Paint()..color = isSpecial ? Colors.amber[200]! : Colors.orange[100]!;
    final strokePaint = Paint()
      ..color = isSpecial ? Colors.orange[900]! : Colors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSpecial ? 4 : 3;

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
    final patternColor = isSpecial ? Colors.amber[600]! : Colors.orange[200]!;
    
    if (isSpecial) {
      // 스페셜 무늬
      canvas.drawCircle(Offset(size.width / 2, size.height * 0.4), 16, Paint()..color = patternColor);
      canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), 20, Paint()..color = patternColor);
      canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.65), 14, Paint()..color = patternColor);
      
      // 반짝이는 효과
      final starPaint = Paint()..color = Colors.white.withOpacity(0.8);
      canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.25), 6, starPaint);
      canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.35), 4, starPaint);
    } else {
      // 일반 무늬
      canvas.drawCircle(Offset(size.width / 2, size.height * 0.4), 10, Paint()..color = patternColor);
      canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), 15, Paint()..color = patternColor);
      canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.65), 12, Paint()..color = patternColor);
    }
  }

  @override
  bool shouldRepaint(covariant EggPainter oldDelegate) => oldDelegate.grade != grade;
}
