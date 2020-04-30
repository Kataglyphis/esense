import 'package:esense_flutter/esense.dart';
import 'package:epic_esense_app/navigation_screens/head_gestures/head_gesture.dart';

class TurnUp implements head_gesture {}

class TurnUpObserver extends head_gesture_observer {

  @override
  bool checkPreviousEvent(SensorEvent oldEvent, SensorEvent newEvent) {
    return oldEvent.gyro[2] - newEvent.gyro[2] < -4000;
  }

  @override
  bool checkNextEvent(SensorEvent oldEvent, SensorEvent newEvent) {
    return oldEvent.gyro[2] - newEvent.gyro[2] > 6000;
  }

  @override TurnUp createEvent() {

    return new TurnUp();
  }
}