import 'dart:convert';
import 'dart:developer';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';

class GroupCallProvider extends ChangeNotifier {
  final Room room = Room();
  EventsListener<RoomEvent>? _eventsListener;
  bool isMuted = false;
  Map<String, RemoteParticipant> remoteParticipants = {};
  bool isCameraTurnedOff = false;
  //Connecting to enter in a call
  Future<void> connect({
    required String token,
    required bool isAudioCall,
    required Function(String username) onMemberJoined,
    required Function(String username) onMemberLeft,
    required Function() whenEveryOneLeaves,
  }) async {
    try {
      //creating a new event listener to listen whether new participant joined or removed
      _eventsListener ??= room.createListener();

      //To know who is speaking currently
      _eventsListener?.on<ActiveSpeakersChangedEvent>((event) {
        //Swaping the group members to show who spoke last
        for (var participant in event.speakers) {
          log("Remote participant identity : ${participant.identity}");
          final RemoteParticipant? removedParticipant = remoteParticipants
              .remove(participant.identity);
          if (removedParticipant != null) {
            //Creating new map
            Map<String, RemoteParticipant> newParticipantsMap = {
              participant.identity: removedParticipant,
              ...remoteParticipants,
            };
            remoteParticipants = newParticipantsMap;
            notifyListeners();
          }
        }
      });
      //To know if any user disconnected
      _eventsListener?.on<ParticipantDisconnectedEvent>((event) {
        final Map<String, dynamic>? metaData =
            event.participant.metadata != null
                ? jsonDecode(event.participant.metadata!)
                    as Map<String, dynamic>
                : null;
        if (metaData != null) {
          //Removing the user from remote participants map
          remoteParticipants.remove(event.participant.identity);
          notifyListeners();
          onMemberLeft(metaData['username']);
          if (remoteParticipants.values.isEmpty) {
            whenEveryOneLeaves();
          }
        }
      });
      //To know if any user joined
      _eventsListener?.on<ParticipantConnectedEvent>((event) {
        final Map<String, dynamic>? metaData =
            event.participant.metadata != null
                ? jsonDecode(event.participant.metadata!)
                    as Map<String, dynamic>
                : null;
        if (metaData != null) {
          //Adding new participant
          remoteParticipants[event.participant.identity] = event.participant;

          notifyListeners();
          onMemberJoined(metaData['username']);
        }
      });

      await LiveKitClient.initialize();
      await room.connect(dotenv.get('LIVEKIT_URL'), token);
      await room.localParticipant?.setMicrophoneEnabled(true);
      if (!isAudioCall) {
        await room.localParticipant?.setCameraEnabled(true);
        printDebug('Camera enabled');
      } else {
        printDebug("Its an audio call");
      }
      for (var remoteParticipant in room.remoteParticipants.values) {
        remoteParticipants[remoteParticipant.identity] = remoteParticipant;
      }
      notifyListeners();
    } catch (e) {
      printDebug("Live kit connection error : $e");
    }
  }

  //For muting and unmuting the mic of current user
  Future<void> micMuteAndUnmute() async {
    if (isMuted) {
      await room.localParticipant?.audioTrackPublications.firstOrNull?.unmute();
      isMuted = false;
    } else {
      await room.localParticipant?.audioTrackPublications.firstOrNull?.mute();
      isMuted = true;
    }
    notifyListeners();
  }

  //For switching camera
  Future<void> switchCamera() async {
    try {
      final LocalVideoTrack? localVideoTrack =
          room.localParticipant?.videoTrackPublications.firstOrNull?.track;
      if (localVideoTrack == null) {
        return;
      }

      await Helper.switchCamera(localVideoTrack.mediaStreamTrack);
    } catch (e) {
      printDebug("Camera switching error : $e");
    }
  }

  //For turning off the camera
  Future<void> turnOffAndOnCamera() async {
    try {
      if (isCameraTurnedOff) {
        isCameraTurnedOff = false;
        notifyListeners();
        await room.localParticipant?.setCameraEnabled(true);
      } else {
        isCameraTurnedOff = true;
        notifyListeners();
        await room.localParticipant?.setCameraEnabled(false);
      }
    } catch (e) {
      printDebug('Camera turning off and on error : $e');
    }
  }

  //For disposing the resources
  void disposeResource() async {
    await _eventsListener?.dispose();
    try {
      await room.disconnect();
      await room.dispose();
    } catch (e) {
      printDebug('disposing error : $e');
    }
  }
}
