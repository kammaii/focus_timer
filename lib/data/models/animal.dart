import 'package:uuid/uuid.dart';

enum AnimalLevel { egg, animal }
enum AnimalGrade { normal, special }

enum AnimalType {
  // 일반 알 (4종)
  rabbit, 
  cat,
  squirrel,
  hedgehog,
  // 스페셜 알 (6종)
  dog,
  turtle,
  tiger,
  lion,
  bear,
  dinosaur
}

class Animal {
  final String id;
  final AnimalType type;
  final AnimalGrade grade;
  final String name;
  int currentExpMinutes;

  Animal({
    String? id,
    required this.type,
    required this.grade,
    String? name,
    this.currentExpMinutes = 0,
  }) : id = id ?? const Uuid().v4(),
       name = name ?? _getDefaultName(type);

  static String _getDefaultName(AnimalType type) {
    switch (type) {
      case AnimalType.rabbit: return "토끼";
      case AnimalType.cat: return "고양이";
      case AnimalType.squirrel: return "다람쥐";
      case AnimalType.hedgehog: return "고슴도치";
      case AnimalType.dog: return "강아지";
      case AnimalType.turtle: return "거북이";
      case AnimalType.tiger: return "호랑이";
      case AnimalType.lion: return "사자";
      case AnimalType.bear: return "곰";
      case AnimalType.dinosaur: return "공룡";
    }
  }

  AnimalLevel get level {
    // 일반알: 알 -> 동물 (2시간 = 120분)
    // 스페셜알: 알 -> 동물 (5시간 = 300분)
    final isSpecial = grade == AnimalGrade.special;
    final animalThreshold = isSpecial ? 300 : 120;

    if (currentExpMinutes >= animalThreshold) return AnimalLevel.animal;
    return AnimalLevel.egg;
  }

  int get maxExpForCurrentLevel {
    final isSpecial = grade == AnimalGrade.special;
    if (level == AnimalLevel.egg) {
      return isSpecial ? 300 : 120;
    } else {
      return isSpecial ? 1800 : 1200;
    }
  }

  int get baseExpForCurrentLevel {
    final isSpecial = grade == AnimalGrade.special;
    if (level == AnimalLevel.egg) {
      return 0;
    } else {
      return isSpecial ? 300 : 120;
    }
  }

  double get currentLevelProgress {
    if (isReadyToCollect) return 1.0;
    int baseExp = baseExpForCurrentLevel;
    int maxExp = maxExpForCurrentLevel;
    
    int currentLevelExp = currentExpMinutes - baseExp;
    int requiredExp = maxExp - baseExp;
    
    if (requiredExp <= 0) return 0.0;
    return (currentLevelExp / requiredExp).clamp(0.0, 1.0);
  }

  bool get isReadyToCollect {
    final isSpecial = grade == AnimalGrade.special;
    final collectThreshold = isSpecial ? 1800 : 1200;
    return currentExpMinutes >= collectThreshold;
  }

  void addExp(int minutes) {
    currentExpMinutes += minutes;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'grade': grade.name,
      'name': name,
      'currentExpMinutes': currentExpMinutes,
    };
  }

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      type: AnimalType.values.firstWhere((e) => e.name == json['type']),
      grade: AnimalGrade.values.firstWhere((e) => e.name == json['grade']),
      name: json['name'],
      currentExpMinutes: json['currentExpMinutes'] ?? 0,
    );
  }
}
