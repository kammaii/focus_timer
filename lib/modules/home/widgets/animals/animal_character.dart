import 'package:flutter/material.dart';

import '../../home_controller.dart';
import '../../../../data/models/animal.dart';

abstract class AnimalCharacter {
  Widget get idle;
  Widget get focus;
  Widget get rest;
  
  AnimalGrade get grade;

  Widget buildByState(TimerState state) {
    switch(state) {
      case TimerState.idle: return idle;
      case TimerState.focus: return focus;
      case TimerState.rest: return rest;
    }
  }
}
