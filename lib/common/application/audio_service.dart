import 'package:just_audio/just_audio.dart';

class AudioService {
  //Creating an instance of AudioPlayer to play audio
  static AudioPlayer audioPlayer = AudioPlayer();

  void audioPlayerDispose() {
    audioPlayer.dispose();
  }
}
