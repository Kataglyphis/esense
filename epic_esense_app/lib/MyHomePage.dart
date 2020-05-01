import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:epic_esense_app/navigation_screens/head_gestures/head_gesture.dart';
import 'package:epic_esense_app/navigation_screens/info.dart';
import 'package:epic_esense_app/navigation_screens/Modi.dart';
import 'dart:async';
import 'package:esense_flutter/esense.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:epic_esense_app/navigation_screens/MusicPlayer.dart';
import 'package:epic_esense_app/navigation_screens/head_gestures/turn_down.dart';
import 'package:epic_esense_app/navigation_screens/head_gestures/turn_up.dart';
import 'package:epic_esense_app/navigation_screens/head_gestures/turn_left.dart';
import 'package:epic_esense_app/navigation_screens/head_gestures/turn_right.dart';
import 'package:epic_esense_app/esense.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String eSenseName = 'eSense-0414';
  MusicPlayer mp;
  ESense esense;
  EventBus connectedBus;
  EventBus songChangedBus;
  String state = 'disconnected';
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
          mp,
          Modi(),
          Info(esense),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: new FloatingActionButton(
        // a floating button that starts/stops listening to sensor events.
        // is disabled until we're connected to the device.
        onPressed: (this.state == "disconnected") ? this.connectESense : this.disconnectESense,
        tooltip: 'Listen to eSense sensors',
        child: (this.state == "connected") ? Icon(Icons.play_arrow) : Icon(Icons.pause),
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
    this.songChangedBus = new EventBus();
    this.connectedBus = new EventBus();
    this.esense = new ESense();
    this.state = 'disconnected';
    _pageController = PageController();
    this.mp = MusicPlayer(esense: this.esense,connectedBus: this.connectedBus);

    connectESense();

    this.songChangedBus.on()
        .listen((current) => setState(() {
      currentSong = current;
    }));
    this.esense.sensorEventBus.on<head_gesture_event_start>()
        .listen((_) => setState(() {
      listeningToGestures = true;
    }));
    this.esense.sensorEventBus.on<head_gesture_event_stop>()
        .listen((_) => setState(() {
      listeningToGestures = false;
    }));
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    esense.stopListenToSensorEvents();
    ESenseManager.disconnect();
  }

  void connectESense({String name = ''}) {
    setState(() {
      state = 'connecting';
    });
    this.esense.connectToESense(name: this.eSenseName)
        .then((event) {
      setState(() {
        state = 'connected';
      });
      this.connectedBus.fire(event);
    });
  }

  void disconnectESense() {
    this.esense.disconnectFromESense()
        .then((event) {
      setState(() {
        state = 'disconnected';
        listeningToGestures = false;
      });
    });
  }
}

