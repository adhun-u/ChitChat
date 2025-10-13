import 'dart:io';
import 'package:chitchat/common/data/models/current_user_model.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/icons.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/common/presentations/components/app_text_field.dart';
import 'package:chitchat/common/presentations/components/image_picker_sheet.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();

  TextEditingController bioController = TextEditingController();

  final ValueNotifier<XFile?> imageFileNotifier = ValueNotifier<XFile?>(null);

  @override
  void dispose() {
    imageFileNotifier.dispose();
    nameController.dispose();
    bioController.dispose();
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
          'Edit profile',
          style: getTitleMedium(context: context, fontweight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Consumer<CurrentUserProvider>(
          builder: (context, currentUserProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30.h),
                Center(
                  child: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: blueColor, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Opacity(
                            opacity: 0.9,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              onTap: () {},
                              child: ValueListenableBuilder(
                                valueListenable: imageFileNotifier,
                                builder: (context, file, _) {
                                  return file == null
                                      ? GestureDetector(
                                        onTap: () {
                                          showBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return ImagePickerSheet(
                                                onCameraClick: (image) async {
                                                  imageFileNotifier.value =
                                                      image;
                                                },
                                                onGalleryClick: (image) async {
                                                  imageFileNotifier.value =
                                                      image;
                                                },
                                              );
                                            },
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: 60.r,
                                          backgroundColor:
                                              themeProvider.isDark
                                                  ? greyColor
                                                  : darkWhite2,
                                          backgroundImage:
                                              currentUserProvider
                                                      .currentUser
                                                      .profilePic
                                                      .isNotEmpty
                                                  ? NetworkImage(
                                                    currentUserProvider
                                                        .currentUser
                                                        .profilePic,
                                                  )
                                                  : AssetImage(profileIcon),
                                          child: Center(
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: whiteColor,
                                            ),
                                          ),
                                        ),
                                      )
                                      : GestureDetector(
                                        onTap: () {
                                          showBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return ImagePickerSheet(
                                                onCameraClick: (image) async {
                                                  imageFileNotifier.value =
                                                      image;
                                                },
                                                onGalleryClick: (image) async {
                                                  imageFileNotifier.value =
                                                      image;
                                                },
                                              );
                                            },
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: 60.r,
                                          backgroundColor:
                                              themeProvider.isDark
                                                  ? greyColor
                                                  : darkWhite2,
                                          backgroundImage: FileImage(
                                            File(file.path),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: whiteColor,
                                            ),
                                          ),
                                        ),
                                      );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 55.h),
                Padding(
                  padding: EdgeInsets.only(left: 28.w, right: 28.w),
                  child: AppTextField(
                    controller: nameController,
                    prefix: Icon(Icons.person),
                    suffix: null,
                    obscureText: false,
                    hintText: "Enter your new name",
                    maxLength: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 28.w, right: 28.w),
                  child: AppTextField(
                    controller: bioController,
                    prefix: Icon(Icons.edit),
                    suffix: null,
                    obscureText: false,
                    hintText: 'New bio',
                    maxLength: 50,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 60.h,
                  width: 380.w,
                  child: Selector<CurrentUserProvider, bool>(
                    selector: (_, currentUserProv) {
                      return currentUserProv.updateDetailsLoading;
                    },
                    builder: (context, isLoading, _) {
                      return CupertinoButton(
                        onPressed: () async {
                          final String name = nameController.text.trim();
                          final String bio = bioController.text.trim();
                          if (isLoading) {
                            return;
                          }
                          if (imageFileNotifier.value != null ||
                              name.isNotEmpty ||
                              bio.isNotEmpty) {
                            dartz.Either<
                              UpdatedUserDetailsModel,
                              ErrorMessageModel
                            >
                            result = await context
                                .read<CurrentUserProvider>()
                                .updateUserDetails(
                                  newBio:
                                      bio != currentUserProvider.currentUser.bio
                                          ? bio
                                          : "",
                                  imagePath:
                                      imageFileNotifier.value != null
                                          ? imageFileNotifier.value!.path
                                          : "",
                                  newName:
                                      name !=
                                              currentUserProvider
                                                  .currentUser
                                                  .username
                                          ? name
                                          : "",
                                );

                            //Checking whether the result returns success state or error state
                            result.fold(
                              //Success
                              (_) {
                                showSuccessMessage(
                                  context,
                                  "Updated successfully",
                                );
                                Navigator.of(context).pop();
                              },
                              //Error
                              (_) {
                                showErrorMessage(
                                  context,
                                  "Something went wrong",
                                );
                              },
                            );
                          }
                        },
                        sizeStyle: CupertinoButtonSize.large,
                        color: blueColor,
                        borderRadius: BorderRadius.circular(50),
                        child:
                            isLoading
                                ? SizedBox(
                                  height: 35.h,
                                  width: 25.w,
                                  child: const LoadingIndicator(
                                    color: whiteColor,
                                  ),
                                )
                                : Text(
                                  'Save changes',
                                  style: getTitleMedium(
                                    context: context,
                                    fontweight: FontWeight.bold,
                                    color: whiteColor,
                                    fontSize: 15.sp,
                                  ),
                                ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
