import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:esense_flutter/esense.dart';
import 'package:event_bus/event_bus.dart';

class MusicPlayer extends StatefulWidget {
  @override
  _MusicPlayerState createState() => _MusicPlayerState(connectedBus: this.connectedBus);

  final connectedBus;
  MusicPlayer({this.connectedBus});
}

class _MusicPlayerState extends State<MusicPlayer> {
  final _volumeSubject = BehaviorSubject.seeded(1.0);
  final _speedSubject = BehaviorSubject.seeded(1.0);
  AudioPlayer _player;
  EventBus connectedBus;

  _MusicPlayerState({this.connectedBus});

  @override
  void initState() {
    super.initState();
    this._register_sensor_observer();
    this._register_sensor_listeners();
    _player = AudioPlayer();
    _player
        .setAsset('assets/audio/Powerwolf/Blood_of_the_Saints/Agnus_Dei_(Intro).mp3');
    /*_player
        .setUrl(
        "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3")
        .catchError((error) {
      // catch audio error ex: 404 url, wrong url ...
      print(error);
    });*/
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Audio Player'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Powerwolf"),
              Text("Blood of the Saints"),
              StreamBuilder<FullAudioPlaybackState>(
                stream: _player.fullPlaybackStateStream,
                builder: (context, snapshot) {
                  final fullState = snapshot.data;
                  final state = fullState?.state;
                  final buffering = fullState?.buffering;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state == AudioPlaybackState.connecting ||
                          buffering == true)
                        Container(
                          margin: EdgeInsets.all(8.0),
                          width: 64.0,
                          height: 64.0,
                          child: CircularProgressIndicator(),
                        )
                      else if (state == AudioPlaybackState.playing)
                        IconButton(
                          icon: Icon(Icons.pause),
                          iconSize: 64.0,
                          onPressed: _player.pause,
                        )
                      else
                        IconButton(
                          icon: Icon(Icons.play_arrow),
                          iconSize: 64.0,
                          onPressed: _player.play,
                        ),
                      IconButton(
                        icon: Icon(Icons.stop),
                        iconSize: 64.0,
                        onPressed: state == AudioPlaybackState.stopped ||
                            state == AudioPlaybackState.none
                            ? null
                            : _player.stop,
                      ),
                    ],
                  );
                },
              ),
              Text("Track position"),
              StreamBuilder<Duration>(
                stream: _player.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: _player.getPositionStream(),
                    builder: (context, snapshot) {
                      var position = snapshot.data ?? Duration.zero;
                      if (position > duration) {
                        position = duration;
                      }
                      return SeekBar(
                        duration: duration,
                        position: position,
                        onChangeEnd: (newPosition) {
                          _player.seek(newPosition);
                        },
                      );
                    },
                  );
                },
              ),
              Text("Volume"),
              StreamBuilder<double>(
                stream: _volumeSubject.stream,
                builder: (context, snapshot) => Slider(
                  divisions: 20,
                  min: 0.0,
                  max: 2.0,
                  value: snapshot.data ?? 1.0,
                  onChanged: (value) {
                    _volumeSubject.add(value);
                    _player.setVolume(value);
                  },
                ),
              ),
              Text("Speed"),
              StreamBuilder<double>(
                stream: _speedSubject.stream,
                builder: (context, snapshot) => Slider(
                  divisions: 10,
                  min: 0.5,
                  max: 1.5,
                  value: snapshot.data ?? 1.0,
                  onChanged: (value) {
                    _speedSubject.add(value);
                    _player.setSpeed(value);
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
  /////////////////////////////////////////////////////////////////////////////
  /////// eSense part ////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  void _register_sensor_observer() {

  }

  void _register_sensor_listeners() {

  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    @required this.duration,
    @required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue;

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: 0.0,
      max: widget.duration.inMilliseconds.toDouble(),
      value: _dragValue ?? widget.position.inMilliseconds.toDouble(),
      onChanged: (value) {
        setState(() {
          _dragValue = value;
        });
        if (widget.onChanged != null) {
          widget.onChanged(Duration(milliseconds: value.round()));
        }
      },
      onChangeEnd: (value) {
        _dragValue = null;
        if (widget.onChangeEnd != null) {
          widget.onChangeEnd(Duration(milliseconds: value.round()));
        }
      },
    );
  }

}