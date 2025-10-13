import 'dart:io';

import 'package:chitchat/common/presentations/components/app_text_field.dart';
import 'package:chitchat/common/presentations/components/image_picker_sheet.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class EditGroupPage extends StatefulWidget {
  final String groupId;
  final String groupImageUrl;
  final String groupBio;
  final String groupName;
  const EditGroupPage({
    super.key,
    required this.groupId,
    required this.groupImageUrl,
    required this.groupBio,
    required this.groupName,
  });

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.groupName,
  );
  late final TextEditingController _bioController = TextEditingController(
    text: widget.groupBio,
  );
  late final ValueNotifier<XFile?> _imageNotifier = ValueNotifier(null);

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _imageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Edit group info',
          style: getTitleMedium(context: context, fontweight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            40.verticalSpace,
            BlocListener<GroupBloc, GroupState>(
              listenWhen: (_, current) {
                return current is EditGroupErrorState ||
                    current is EditGroupSuccessState ||
                    current is EditGroupLoadingState;
              },
              listener: (context, groupState) {
                if (groupState is EditGroupErrorState) {
                  showErrorMessage(context, groupState.message);
                }
                if (groupState is EditGroupSuccessState) {
                  showSuccessMessage(context, groupState.message);
                  Navigator.of(context).pop();
                }
              },
              child: const SizedBox(),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Group Photo',
                style: getTitleLarge(
                  context: context,
                  fontweight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
            10.verticalSpace,
            SizedBox(
              height: 140.h,
              width: 150.h,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ValueListenableBuilder(
                    valueListenable: _imageNotifier,
                    builder: (context, image, child) {
                      return Container(
                        height: 140.h,
                        width: 140.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          image:
                              image == null
                                  ? widget.groupImageUrl.isNotEmpty
                                      ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          widget.groupImageUrl,
                                        ),
                                      )
                                      : null
                                  : DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(File(image.path)),
                                  ),
                        ),
                        child:
                            widget.groupImageUrl.isEmpty
                                ? Icon(Icons.group, size: 35.h)
                                : null,
                      );
                    },
                  ),
                  Builder(
                    builder: (innerContext) {
                      return GestureDetector(
                        onTap: () {
                          showBottomSheet(
                            context: innerContext,
                            builder: (context) {
                              return ImagePickerSheet(
                                onCameraClick: (image) {
                                  _imageNotifier.value = image;
                                },
                                onGalleryClick: (image) {
                                  _imageNotifier.value = image;
                                },
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 25.r,
                          backgroundColor: blueColor,
                          child: const Icon(
                            Icons.camera_alt,
                            color: whiteColor,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            10.verticalSpace,
            Text(
              'Tap the camera icon to change your group photo',
              style: getBodySmall(
                context: context,
                fontweight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
            20.verticalSpace,
            Padding(
              padding: EdgeInsets.only(left: 40.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Group Name',
                  style: getTitleLarge(
                    context: context,
                    fontweight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
            10.verticalSpace,
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: AppTextField(
                controller: _nameController,
                prefix: const Icon(Icons.group),
                hintText: "Enter new group name",
                maxLength: 30,
                obscureText: false,
                suffix: null,
              ),
            ),
            20.verticalSpace,
            Padding(
              padding: EdgeInsets.only(left: 40.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Group Bio',
                  style: getTitleLarge(
                    context: context,
                    fontweight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
            10.verticalSpace,
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: AppTextField(
                controller: _bioController,
                prefix: const Icon(Icons.info),
                hintText: "Enter new group bio",
                maxLength: 200,
                maxLines: 3,
                obscureText: false,
                suffix: null,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.h, left: 40.w, right: 40.w),
              child: Text(
                'Write a brief description about your group to help members to understand its purpose',
                style: getBodySmall(
                  context: context,
                  fontweight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
            30.verticalSpace,
            SizedBox(
              height: 60.h,
              width: 390.w,
              child: BlocBuilder<GroupBloc, GroupState>(
                builder: (context, groupState) {
                  return CupertinoButton(
                    onPressed: () {
                      if (groupState is EditGroupLoadingState) {
                        return;
                      }

                      final String groupName = _nameController.text.trim();
                      final String groupBio = _bioController.text.trim();

                      if (groupBio.isEmpty &&
                          groupName.isEmpty &&
                          _imageNotifier.value == null) {
                        return;
                      }

                      //Calling bloc to change image , name or bio
                      context.read<GroupBloc>().add(
                        EditGroupInfoEvent(
                          groupId: widget.groupId,
                          newGroupName: groupName,
                          newGroupImagePath:
                              _imageNotifier.value != null
                                  ? _imageNotifier.value!.path
                                  : "",
                          newGroupBio: groupBio,
                        ),
                      );
                    },
                    color: blueColor,
                    borderRadius: BorderRadius.circular(30),
                    child:
                        groupState is EditGroupLoadingState
                            ? SizedBox(
                              height: 50.h,
                              width: 25.h,
                              child: const CircularProgressIndicator(
                                color: whiteColor,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'SAVE CHANGES',
                              style: getTitleSmall(
                                context: context,
                                fontweight: FontWeight.bold,
                                color: whiteColor,
                                fontSize: 14.sp,
                              ),
                            ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
