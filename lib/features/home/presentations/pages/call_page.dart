import 'dart:convert';
import 'package:chitchat/features/home/presentations/blocs/call/call_bloc.dart';
import 'package:chitchat/features/home/presentations/components/audio_call_prev.dart';
import 'package:chitchat/features/home/presentations/components/video_call_pre.dart';
import 'package:chitchat/features/home/presentations/providers/call_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class CallPage extends StatefulWidget {
  final String displayName;
  final String imageUrl;
  final int userId;
  final int currentUserId;
  final String currentUsername;
  final String currentUserProfilePic;
  final bool isSomeCalling;
  final bool isAudioCall;
  const CallPage({
    super.key,
    required this.displayName,
    required this.imageUrl,
    required this.userId,
    required this.currentUserId,
    required this.currentUsername,
    required this.currentUserProfilePic,
    required this.isSomeCalling,
    required this.isAudioCall,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late final ValueNotifier<bool> muteMicNotifier = ValueNotifier(false);
  late final ValueNotifier<bool> speakerModeNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    //Initializing renderers
    initRenderer();
    //Connecting call websocket
    context.read<CallBloc>().add(
      ConnectCallSocket(
        currentUserId: widget.currentUserId,
        oppositeUserId: widget.userId,
        currentUserProfilePic: widget.currentUserProfilePic,
      ),
    );
  }

  //For initializing local and remote renderers
  void initRenderer() async {
    context.read<CallProvider>().initRenderers(
      onInitialized: () async {
        if (!widget.isSomeCalling) {
          await context.read<CallProvider>().createOffer(
            onOfferCreated: (offer) {
              context.read<CallBloc>().add(
                CreateCallOfferEvent(
                  offer: jsonEncode(offer.toMap()),
                  currentUserId: widget.currentUserId,
                  calleeId: widget.userId,
                  callType: widget.isAudioCall ? "audio" : "video",
                  currentUsername: widget.currentUsername,
                ),
              );
            },
          );
          //Starting the timer
          if (context.mounted) {
            // ignore: use_build_context_synchronously
            context.read<CallBloc>().add(StartTimerEvent());
          }
        } else {
          //First getting the offer that caller created
          if (context.mounted) {
            // ignore: use_build_context_synchronously
            context.read<CallBloc>().add(
              GetOfferEvent(
                currentUserId: widget.currentUserId,
                userId: widget.userId,
              ),
            );
          }
        }
      },
      onIceCandidate: (candidate) {
        //Sending candidate info to caller or callee
        context.read<CallBloc>().add(
          PostCandidateEvent(
            data: jsonEncode(candidate.toMap()),
            callerId:
                widget.isSomeCalling ? widget.userId : widget.currentUserId,
            calleeId:
                widget.isSomeCalling ? widget.currentUserId : widget.userId,
          ),
        );
      },
      onConnectionClosed: () {
      },
      onConnectionConnected: () {
        //Sending the indication to calle or caller that call is connected
        context.read<CallBloc>().add(
          SendCallIndicationEvent(
            callerId:
                widget.isSomeCalling ? widget.userId : widget.currentUserId,
            calleeId:
                widget.isSomeCalling ? widget.currentUserId : widget.userId,
            type: "CALL-CONNECTED",
          ),
        );
      },
      onConnectionConnectingState: () {
        //Sending the indication to calle or caller that call is in connecting stae
        context.read<CallBloc>().add(
          SendCallIndicationEvent(
            callerId:
                widget.isSomeCalling ? widget.userId : widget.currentUserId,
            calleeId:
                widget.isSomeCalling ? widget.currentUserId : widget.userId,
            type: "CALL-CONNECTING",
          ),
        );
      },
      isAudioCall: widget.isAudioCall,
    );
  }

  @override
  void dispose() {
    muteMicNotifier.dispose();
    speakerModeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        //Closing websocket connection
        context.read<CallBloc>().add(CloseCallWebSocketConnection());
      },
      child: Scaffold(
        body:
            widget.isAudioCall
                ? AudioCallPrev(
                  calleeId:
                      widget.isSomeCalling
                          ? widget.currentUserId
                          : widget.userId,
                  callerId:
                      widget.isSomeCalling
                          ? widget.userId
                          : widget.currentUserId,
                  displayName: widget.displayName,
                  imageUrl: widget.imageUrl,
                )
                : VideoCallPre(
                  oppositUserProfilePic: widget.imageUrl,
                  calleeId:
                      widget.isSomeCalling
                          ? widget.currentUserId
                          : widget.userId,
                  callerId:
                      widget.isSomeCalling
                          ? widget.userId
                          : widget.currentUserId,
                ),
      ),
    );
  }
}
