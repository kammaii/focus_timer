import 'package:flutter/material.dart';
import '../../../../data/models/animal.dart';
import '../../home_controller.dart';
import 'animal_character.dart';
import 'rabbit.dart';
import 'dog.dart';

class RabbitCharacter extends AnimalCharacter {
  @override Widget get idle => const IdleRabbit();
  @override Widget get focus => const FocusRabbit();
  @override Widget get rest => const RestRabbit();
}

class DogCharacter extends AnimalCharacter {
  @override Widget get idle => const IdleDog();
  @override Widget get focus => const FocusDog();
  @override Widget get rest => const RestDog();
}

class AnimalRegistry {
  static final Map<AnimalType, AnimalCharacter> _characters = {
    AnimalType.rabbit: RabbitCharacter(),
    AnimalType.dog: DogCharacter(),
  };

  static Widget getWidget(AnimalType type, TimerState state) {
    final character = _characters[type] ?? RabbitCharacter();
    return character.buildByState(state);
  }
}
