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
import 'package:epic_esense_app/navigation_screens/new_music_player.dart';
import 'package:epic_esense_app/navigation_screens/MusicPlayerCanvas.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String eSenseName = 'eSense-0414';
  NewMusicPlayer mp;
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
        actions: <Widget>[
          this.createGestureButton(context)
        ],
      ),
      body:
        PageView(
        children: <Widget>[
          MusicPlayerCanvas(eSense: esense,player: mp, connectedBus: connectedBus, songChangedBus: this.songChangedBus),
          Modi(esense: esense),
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
      //floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: new FloatingActionButton(
        // a floating button that starts/stops listening to sensor events.
        // is disabled until we're connected to the device.
        onPressed: (!ESenseManager.connected) ? this.connectESense : this.disconnectESense,
        tooltip: 'Listen to eSense sensors',
        child: (this.state == 'disconnected') ? Icon(Icons.bluetooth_disabled) : Icon(Icons.bluetooth_connected),
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
    this.mp = NewMusicPlayer(songChangedBus: this.songChangedBus);
    this.esense = new ESense();
    this.connectedBus = new EventBus();

    this.state = 'disconnected';
    _pageController = PageController();

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
    //ESenseManager.disconnect();
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

  Widget createGestureButton(BuildContext context) {
    FlatButton button;
    if (this.listeningToGestures == true) {
      button = FlatButton(
        onPressed: this.esense.stopListenToSensorEvents,
        child: Container(
          child: Icon(Icons.hearing, color: Colors.blue,),
          color: Colors.white,

        ),

      );
    } else if (this.listeningToGestures == false) {
      button = FlatButton(
        onPressed: this.esense.startListenToSensorEvents,
        child: Icon(Icons.record_voice_over, color: Colors.white,),
      );
    }
    Widget content = Visibility(
      child: button,
      visible: this.state == 'connected',
    );
    return content;
  }
}

