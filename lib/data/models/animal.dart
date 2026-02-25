import 'package:uuid/uuid.dart';

enum AnimalLevel { egg, baby, adult }
enum AnimalGrade { normal, special }

enum AnimalType {
  // 일반 알
  rabbit, 
  squirrel, 
  bird,
  // 스페셜 알
  bear, 
  tiger, 
  elephant, 
  dinosaur, dog
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
      case AnimalType.squirrel: return "다람쥐";
      case AnimalType.bird: return "작은 새";
      case AnimalType.bear: return "곰";
      case AnimalType.tiger: return "호랑이";
      case AnimalType.elephant: return "코끼리";
      case AnimalType.dinosaur: return "공룡";
      case AnimalType.dog: return "강아지";
    }
  }

  AnimalLevel get level {
    // 일반알: 알 -> 아기 (2시간 = 120분), 아기 -> 어른 (18시간 = 1080분, 누적 1200분)
    // 스페셜알: 알 -> 아기 (5시간 = 300분), 아기 -> 어른 (25시간 = 1500분, 누적 1800분)
    final isSpecial = grade == AnimalGrade.special;
    final babyThreshold = isSpecial ? 300 : 120;
    final adultThreshold = isSpecial ? 1800 : 1200;

    if (currentExpMinutes >= adultThreshold) return AnimalLevel.adult;
    if (currentExpMinutes >= babyThreshold) return AnimalLevel.baby;
    return AnimalLevel.egg;
  }

  int get maxExpForCurrentLevel {
    final isSpecial = grade == AnimalGrade.special;
    if (level == AnimalLevel.egg) {
      return isSpecial ? 300 : 120;
    } else if (level == AnimalLevel.baby) {
      return isSpecial ? 1800 : 1200;
    } else {
      return isSpecial ? 1800 : 1200;
    }
  }

  int get baseExpForCurrentLevel {
    final isSpecial = grade == AnimalGrade.special;
    if (level == AnimalLevel.egg) {
      return 0;
    } else if (level == AnimalLevel.baby) {
      return isSpecial ? 300 : 120;
    } else {
      return isSpecial ? 1800 : 1200;
    }
  }

  double get currentLevelProgress {
    if (level == AnimalLevel.adult) return 1.0;
    int baseExp = baseExpForCurrentLevel;
    int maxExp = maxExpForCurrentLevel;
    
    int currentLevelExp = currentExpMinutes - baseExp;
    int requiredExp = maxExp - baseExp;
    
    if (requiredExp <= 0) return 0.0;
    return (currentLevelExp / requiredExp).clamp(0.0, 1.0);
  }

  bool get isAdult => level == AnimalLevel.adult;

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
