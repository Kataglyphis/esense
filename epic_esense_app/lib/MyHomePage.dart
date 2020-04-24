import 'package:flutter/material.dart';

import 'package:epic_esense_app/navigation_screens/info.dart';
import 'package:epic_esense_app/navigation_screens/Modi.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:esense_flutter/esense.dart';

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
  int offsetX = -1;
  int offsetY = -1;
  int offsetZ = -1;

  PageController _pageController;
  var _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView(
        children: <Widget>[
          Modi(),
          Info(deviceName,
          voltage,
          deviceStatus,
          sampling,
          eventString,
          button,
          eSenseName,
          offsetX,
          offsetY,
          offsetZ)

        ],
        controller: _pageController,
        physics: BouncingScrollPhysics(),
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text("Modi"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            title: Text("Info"),
          ),
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
            offsetX = (event as AccelerometerOffsetRead).offsetX;
            offsetY = (event as AccelerometerOffsetRead).offsetY;
            offsetZ = (event as AccelerometerOffsetRead).offsetZ;
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
    Timer(Duration(seconds: 4), () async => await ESenseManager.getAccelerometerOffset());
    Timer(Duration(seconds: 6), () async => await ESenseManager.getAdvertisementAndConnectionInterval());
    Timer(Duration(seconds: 8), () async => await ESenseManager.getSensorConfig());
  }

  StreamSubscription subscription;
  void _startListenToSensorEvents() async {
    // subscribe to sensor event from the eSense device
    subscription = ESenseManager.sensorEvents.listen((event) {
      print('SENSOR event: $event');
      setState(() {
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

}

