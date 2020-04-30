import 'package:esense_flutter/esense.dart';
import 'package:epic_esense_app/navigation_screens/head_gestures/head_gesture.dart';

class TurnDown implements head_gesture {}

class TurnDownObserver extends head_gesture_observer {

  @override
  bool checkPreviousEvent(SensorEvent oldEvent, SensorEvent newEvent) {
    return oldEvent.gyro[2] - newEvent.gyro[2] > 4000;
  }

  @override
  bool checkNextEvent(SensorEvent oldEvent, SensorEvent newEvent) {
    return oldEvent.gyro[2] - newEvent.gyro[2] < -6000;
  }

  @override TurnDown createEvent() {

    return new TurnDown();
  }
}