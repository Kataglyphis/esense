import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'dart:async';

import '../esense.dart';
import 'head_gestures/head_gesture.dart';
import 'head_gestures/turn_down.dart';
import 'head_gestures/turn_left.dart';
import 'head_gestures/turn_right.dart';
import 'player/PlayingControls.dart';
import 'player/PositionSeekWidget.dart';
import 'player/SongsSelector.dart';
import 'player/VolumeSelector.dart';
import 'player/model/MyAudio.dart';

class MusicPlayer extends StatefulWidget {
  @override
  _MusicPlayerState createState() => _MusicPlayerState(
    esense: this.esense,
    connectedBus: this.connectedBus,
  );

  final ESense esense;
  final connectedBus;
  MusicPlayer({this.esense, this.connectedBus});
}

class _MusicPlayerState extends State<MusicPlayer> {

  ESense esense;
  EventBus connectedBus;
  List<gesture_observer> eventCheckers = new List();
  EventBus sensorEventBus = new EventBus();
  bool listeningToGestures = false;

  _MusicPlayerState({this.esense, this.connectedBus});

  final audios = <MyAudio>[
    MyAudio(
        name: "Powerwolf - We drink your Blood",
        audio:
          Audio(
          "assets/audios/Powerwolf/Blood_of_the_Saints/03 - We Drink Your Blood.mp3",
          metas: Metas(
            title: "Metal",
            artist: "Powerwolf",
            album: "Blood of the Saints",
            image: MetasImage.asset("assets/images/powerwolf.jpg"),
          ),
        ),
        imageUrl: "https://www.laut.de/Powerwolf/powerwolf-193426.jpg"),
    MyAudio(
        name: "Powerwolf - Night of the Werewolves",
        audio:
        Audio(
          "assets/audios/Powerwolf/Blood_of_the_Saints/08 - Night of the Werewolves.mp3",
          metas: Metas(
            title: "Metal",
            artist: "Powerwolf",
            album: "Blood of the Saints",
            image: MetasImage.asset("assets/images/powerwolf.jpg"),
          ),
        ),
        imageUrl: "https://www.laut.de/Powerwolf/powerwolf-193426.jpg"),
    MyAudio(
        name: "Online",
        audio: Audio.network(
          "https://files.freemusicarchive.org/storage-freemusicarchive-org/music/Music_for_Video/springtide/Sounds_strange_weird_but_unmistakably_romantic_Vol1/springtide_-_03_-_We_Are_Heading_to_the_East.mp3",
          metas: Metas(
            title: "Online",
            artist: "Florent Champigny",
            album: "",
            image: MetasImage.network(
                "https://image.shutterstock.com/image-vector/pop-music-text-art-colorful-600w-515538502.jpg"),
          ),
        ),
        imageUrl:
        "https://image.shutterstock.com/image-vector/pop-music-text-art-colorful-600w-515538502.jpg"),
    MyAudio(
        name: "Rock",
        audio: Audio(
          "assets/audios/rock.mp3",
          metas: Metas(
            title: "Rock",
            artist: "Florent Champigny",
            album: "",
            image: MetasImage.network(
                "https://static.radio.fr/images/broadcasts/cb/ef/2075/c300.png"),
          ),
        ),
        imageUrl:
        "https://static.radio.fr/images/broadcasts/cb/ef/2075/c300.png"),

    MyAudio(
        name: "Electronic",
        audio: Audio("assets/audios/electronic.mp3"),
        imageUrl: "https://i.ytimg.com/vi/nVZNy0ybegI/maxresdefault.jpg"),
  ];

  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    _subscriptions.add(_assetsAudioPlayer.playlistFinished.listen((data) {
      print("finished : $data");
    }));
    _subscriptions.add(_assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print("playlistAudioFinished : $data");
    }));
    _subscriptions.add(_assetsAudioPlayer.current.listen((data) {
      print("current : $data");
    }));
    _subscriptions.add(_assetsAudioPlayer.onReadyToPlay.listen((audio) {
      print("onRedayToPlay : $audio");
    }));
    super.initState();

    this.sensorEventBus.on<head_gesture_event_start>()
        .listen((_) => setState(() {
      listeningToGestures = true;
    }));
    this.sensorEventBus.on<head_gesture_event_stop>()
        .listen((_) => setState(() {
      listeningToGestures = false;
    }));
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  MyAudio find(List<MyAudio> source, String fromPath) {
    return source.firstWhere((element) => element.audio.path == fromPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 48.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    StreamBuilder(
                      stream: _assetsAudioPlayer.current,
                      builder: (BuildContext context,
                          AsyncSnapshot<Playing> snapshot) {
                        final Playing playing = snapshot.data;
                        if (playing != null) {
                          final myAudio =
                          find(this.audios, playing.audio.assetAudioPath);
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Neumorphic(
                              boxShape: NeumorphicBoxShape.circle(),
                              style: NeumorphicStyle(
                                  depth: 8,
                                  surfaceIntensity: 1,
                                  shape: NeumorphicShape.concave),
                              child: Image.network(
                                myAudio.imageUrl,
                                height: 100,
                                width: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        }
                        return SizedBox();
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 20,
                ),
                StreamBuilder(
                    stream: _assetsAudioPlayer.current,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox();
                      }
                      final Playing playing = snapshot.data;
                      return Column(
                        children: <Widget>[
                          StreamBuilder(
                            stream: _assetsAudioPlayer.isLooping,
                            initialData: false,
                            builder: (context, snapshotLooping) {
                              final bool isLooping = snapshotLooping.data;
                              return StreamBuilder(
                                  stream: _assetsAudioPlayer.isPlaying,
                                  initialData: false,
                                  builder: (context, snapshotPlaying) {
                                    final isPlaying = snapshotPlaying.data;
                                    return PlayingControls(
                                      isLooping: isLooping,
                                      isPlaying: isPlaying,
                                      isPlaylist:
                                      playing.playlist.audios.length > 1,
                                      toggleLoop: () {
                                        _assetsAudioPlayer.toggleLoop();
                                      },
                                      onPlay: () {
                                        _assetsAudioPlayer.playOrPause();
                                      },
                                      onNext: () {
                                        _assetsAudioPlayer.next();
                                      },
                                      onPrevious: () {
                                        _assetsAudioPlayer.previous();
                                      },
                                    );
                                  });
                            },
                          ),
                          StreamBuilder(
                              stream: _assetsAudioPlayer.realtimePlayingInfos,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return SizedBox();
                                }
                                final RealtimePlayingInfos infos =
                                    snapshot.data;
                                //print("infos: $infos");
                                return PositionSeekWidget(
                                  currentPosition: infos.currentPosition,
                                  duration: infos.duration,
                                  seekTo: (to) {
                                    _assetsAudioPlayer.seek(to);
                                  },
                                );
                              }),
                        ],
                      );
                    }),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: StreamBuilder(
                      stream: _assetsAudioPlayer.current,
                      builder: (BuildContext context,
                          AsyncSnapshot<Playing> snapshot) {
                        final Playing playing = snapshot.data;
                        return SongsSelector(
                          audios: this.audios,
                          onPlaylistSelected: (myAudios) {
                            _assetsAudioPlayer.open(
                              Playlist(
                                  audios:
                                  myAudios.map((e) => e.audio).toList()),
                              showNotification: true,
                            );
                          },
                          onSelected: (myAudio) {
                            _assetsAudioPlayer.open(
                              myAudio.audio,
                              autoStart: false,
                              respectSilentMode: true,
                              showNotification: true,
                            );
                          },
                          playing: playing,
                        );
                      }),
                ),
                StreamBuilder(
                    stream: _assetsAudioPlayer.volume,
                    initialData: AssetsAudioPlayer.defaultVolume,
                    builder: (context, snapshot) {
                      final double volume = snapshot.data;
                      return VolumeSelector(
                        volume: volume,
                        onChange: (v) {
                          _assetsAudioPlayer.setVolume(v);
                        },
                      );
                    }),
              ],
            ),
          ),
        ),
    );
  }

  void registerSensorEventCheck(gesture_observer observer) {
    this.eventCheckers.add(observer);
  }

  void _registerSensorCheckers() {
    registerSensorEventCheck(new TurnDownObserver());
    registerSensorEventCheck(new TurnLeftObserver());
    registerSensorEventCheck(new TurnRightObserver());
  }

  void _registerSensorListeners() {
    /*sensorEventBus.on<TurnDown>()
        .listen((event) => playOrPause());
    sensorEventBus.on<TurnLeft>()
        .listen((event) => previous());
    sensorEventBus.on<TurnRight>()
        .listen((event) => next());*/
  }
}