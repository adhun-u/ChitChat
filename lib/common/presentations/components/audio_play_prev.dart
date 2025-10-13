import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:chitchat/common/presentations/providers/audio_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AudioPlayPrev extends StatefulWidget {
  final String audioId;
  final String audioPath;
  final String audioTitle;
  const AudioPlayPrev({
    super.key,
    required this.audioId,
    required this.audioPath,
    required this.audioTitle,
  });

  @override
  State<AudioPlayPrev> createState() => _AudioPlayPrevState();
}

class _AudioPlayPrevState extends State<AudioPlayPrev> {
  //For playing the audio when current user enters this page
  void _playAudio() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AudioProvider>().setupAudioPlayer(
        widget.audioPath,
        widget.audioId,
      );

      if (context.mounted) {
        // ignore: use_build_context_synchronously
        await context.read<AudioProvider>().playAudio();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      _playAudio();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        //Pausing the audio
        context.read<AudioProvider>().deleteAllSourceAndDispose();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          title: Text(
            widget.audioTitle,
            style: getTitleSmall(context: context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Icon(Icons.music_note, size: 50.h, color: blueColor),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.w, right: 10.w),
              child: Row(
                children: [
                  Consumer<AudioProvider>(
                    builder: (context, audio, _) {
                      return IconButton(
                        onPressed: () async {
                          //Pausing when the audio is playing
                          if (audio.currentPlayingAudioId == widget.audioId &&
                              audio.isPlaying) {
                            await context.read<AudioProvider>().pauseAudio();
                            //Resuming the audio
                          } else if (audio.currentPlayingAudioId ==
                                  widget.audioId &&
                              !audio.isPlaying) {
                            await context.read<AudioProvider>().playAudio();
                            //Otherwise setting the source and playing the audio
                          } else {
                            await context
                                .read<AudioProvider>()
                                .setupAudioPlayer(
                                  widget.audioPath,
                                  widget.audioId,
                                );

                            if (context.mounted) {
                              await context.read<AudioProvider>().playAudio();
                            }
                          }
                        },
                        icon:
                            audio.currentPlayingAudioId == widget.audioId &&
                                    audio.isPlaying
                                ? const Icon(Icons.pause)
                                : const Icon(Icons.play_arrow_rounded),
                      );
                    },
                  ),

                  SizedBox(
                    height: 25.h,
                    width: 350.w,
                    child: Consumer<AudioProvider>(
                      builder: (context, audio, _) {
                        return ProgressBar(
                          progress:
                              audio.currentPlayingAudioId == widget.audioId
                                  ? audio.currentDuration
                                  : const Duration(seconds: 0),
                          total:
                              audio.currentPlayingAudioId == widget.audioId
                                  ? audio.totalDuration
                                  : const Duration(seconds: 10),
                          onSeek: (duration) async {
                            await context.read<AudioProvider>().seekAudio(
                              duration,
                            );
                          },
                          thumbColor: darkWhite,
                          progressBarColor: blueColor,
                          thumbGlowRadius: 16.r,
                          thumbRadius: 12.r,
                          timeLabelLocation: TimeLabelLocation.none,
                          baseBarColor:
                              context.read<ThemeProvider>().isDark
                                  ? greyColor
                                  : lightGrey,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
