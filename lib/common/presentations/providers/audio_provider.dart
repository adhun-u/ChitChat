import 'dart:developer';
import 'package:chitchat/common/application/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioService.audioPlayer;
  //Currently playing audio's current duration as string
  String currentPostion = "0.00";
  //Total duration as String of currently playing audio
  String totalPostion = "0.00";
  Duration totalDuration = Duration();
  Duration currentDuration = Duration();
  bool isPlaying = false;
  String currentPlayingAudioId = "";
  
  AudioProvider() {
    _initListeners();
  }

  //Initializing all listeners for getting current playing song details
  void _initListeners() {
    //Getting current position
    _audioPlayer.positionStream.listen((position) async {
      currentDuration = position;
      currentPostion = formatDuration(position);
      notifyListeners();
      if (double.parse(
            "${position.inMinutes}.${position.inSeconds}${position.inMilliseconds}",
          ) >=
          double.parse(
            "${totalDuration.inMinutes}.${totalDuration.inSeconds}${totalDuration.inMilliseconds}",
          )) {
        await pauseAudio();
        await _audioPlayer.seek(Duration(seconds: 0, milliseconds: 0));
      }
    });

    _audioPlayer.durationStream.listen((position) {
      if (position != null) {
        totalDuration = position;
        totalPostion = formatDuration(position);
        notifyListeners();
      }
    });

    //To know whether the audio is playing or not
    _audioPlayer.playerStateStream.listen((playerState) {
      isPlaying = playerState.playing;
      notifyListeners();
    });
  }

  //Setting the audio player to play audio
  Future<void> setupAudioPlayer(String audioPath, String audioId) async {
    try {
      currentPlayingAudioId = audioId;
      notifyListeners();
      _audioPlayer.audioSources.clear();
      await _audioPlayer.setAudioSource(AudioSource.file(audioPath));
    } catch (e) {
      log("Audio player exception : $e");
    }
  }

  //To play audio
  Future<void> playAudio() async {
    await _audioPlayer.play();
  }

  //To pause audio
  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  //For seeking audio
  Future<void> seekAudio(Duration duration) async {
    await _audioPlayer.seek(duration);
  }

  //For getting duration of the audio given
  Future<String> getDuration(String audioPath) async {
    await _audioPlayer.clearAudioSources();
    final Duration? duration = await _audioPlayer.setAudioSource(
      AudioSource.file(audioPath),
    );
    return formatDuration(duration ?? Duration());
  }

  String formatDuration(Duration duration) {
    final int minutes = duration.inSeconds ~/ 60;
    final int seconds = duration.inSeconds % 60;

    return "$minutes:${seconds.toString().padLeft(2, "0")}";
  }

  //For deleting all source from audioplayer
  Future<void> deleteAllSourceAndDispose() async {
    await _audioPlayer.stop();
    await _audioPlayer.clearAudioSources();
  }
}
