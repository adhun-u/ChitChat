import 'dart:async';
import 'package:flutter/material.dart';

class TimeProvider extends ChangeNotifier {
  Duration changingDur = Duration(seconds: 60);
  String currentTime = "01:00";
  String recordingTime = "00.00";
  Duration changingRecorderDur = Duration(seconds: 0);
  Timer? _timer;

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  //Setting up the time for starting
  void setupTime() {
    _timer?.cancel();
    changingDur = const Duration(seconds: 60);
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _decreaseDuration(),
    );
  }

  //Decreasing each seconds
  void _decreaseDuration() {
    //Cancelling the timer when the duration is 0 seconds
    if (changingDur <= Duration(seconds: 0)) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    final int changingSec = changingDur.inSeconds - 1;
    changingDur = Duration(seconds: changingSec);
    currentTime = formatTimerDuration(changingDur);
    notifyListeners();
  }

  //Formatting the duration
  String formatTimerDuration(Duration duration) {
    final String minutes = _twoDigits(duration.inMinutes.remainder(60));
    final String seconds = _twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  //For showing recording time
  void setupRecorderTime() {
    _timer?.cancel();
    recordingTime = "00.00";
    notifyListeners();
    changingRecorderDur = const Duration(seconds: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _increaseTime());
  }

  void _increaseTime() {
    final int changingSec = changingRecorderDur.inSeconds + 1;
    changingRecorderDur = Duration(seconds: changingSec);
    recordingTime = formatTimerDuration(changingRecorderDur);
    notifyListeners();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
