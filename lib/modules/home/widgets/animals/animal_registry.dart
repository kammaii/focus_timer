import 'package:flutter/material.dart';
import '../../../../data/models/animal.dart';
import '../../home_controller.dart';
import 'animal_character.dart';
import 'rabbit.dart';
import 'dog.dart';
import 'cat.dart';
import 'squirrel.dart';
import 'hedgehog.dart';
import 'turtle.dart';
import 'tiger.dart';
import 'lion.dart';
import 'bear.dart';
import 'dinosaur.dart';

class RabbitCharacter extends AnimalCharacter {
  @override AnimalGrade get grade => AnimalGrade.normal;
  @override Widget get idle => const IdleRabbit();
  @override Widget get focus => const FocusRabbit();
  @override Widget get rest => const RestRabbit();
}

class DogCharacter extends AnimalCharacter {
  @override AnimalGrade get grade => AnimalGrade.normal;
  @override Widget get idle => const IdleDog();
  @override Widget get focus => const FocusDog();
  @override Widget get rest => const RestDog();
}

class CatCharacter extends AnimalCharacter {
  @override AnimalGrade get grade => AnimalGrade.normal;
  @override Widget get idle => const IdleCat();
  @override Widget get focus => const FocusCat();
  @override Widget get rest => const RestCat();
}

class SquirrelCharacter extends AnimalCharacter {
  @override AnimalGrade get grade => AnimalGrade.normal;
  @override Widget get idle => const IdleSquirrel();
  @override Widget get focus => const FocusSquirrel();
  @override Widget get rest => const RestSquirrel();
}

class HedgehogCharacter extends AnimalCharacter {
  @override AnimalGrade get grade => AnimalGrade.normal;
  @override Widget get idle => const IdleHedgehog();
  @override Widget get focus => const FocusHedgehog();
  @override Widget get rest => const RestHedgehog();
}

class TurtleCharacter extends AnimalCharacter {
  @override AnimalGrade get grade => AnimalGrade.special;
  @override Widget get idle => const IdleTurtle();
  @override Widget get focus => const FocusTurtle();
  @override Widget get rest => const RestTurtle();
}

class TigerCharacter extends AnimalCharacter {
  @override AnimalGrade get grade => AnimalGrade.special;
  @override Widget get idle => const IdleTiger();
  @override Widget get focus => const FocusTiger();
  @override Widget get rest => const RestTiger();
}

class LionCharacter extends AnimalCharacter {
  @override AnimalGrade get grade => AnimalGrade.special;
  @override Widget get idle => const IdleLion();
  @override Widget get focus => const FocusLion();
  @override Widget get rest => const RestLion();
}

class BearCharacter extends AnimalCharacter {
  @override AnimalGrade get grade => AnimalGrade.special;
  @override Widget get idle => const IdleBear();
  @override Widget get focus => const FocusBear();
  @override Widget get rest => const RestBear();
}

class DinosaurCharacter extends AnimalCharacter {
  @override AnimalGrade get grade => AnimalGrade.special;
  @override Widget get idle => const IdleDino();
  @override Widget get focus => const FocusDino();
  @override Widget get rest => const RestDino();
}

class AnimalRegistry {
  static final Map<AnimalType, AnimalCharacter> _characters = {
    AnimalType.rabbit: RabbitCharacter(),
    AnimalType.dog: DogCharacter(),
    AnimalType.cat: CatCharacter(),
    AnimalType.squirrel: SquirrelCharacter(),
    AnimalType.hedgehog: HedgehogCharacter(),
    AnimalType.turtle: TurtleCharacter(),
    AnimalType.tiger: TigerCharacter(),
    AnimalType.lion: LionCharacter(),
    AnimalType.bear: BearCharacter(),
    AnimalType.dinosaur: DinosaurCharacter(),
  };

  static Widget getWidget(AnimalType type, TimerState state) {
    final character = _characters[type] ?? RabbitCharacter();
    return character.buildByState(state);
  }

  static AnimalGrade getGrade(AnimalType type) {
    final character = _characters[type] ?? RabbitCharacter();
    return character.grade;
  }
}
