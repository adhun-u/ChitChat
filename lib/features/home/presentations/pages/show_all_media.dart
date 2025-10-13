import 'dart:io';
import 'package:chitchat/common/presentations/components/audio_play_prev.dart';
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/pages/error_page.dart';
import 'package:chitchat/common/presentations/pages/show_image_prev.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/home/domain/entities/chat_storage/chat_storage_entity.dart';
import 'package:chitchat/features/home/presentations/blocs/chat/chat_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShowAllMedia extends StatefulWidget {
  final int currentUserId;
  final int oppositeUserId;
  const ShowAllMedia({
    super.key,
    required this.currentUserId,
    required this.oppositeUserId,
  });

  @override
  State<ShowAllMedia> createState() => _ShowAllMediaState();
}

class _ShowAllMediaState extends State<ShowAllMedia> {
  @override
  void initState() {
    super.initState();
    //Fetching all media
    context.read<ChatBloc>().add(
      FetchMediaEvent(
        currentUserId: widget.currentUserId,
        oppositeUserId: widget.oppositeUserId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("All Media", style: getTitleMedium(context: context)),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        buildWhen: (_, current) {
          return (current is FetchMediaErrorState) ||
              (current is FetchMediaLoadingState) ||
              (current is FetchMediaSuccessState);
        },
        builder: (context, chatState) {
          if (chatState is FetchMediaErrorState) {
            return const ErrorPage();
          }
          if (chatState is FetchMediaSuccessState) {
            return GridView.builder(
              itemCount: chatState.media.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final ChatStorageDBModel chat = chatState.media[index];
                return Padding(
                  padding: EdgeInsets.only(left: 5.w, top: 5.h),
                  child: GestureDetector(
                    onTap: () {
                      if (chat.type == "audio") {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) {
                              return AudioPlayPrev(
                                audioId: chat.chatId,
                                audioPath: chat.audioPath,
                                audioTitle: chat.audioTitle,
                              );
                            },
                          ),
                        );
                      } else if (chat.type == "image") {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) {
                              return ShowImagePrev(
                                imagePath: chat.imagePath ?? "",
                                username: "",
                                sentImageTime: "",
                                heroTag: chat.chatId,
                              );
                            },
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image:
                            chat.type == "image"
                                ? DecorationImage(
                                  fit: BoxFit.cover,

                                  image: FileImage(File(chat.imagePath ?? "")),
                                )
                                : null,
                        color:
                            context.read<ThemeProvider>().isDark
                                ? greyColor
                                : darkWhite,
                      ),
                      child:
                          chat.type == "audio"
                              ? Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: 10.w,
                                        top: 10.h,
                                      ),
                                      child: Text(
                                        chat.audioDuration,
                                        style: getBodySmall(
                                          context: context,
                                          fontweight: FontWeight.w400,
                                          color: lightGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Icon(
                                      Icons.music_note,
                                      size: 35.h,
                                      color: blueColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 10.w,
                                      right: 10.w,
                                      bottom: 10.w,
                                    ),
                                    child: Text(
                                      chat.audioTitle,
                                      style: getBodySmall(context: context),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                              : const SizedBox(),
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: LoadingIndicator(color: blueColor));
        },
      ),
    );
  }
}
