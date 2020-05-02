import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:event_bus/event_bus.dart';

class NewMusicPlayer {
  final String folderPath = 'assets/audios/Powerwolf/Blood_of_the_Saints/';
  AssetsAudioPlayer player;
  List<Audio> songs = [];
  List<String> songNames = [];
  int current = -1;
  Stream<bool> isPlayingStream;
  EventBus songChangedBus;

  NewMusicPlayer({this.songChangedBus}) {
    this.player = new AssetsAudioPlayer();
    this.songNames = this._getSongNames();
    this.songs = this._initializeSongs();
    this.isPlayingStream = this.player.isPlaying;
  }

  List<String> _getSongNames() {
    return [
      '01 - Agnus Dei (Intro).mp3',
      '02 - Sanctified with Dynamite.mp3',
      '03 - We Drink Your Blood.mp3',
      '04 - Murder at Midnight.mp3',
      '05 - All We Need is Blood.mp3',
      '07 - Son of a Wolf.mp3',
      '08 - Night of the Werewolves.mp3',
      '09 - Phanoton of the Funeral.mp3'
//    Specify the names of the songs here
//    e.g.:
//      'my-song.mp3',
//      'another-song.mp3'
    ];
  }

  List<Audio> _initializeSongs() {
    List<Audio> audios = [];
    for(int i = 0; i < songNames.length; i++) {
      audios.add(new Audio(folderPath+songNames[i]));
    }

    return audios;
  }

  void playOrPause() {
    if (this.current == -1) {
      this.selectSong(0);
    }
    this.player.playOrPause();
  }

  void next() {
    int nextSong = (this.current + 1) % this.songs.length;
    this.pauseIfPlaying();
    this.selectSong(nextSong);
    this.player.play();
  }

  void previous() {
    int previousSong =
        (this.current + this.songs.length - 1) % this.songs.length;
    this.pauseIfPlaying();
    this.selectSong(previousSong);
    this.player.play();
  }

  void playSong(int songNumber) {
    if (this.current != songNumber) {
      this.pauseIfPlaying();
      this.selectSong(songNumber);
      this.player.play();
    }
  }

  bool isPlaying() {
    return !this.player.isPlaying.value;
  }

  String getSongTitle() {
    if (current == -1) {
      return '';
    } else {
      return this.songNames[current];
    }
  }

  void pauseIfPlaying() {
    if (this.isPlaying()) {
      this.player.pause();
    }
  }

  void selectSong(int number) {
    this.current = number;
    this.player.open(this.songs[number]);
    this.songChangedBus.fire(number);
  }
}