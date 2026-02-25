import 'package:flutter/material.dart';

import '../../home_controller.dart';

abstract class AnimalCharacter {
  Widget get idle;
  Widget get focus;
  Widget get rest;
  
  Widget buildByState(TimerState state) {
    switch(state) {
      case TimerState.idle: return idle;
      case TimerState.focus: return focus;
      case TimerState.rest: return rest;
    }
  }
}
