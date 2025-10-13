import 'dart:convert';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallProvider extends ChangeNotifier {
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  //For initializing renderers for getting remote audio,video and local audio and video
  void initRenderers({
    required Function() onInitialized,
    required Function(RTCIceCandidate candidate) onIceCandidate,
    required Function() onConnectionClosed,
    required Function() onConnectionConnected,
    required Function() onConnectionConnectingState,
    required bool isAudioCall,
  }) async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    await _initWebRTC(
      onInitialized: onInitialized,
      onIceCandidate: onIceCandidate,
      isAudioCall: isAudioCall,
      onConnectionClosed: onConnectionClosed,
      onConnectionConnected: onConnectionConnected,
      onConnectionConnectingState: onConnectionConnectingState,
    );
  }

  //Initializing webrtc for activating real time communication with callee
  Future<void> _initWebRTC({
    required Function() onInitialized,
    required Function(RTCIceCandidate candidate) onIceCandidate,
    required Function() onConnectionClosed,
    required Function() onConnectionConnected,
    required Function() onConnectionConnectingState,
    required bool isAudioCall,
  }) async {
    final Map<String, dynamic> config = {
      'iceServers': [
        {'urls': dotenv.env['ICE_SERVER_URL']},
      ],
    };

    //Assigning peer connect with ice servers
    _peerConnection = await createPeerConnection(config);
    //Getting current user media
    _localStream = await navigator.mediaDevices.getUserMedia({
      "audio": true,
      "video": !isAudioCall,
    });

    //Assigning the local stream with current user's stream (audio,video)
    localRenderer.srcObject = _localStream;

    _localStream?.getTracks().forEach((track) async {
      await _peerConnection?.addTrack(track, _localStream!);
    });

    _peerConnection?.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    //For knowing whether the connection is closed , connected or connecting
    _peerConnection?.onConnectionState = (connectionState) {
      if (connectionState ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        onConnectionConnected();
      }
      if (connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        onConnectionClosed();
      }
      if (connectionState ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnecting) {
        onConnectionConnectingState();
      }
    };

    _peerConnection?.onIceConnectionState = (iceConnState) {};

    _peerConnection?.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        onIceCandidate(candidate);
      }
    };

    onInitialized();
    notifyListeners();
  }

  //For creating offer to make a call with callee and to notify callee that caller wants to call
  Future<void> createOffer({
    required Function(RTCSessionDescription offer) onOfferCreated,
  }) async {
    //Creating an offer to get current user sdp info
    final RTCSessionDescription? offer = await _peerConnection?.createOffer();
    if (offer != null) {
      await _peerConnection?.setLocalDescription(offer);
      onOfferCreated(offer);
      notifyListeners();
    }
  }

  //For answering the offer that caller created
  Future<void> answerOffer({
    required Map<String, dynamic> rtcSessionDes,
    required Function(RTCSessionDescription answer) onAnswerCreated,
  }) async {
    final RTCSessionDescription remoteDes = RTCSessionDescription(
      rtcSessionDes['sdp'],
      rtcSessionDes['type'],
    );
    await _peerConnection?.setRemoteDescription(remoteDes);
    final RTCSessionDescription? answer = await _peerConnection?.createAnswer();
    if (answer != null) {
      await _peerConnection?.setLocalDescription(answer);
      onAnswerCreated(answer);
      notifyListeners();
    }
  }

  //For getting the answer that callee created
  Future<void> getAnswer({required Map<String, dynamic> rtcSessionDes}) async {
    final RTCSessionDescription remoteDes = RTCSessionDescription(
      rtcSessionDes['sdp'],
      rtcSessionDes['type'],
    );

    if (await _peerConnection?.getRemoteDescription() == null) {
      await _peerConnection?.setRemoteDescription(remoteDes);
      notifyListeners();
    }
  }

  //For fetching ice candidates to complete the webrtc connection
  Future<void> fetchICECandidates({
    required List<dynamic> candidatesData,
  }) async {
    for (var data in candidatesData) {
      final Map<String, dynamic> candidate =
          data['data'] is String
              ? jsonDecode(data['data']) as Map<String, dynamic>
              : Map<String, dynamic>.from(data['data']);

      //Extracting sdpMid , sdpMLineIndex , candidate
      final RTCIceCandidate iceCandidate = RTCIceCandidate(
        candidate['candidate'] as String?,
        candidate['sdpMid'] as String?,
        (candidate['sdpMLineIndex'] as num?)?.toInt(),
      );

      if (await _peerConnection?.getRemoteDescription() != null) {
        await _peerConnection?.addCandidate(iceCandidate);
        notifyListeners();
      }
    }
  }

  //For disposing renderers and streams
  Future<void> disposeRenderesAndStreams() async {
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    _localStream?.getTracks().forEach((track) async {
      await track.stop();
    });
    await _localStream?.dispose();
    await _peerConnection?.close();

    if (localRenderer.renderVideo) {
      await localRenderer.dispose();
    }
    if (remoteRenderer.renderVideo) {
      await remoteRenderer.dispose();
    }
  }

  //Muting the mic so that the callee can't hear
  Future<void> micMuteAndUnmute({required bool mute}) async {
    _localStream?.getAudioTracks().forEach((audioTrack) {
      audioTrack.enabled = !mute;
    });
  }

  //For switching from ear piece to speacker
  Future<void> switchSpeackerMode({required bool speaker}) async {
    await Helper.setSpeakerphoneOn(speaker);
  }

  //For switching camera
  Future<void> switchCamera() async {
    try {
      if (_localStream == null) {
        return;
      }
      final MediaStreamTrack videoTrack = _localStream!.getVideoTracks().first;

      await Helper.switchCamera(videoTrack);
    } catch (e) {
      printDebug('Camera switching error : $e');
    }
  }
}
