import 'package:chitchat/common/application/permissions.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ImagePickerSheet extends StatelessWidget {
  final Function(XFile image) onGalleryClick;
  final Function(XFile image) onCameraClick;
  const ImagePickerSheet({
    super.key,
    required this.onCameraClick,
    required this.onGalleryClick,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          height: 300.h,
          width: double.infinity.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: darkGrey,
                blurRadius: 3,
                spreadRadius: 0.3,
                offset: Offset(-1, 0),
              ),
            ],
            color: themeProvider.isDark ? blackColor : whiteColor,
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Container(
                  height: 5.h,
                  width: 43.w,
                  decoration: BoxDecoration(
                    color: themeProvider.isDark ? darkWhite2 : greyColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 15.h),
          Text(
            'Select image source',
            style: getTitleMedium(
              context: context,
              fontweight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15.h),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    //Asking the camera permission
                    final bool isGranted = await askCameraPermission();

                    if (isGranted) {
                      try {
                        final XFile? imageFile = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                        );
                        if (imageFile != null) {
                          onCameraClick(imageFile);
                        }
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: _SheetTile(
                    prefixIcon: Icon(
                      Icons.camera_alt,
                      color: Colors.green,
                      size: 35.h,
                    ),
                    subTitle: "Take a picture",
                    title: "Camera",
                  ),
                ),
                SizedBox(height: 5.h),
                GestureDetector(
                  onTap: () async {
                    //Asking the storage permission
                    final bool isGranted = await askStoragePermission();

                    //If the permission is granted , then picking image
                    if (isGranted) {
                      try {
                        final XFile? imageFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (imageFile != null) {
                          onGalleryClick(imageFile);
                        }
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: _SheetTile(
                    prefixIcon: Icon(
                      Icons.photo,
                      color: Colors.blue,
                      size: 35.h,
                    ),
                    subTitle: "Choose from storage",
                    title: "Gallery",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget prefixIcon;

  const _SheetTile({
    required this.prefixIcon,
    required this.subTitle,
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Card(
            color: themeProvider.isDark ? greyColor : whiteColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: SizedBox(
                height: 80.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: prefixIcon,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: getTitleMedium(
                                context: context,
                                fontweight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              subTitle,
                              style: getTitleSmall(
                                context: context,
                                fontweight: FontWeight.w400,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
