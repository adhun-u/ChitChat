import 'package:audioplayers/audioplayers.dart';
import 'package:chitchat/core/constants/sound.dart';
import 'package:chitchat/features/home/data/datasource/chat_function_db.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class ChatFunctionProvider extends ChangeNotifier {
  bool isSoundEnabled = true;
  bool isVibratorOn = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  ChatFunctionProvider() {
    _getSoundData();
    _getVibrationData();
  }

  //Getting the sound data from database to checking whether the sound mode is enabled or disabled
  void _getSoundData() async {
    final bool? isEnabled = await getSoundData();
    if (isEnabled == null) {
      return;
    }
    isSoundEnabled = isEnabled;
    notifyListeners();
    if (isSoundEnabled) {}
  }

  //Getting the vibration data from database to checking whether the sound mode is enabled or disabled
  void _getVibrationData() async {
    final bool? isEnabled = await getVibrationData();
    if (isEnabled == null) {
      return;
    }
    isVibratorOn = isEnabled;
    notifyListeners();
  }

  //To disable and enable the sound
  void changeSoundMode(bool isEnabled) async {
    isSoundEnabled = isEnabled;
    notifyListeners();
    await saveSoundData(isEnabled);
  }

  //To disble and enable the vibrator
  void changeVibrationMode(bool isEnabled) async {
    isVibratorOn = isEnabled;
    notifyListeners();
    await saveVibrationData(isEnabled);
  }

  //To turn on vibration
  void turnOnVibrator() async {
    //Checking the vibration mode is enabled
    if (!isVibratorOn) {
      return;
    }
    //Checking if the current device has vibration support
    final bool doesSupportVibration = await Vibration.hasVibrator();
    if (doesSupportVibration) {
      //Turning on the vibration
      await Vibration.vibrate();
    }
  }

  //To turn on the chat sound
  void turnOnChatSound() async {
    //Checking the sound mode is enabled
    if (!isSoundEnabled) {
      return;
    }

    await _audioPlayer.play(AssetSource(chatSound));
  }

  //To play sound if any member joined in group call
  void playMemberJoinedSound() async {
    if (!isSoundEnabled) {
      return;
    }

    await _audioPlayer.play(AssetSource(memberJoincallSound));
  }
}
