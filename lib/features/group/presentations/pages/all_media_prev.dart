import 'dart:io';

import 'package:chitchat/common/presentations/components/audio_play_prev.dart';
import 'package:chitchat/common/presentations/pages/show_image_prev.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/features/group/domain/entities/chat_storage/group_chat_storage_model.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllMediaPrev extends StatefulWidget {
  final String groupId;
  const AllMediaPrev({super.key, required this.groupId});

  @override
  State<AllMediaPrev> createState() => _AllMediaPrevState();
}

class _AllMediaPrevState extends State<AllMediaPrev> {
  @override
  void initState() {
    super.initState();
    //Fetching all media items
    context.read<GroupBloc>().add(
      FetchGroupMediaItems(groupId: widget.groupId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<GroupBloc, GroupState>(
        buildWhen: (_, current) {
          return current is GroupMediaItemsSuccessState;
        },
        builder: (context, groupState) {
          if (groupState is GroupMediaItemsSuccessState) {
            return Padding(
              padding: EdgeInsets.only(left: 10.w, top: 10.h, right: 10.w),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.8 / 2,
                  mainAxisSpacing: 10.w,
                  crossAxisSpacing: 10.w,
                ),
                itemCount: groupState.mediaItems.length,
                itemBuilder: (context, index) {
                  final GroupChatStorageModel media =
                      groupState.mediaItems[index];
                  return GestureDetector(
                    onTap: () {
                      if (media.messageType == "image") {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) {
                              return ShowImagePrev(
                                imagePath: media.imagePath,
                                username: "",
                                sentImageTime: formatDate(media.time),
                                heroTag: media.chatId,
                              );
                            },
                          ),
                        );
                      }
                      if (media.messageType == "audio") {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) {
                              return AudioPlayPrev(
                                audioId: media.chatId,
                                audioPath: media.audioPath,
                                audioTitle: media.audioTitle,
                              );
                            },
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            context.read<ThemeProvider>().isDark
                                ? greyColor
                                : darkWhite,
                        image:
                            media.messageType == "image"
                                ? DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(File(media.imagePath)),
                                )
                                : null,
                      ),
                      child:
                          media.messageType == "audio"
                              ? Icon(
                                Icons.headphones,
                                color: blueColor,
                                size: 35.h,
                              )
                              : null,
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
