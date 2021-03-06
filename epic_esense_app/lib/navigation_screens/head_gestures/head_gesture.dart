import 'dart:async';

/**
 * create abstract class for a general head gesture for regulate music player
*/
import 'package:esense_flutter/esense.dart';

abstract class gesture_observer {

  /**
   * let us check here two events against each other :)
   */
  bool occured(SensorEvent new_event) => false;

  head_gesture createEvent() => null;

}

abstract class head_gesture_observer implements gesture_observer{
  bool firstCheckPassed = false;
  SensorEvent lastEvent;

  @override
  bool occured(SensorEvent new_event) {

    //first occuring event; wait for other to happening
    if(lastEvent ==null) {
      this.lastEvent = new_event;
      return false;
    }

    bool occured = false;

    if(!firstCheckPassed && this.checkPreviousEvent(this.lastEvent, new_event)) {
      this.firstCheckPassed = true;
      Timer(Duration(milliseconds: 500), () {
      this.firstCheckPassed = false;
      });
      occured = false;
    } else if (this.firstCheckPassed && this.checkNextEvent(this.lastEvent, new_event)) {
      this.firstCheckPassed = false;
      occured = true;
    }
    this.lastEvent = new_event;
    return occured;
  }

  /**
   * for any gesture detection we will have to check the previous occured event against the new occured :)
   * for each gesture other checking!
   */
  bool checkPreviousEvent(SensorEvent oldEvent, SensorEvent newEvent) => false;
  bool checkNextEvent(SensorEvent oldEvent, SensorEvent newEvent) => false;

}

abstract class head_gesture{}
class head_gesture_event_start implements head_gesture{}
class head_gesture_event_stop implements head_gesture{}