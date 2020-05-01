import 'dart:collection';

import 'package:epic_esense_app/navigation_screens/head_gestures/head_gesture.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:esense_flutter/esense.dart';

class ESense {

  String deviceName = 'Unknown';
  double voltage = -1;
  String deviceStatus = '';
  bool sampling = false;
  String eventString = '';
  String button = 'not pressed';
  String eSenseName = 'eSense-0414';
  String accelX = 'to be filled with';
  String accelY = 'to be filled with';
  String accelZ = 'to be filled with';
  String gyroX = 'to be filled with';
  String gyroY = 'to be filled with';
  String gyroZ = 'to be filled with';
  String accelerometer;

  bool listening = false;

  Map<Type, List<Function>> eSenseHandlers = {};
  List<head_gesture_observer> eventCheckers = [];
  bool checked = false;
  StreamSubscription sensorSubscription;
  StreamSubscription eSenseSubscription;
  EventBus sensorEventBus = new EventBus();

  Future<ConnectionEvent> connectToESense({String name = 'eSense-0414'}) {

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    var result = ESenseManager.connectionEvents.firstWhere((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) {
        listenToESenseEvents();
        return true;
      }
      return false;
    });

    ESenseManager.connect(eSenseName);
    return result;
  }

  Future<ConnectionEvent> disconnectFromESense() {
    var result =  ESenseManager.connectionEvents.firstWhere((event) {

      if (event.type == ConnectionType.disconnected) {
        this.eSenseSubscription.cancel();
        return true;
      }
      return false;
    });
    ESenseManager.disconnect();
    return result;
  }

  void listenToESenseEvents() {
    this.eSenseSubscription = ESenseManager.eSenseEvents.listen((event) {
      if (this.eSenseHandlers.containsKey(event.runtimeType)) {
        this.eSenseHandlers[event.runtimeType].forEach((fun) => fun(event));
      }
    });
  }

  void registerSensorEventCheck(head_gesture_observer observer) {
    this.eventCheckers.add(observer);
  }

  void startListenToSensorEvents() async {
    this.listening = true;
    this.sensorEventBus.fire(new head_gesture_event_start());
    this.sensorSubscription = ESenseManager.sensorEvents.listen((event) {
      for (var check in this.eventCheckers) {
        if (!this.checked && check.occured(event)) {
          this.checked = true;
          this.sensorEventBus.fire(check.createEvent());
          Timer(Duration(seconds: 2), () => this.checked = false);
        }
      }
    });
    //implementing a Moving Average Filter for more precise results
    /*Queue queueX_accel = new Queue();
    Queue queueY_accel = new Queue();
    Queue queueZ_accel = new Queue();
    Queue queueX_gyro = new Queue();
    Queue queueY_gyro = new Queue();
    Queue queueZ_gyro = new Queue();

    // subscribe to sensor event from the eSense device
    subscription = ESenseManager.sensorEvents.listen((event) {
      //print('SENSOR event: $event');
        if(queueX_accel.length <= 10) {

          queueX_gyro.addFirst(event.gyro[0]);
          queueY_gyro.addFirst(event.gyro[1]);
          queueZ_gyro.addFirst(event.gyro[2]);

          queueX_accel.addFirst(event.accel[0]);
          queueY_accel.addFirst(event.accel[1]);
          queueZ_accel.addFirst(event.accel[2]);

        } else {

          List<int> mv_data_accel = new List();
          List<int> mv_data_gyro = new List();
          const int offsetX = -5504;
          const int offsetY = -5568;
          const int offsetZ = 9580;

          mv_data_accel.add(_filter(queueX_accel) - offsetX);
          mv_data_accel.add(_filter(queueY_accel) - offsetY);
          mv_data_accel.add(_filter(queueZ_accel) - offsetZ);

          mv_data_gyro.add(_filter(queueX_gyro));
          mv_data_gyro.add(_filter(queueY_gyro));
          mv_data_gyro.add(_filter(queueZ_gyro));

          //BLEeSense specs page 16 very bottom of page
          accelX = ((mv_data_accel[0] / 8192) * 9.80665).toStringAsFixed(1);
          accelY = ((mv_data_accel[1] / 8192) * 9.80665).toStringAsFixed(1);
          accelZ = ((mv_data_accel[2] / 8192) * 9.80665).toStringAsFixed(1);

          gyroX = mv_data_gyro[0].toStringAsFixed(1);
          gyroY = mv_data_gyro[1].toStringAsFixed(1);
          gyroZ = mv_data_gyro[2].toStringAsFixed(1);

          queueX_gyro.removeLast();
          queueY_gyro.removeLast();
          queueZ_gyro.removeLast();

          queueX_accel.removeLast();
          queueY_accel.removeLast();
          queueZ_accel.removeLast();
        }
        eventString = event.toString();
      });
    sampling = true;*/

  }
  void stopListenToSensorEvents() {
    this.sensorSubscription.cancel();
    this.listening = false;
    this.sensorEventBus.fire(new head_gesture_event_stop());
  }

  void registerESenseHandler(Type type, Function func) {
    if (!this.eSenseHandlers.containsKey(type)) {
      this.eSenseHandlers[type] = [];
    }
    this.eSenseHandlers[type].add(func);
  }

  void registerDeviceNameReadHandler(Function func) {
    this.registerESenseHandler(DeviceNameRead, func);
  }

  void registerBatteryReadHandler(Function func) {
    this.registerESenseHandler(BatteryRead, func);
  }

  void registerButtonChangedHandler(Function func) {
    this.registerESenseHandler(ButtonEventChanged, func);
  }

  //simple moving average for less vanished results
  int _filter(Queue queue) {
    List<int> list = [];
    queue.forEach((element) => list.add(element));
    list.sort();
    int sum = 0;
    for(var i = 0; i < list.length; i++) {
      sum += list[i];
    }
    return (sum / list.length).round();
  }
}