import 'dart:io';
import 'package:chitchat/common/data/models/current_user_model.dart';
import 'package:chitchat/common/presentations/components/app_text_field.dart';
import 'package:chitchat/common/presentations/components/image_picker_sheet.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/icons.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:chitchat/features/group/presentations/components/dialog_loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  late final TextEditingController groupNameController =
      TextEditingController();
  late final TextEditingController groupBioController = TextEditingController();

  late final ValueNotifier<XFile?> imageNotifier = ValueNotifier(null);
  late final ValueNotifier<bool> isEmptyNotifier = ValueNotifier(true);

  late final CurrentUserModel currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = context.read<CurrentUserProvider>().currentUser;
  }

  @override
  void dispose() {
    imageNotifier.dispose();
    groupNameController.dispose();
    groupBioController.dispose();
    isEmptyNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: Text(
          'Create group',
          style: getTitleMedium(context: context, fontweight: FontWeight.bold),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: isEmptyNotifier,
            builder: (context, isGroupNameEmpty, child) {
              return CupertinoButton(
                onPressed: () {
                  if (isGroupNameEmpty) {
                    return;
                  }
                  //Creating group
                  context.read<GroupBloc>().add(
                    CreateGroupEvent(
                      groupName: groupNameController.text.trim(),
                      groupBio: groupBioController.text.trim(),
                      currentUserId: currentUser.userId,
                      groupImagePath:
                          imageNotifier.value != null
                              ? imageNotifier.value!.path
                              : "",
                    ),
                  );
                },
                child: Text(
                  'Create',
                  style: getTitleMedium(
                    context: context,
                    fontweight: FontWeight.bold,
                    color: isGroupNameEmpty ? lightGrey : blueColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          BlocListener<GroupBloc, GroupState>(
            listenWhen: (_, current) {
              return current is CreateGroupLoadingState ||
                  current is CreateGroupErrorState ||
                  current is CreateGroupSuccessState;
            },
            listener: (context, groupState) {
              if (groupState is CreateGroupLoadingState) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return DialogLoadingIndicator(
                      loadingText: 'Creating group',
                    );
                  },
                );
              }
              if (groupState is CreateGroupSuccessState) {
                Navigator.of(context).pop();
                showSuccessMessage(context, groupState.message);
                context.read<GroupBloc>().add(
                  FetchGroupsEvent(
                    currentUserId:
                        context.read<CurrentUserProvider>().currentUser.userId,
                  ),
                );
                Navigator.of(context).pop();
              }
              if (groupState is CreateGroupErrorState) {
                Navigator.of(context).pop();
                showErrorMessage(context, groupState.message);
                context.read<GroupBloc>().add(
                  FetchGroupsEvent(
                    currentUserId:
                        context.read<CurrentUserProvider>().currentUser.userId,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const SizedBox(),
          ),
          Padding(
            padding: EdgeInsets.only(left: 40.w, top: 10.h),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'GROUP NAME',
                style: getTitleSmall(
                  context: context,
                  fontweight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          10.verticalSpace,
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: AppTextField(
              controller: groupNameController,
              prefix: const Icon(Icons.group),
              hintText: "Enter group name",
              maxLength: 30,
              obscureText: false,
              suffix: null,
              onChanged: (text) {
                isEmptyNotifier.value = text.isEmpty;
              },
            ),
          ),
          10.verticalSpace,
          Padding(
            padding: EdgeInsets.only(left: 40.w, top: 10.h),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'GROUP BIO',
                style: getTitleSmall(
                  context: context,
                  fontweight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          10.verticalSpace,
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: AppTextField(
              controller: groupBioController,
              prefix: const Icon(Icons.edit),
              hintText: "Enter group bio",
              maxLength: 200,
              maxLines: 3,
              obscureText: false,
              suffix: null,
            ),
          ),
          10.verticalSpace,
          Padding(
            padding: EdgeInsets.only(left: 40.w, top: 10.h),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'GROUP IMAGE',
                style: getTitleSmall(
                  context: context,
                  fontweight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 40.w, top: 10.h),
            child: Align(
              alignment: Alignment.topLeft,
              child: ValueListenableBuilder(
                valueListenable: imageNotifier,
                builder: (context, imageFile, child) {
                  return GestureDetector(
                    onTap: () {
                      showBottomSheet(
                        context: context,
                        builder: (context) {
                          return ImagePickerSheet(
                            onCameraClick: (image) {
                              FocusScope.of(context).unfocus();
                              imageNotifier.value = image;
                            },
                            onGalleryClick: (image) {
                              FocusScope.of(context).unfocus();
                              imageNotifier.value = image;
                            },
                          );
                        },
                      );
                    },
                    child: Consumer<ThemeProvider>(
                      builder: (context, theme, child) {
                        return Container(
                          height: 150.h,
                          width: 150.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: theme.isDark ? greyColor : darkWhite,
                            image:
                                imageFile != null
                                    ? DecorationImage(
                                      fit: BoxFit.cover,
                                      opacity: 0.7,
                                      image: FileImage(File(imageFile.path)),
                                    )
                                    : null,
                          ),
                          child: child,
                        );
                      },
                      child:
                          imageFile == null
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Image.asset(
                                        albumIcon,
                                        height: 80.h,
                                        width: 80.h,
                                      ),
                                    ),
                                    6.verticalSpace,
                                    Text(
                                      'Upload group image',
                                      style: getBodySmall(
                                        context: context,
                                        fontweight: FontWeight.w400,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : Stack(
                                alignment: Alignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 100.w,
                                      bottom: 125.h,
                                    ),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        onPressed: () {
                                          imageNotifier.value = null;
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          size: 25.h,
                                          color: darkWhite2,
                                          shadows: [
                                            BoxShadow(
                                              color: blackColor,
                                              blurRadius: 3,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.edit, color: darkWhite2),
                                ],
                              ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
