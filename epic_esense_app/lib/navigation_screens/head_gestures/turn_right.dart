import 'package:esense_flutter/esense.dart';
import 'package:epic_esense_app/navigation_screens/head_gestures/head_gesture.dart';

class TurnRight implements head_gesture {}

class TurnRightObserver extends head_gesture_observer {

  @override
  bool checkPreviousEvent(SensorEvent oldEvent, SensorEvent newEvent) {
    return oldEvent.gyro[1] - newEvent.gyro[1] > 2000;
  }

  @override
  bool checkNextEvent(SensorEvent oldEvent, SensorEvent newEvent) {
    return oldEvent.gyro[1] - newEvent.gyro[1] < -2000;
  }

  @override TurnRight createEvent() {

    return new TurnRight();
  }
}