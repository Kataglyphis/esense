import 'package:flutter/material.dart';
import 'package:epic_esense_app/playerWidget.dart';
import 'package:epic_esense_app/navigation_screens/new_music_player.dart';
import 'package:event_bus/event_bus.dart';
import 'package:epic_esense_app/esense.dart';


/// This Widget is the main application widget.
class MusicPlayerCanvas extends StatelessWidget {
  static const String _title = 'Canvas';
  NewMusicPlayer player;
  EventBus connectedBus;
  ESense eSense;
  int currentSong = -1;

  MusicPlayerCanvas({this.eSense, this.player,this.connectedBus, this.currentSong});

  @override
  Widget build(BuildContext context) {
    return MyStatefulWidget(
          eSense: this.eSense,
          player: this.player,
          connectedBus: this.connectedBus,
          currentSong: this.currentSong
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  //MyStatefulWidget({Key key}) : super(key: key);
  final NewMusicPlayer player;
  final EventBus connectedBus;
  final ESense eSense;
  int currentSong = 1;

  MyStatefulWidget({this.eSense, this.player, this.connectedBus, this.currentSong});
  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState(
      eSense: this.eSense,
      player: this.player,
      connectedBus: this.connectedBus,
      currentSong: this.currentSong);

}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final NewMusicPlayer player;
  final EventBus connectedBus;
  final ESense eSense;
  int currentSong = -1;

  _MyStatefulWidgetState({this.eSense, this.player, this.connectedBus, this.currentSong});

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (widget.eSense.deviceStatus == 'device_not_found') ? Colors.deepOrangeAccent : Colors.greenAccent,
      body: Align(
        alignment: Alignment.topLeft,
        child: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: widget.player.songNames.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
                onTap: () => widget.player.playSong(index),
                child: Container(
                  height: 30,
                  child: Center(
                      child: Text(
                        '${widget.player.songNames[index]}',
                        style: TextStyle(color: this.currentSong == index
                            ? Colors.blue : Colors.black),
                        maxLines: 1,
                      )),
                )
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        ),
      ),
      bottomNavigationBar: PlayerWidget(
      eSense: this.eSense,
      connectedBus: this.connectedBus,
      player: this.player
      ),
    );
  }
}