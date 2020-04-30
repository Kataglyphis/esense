import 'package:flutter/material.dart';

import 'package:epic_esense_app/navigation_screens/info.dart';
import 'package:epic_esense_app/navigation_screens/Modi.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:esense_flutter/esense.dart';
import 'dart:collection';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:epic_esense_app/navigation_screens/MusicPlayer.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

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

  EventBus connectedBus;
  EventBus songChangedBus;
  int currentSong = -1;
  bool listeningToGestures = false;

  PageController _pageController;
  var _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:
        PageView(
        children: <Widget>[
          MusicPlayer(),
          Modi(),
          Info(deviceName,
          voltage,
          deviceStatus,
          sampling,
          eventString,
          button,
          eSenseName,
          accelX,
          accelY,
          accelZ,
          gyroX,
          gyroY,
          gyroZ)

        ],
        controller: _pageController,
        physics: BouncingScrollPhysics(),
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_video),
            title: Text("Musik"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text("Modi"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            title: Text("Info"),
          )
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),

      floatingActionButton: new FloatingActionButton(
        // a floating button that starts/stops listening to sensor events.
        // is disabled until we're connected to the device.
        onPressed:
        (!ESenseManager.connected) ? null : (!sampling) ? _startListenToSensorEvents : _pauseListenToSensorEvents,
        tooltip: 'Listen to eSense sensors',
        child: (!sampling) ? Icon(Icons.play_arrow) : Icon(Icons.pause),
      ),
    );
  }
  ///
  /// Bottom Navigation tap listener
  ///
  void navigationTapped(int page) {
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _connectToESense();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _pauseListenToSensorEvents();
    ESenseManager.disconnect();
  }

  Future<void> _connectToESense() async {
    bool con = false;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    ESenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) _listenToESenseEvents();

      setState(() {
        switch (event.type) {
          case ConnectionType.connected:
            deviceStatus = 'connected';
            break;
          case ConnectionType.unknown:
            deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            deviceStatus = 'device_not_found';
            break;
        }
      });
    });

    con = await ESenseManager.connect(eSenseName);

    setState(() {
      deviceStatus = con ? 'connecting' : 'connection failed';
    });
  }

  void _listenToESenseEvents() async {
    ESenseManager.eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            deviceName = (event as DeviceNameRead).deviceName;
            break;
          case BatteryRead:
            voltage = (event as BatteryRead).voltage;
            break;
          case ButtonEventChanged:
            button = (event as ButtonEventChanged).pressed ? 'pressed' : 'not pressed';
            break;
          case AccelerometerOffsetRead:
            break;
          case AdvertisementAndConnectionIntervalRead:
          // TODO
            break;
          case SensorConfigRead:
          // TODO
            break;
        }
      });
    });

    _getESenseProperties();
  }

  void _getESenseProperties() async {
    // get the battery level every 10 secs
    Timer.periodic(Duration(seconds: 10), (timer) async => await ESenseManager.getBatteryVoltage());

    // wait 2, 3, 4, 5, ... secs before getting the name, offset, etc.
    // it seems like the eSense BTLE interface does NOT like to get called
    // several times in a row -- hence, delays are added in the following calls
    Timer(Duration(seconds: 2), () async => await ESenseManager.getDeviceName());
    Timer(Duration(seconds: 3), () async => await ESenseManager.getAccelerometerOffset());
    Timer(Duration(seconds: 4), () async => await ESenseManager.getAdvertisementAndConnectionInterval());
    Timer(Duration(seconds: 5), () async => await ESenseManager.getSensorConfig());
  }

  StreamSubscription subscription;
  void _startListenToSensorEvents() async {

    //implementing a Moving Average Filter for more precise results
    Queue queueX_accel = new Queue();
    Queue queueY_accel = new Queue();
    Queue queueZ_accel = new Queue();
    Queue queueX_gyro = new Queue();
    Queue queueY_gyro = new Queue();
    Queue queueZ_gyro = new Queue();

    // subscribe to sensor event from the eSense device
    subscription = ESenseManager.sensorEvents.listen((event) {
      //print('SENSOR event: $event');
      setState(() {
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
          accelX = ((mv_data_accel[0] / 16384) * 9.80665).toStringAsFixed(1);
          accelY = ((mv_data_accel[1] / 16384) * 9.80665).toStringAsFixed(1);
          accelZ = ((mv_data_accel[2] / 16384) * 9.80665).toStringAsFixed(1);
          
          gyroX = mv_data_gyro[0].toStringAsFixed(1);
          gyroX = mv_data_gyro[1].toStringAsFixed(1);
          gyroX = mv_data_gyro[2].toStringAsFixed(1);

          queueX_gyro.removeLast();
          queueY_gyro.removeLast();
          queueZ_gyro.removeLast();

          queueX_accel.removeLast();
          queueY_accel.removeLast();
          queueZ_accel.removeLast();
        }
        eventString = event.toString();
      });
    });
    setState(() {
      sampling = true;
    });
  }

  void _pauseListenToSensorEvents() async {
    subscription.cancel();
    setState(() {
      sampling = false;
    });
  }

  //simple moving average for less vanished results
  int _filter(Queue queue) {
    List<int> list = new List();
    queue.forEach((element) => list.add(element));
    list.sort();
    int sum = 0;
    for(var i = 0; i < list.length; i++) {
      sum += list[i];
    }
    return (sum / list.length).round();
  }

}

