import 'package:chitchat/common/application/permissions.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class AttachContainer extends StatelessWidget {
  final List<IconData> icons;
  final List<Color> colors;
  final List<String> labels;
  final Function(XFile) whenImageClicked;
  final Function(PlatformFile) whenAudioClicked;
  const AttachContainer({
    super.key,
    required this.icons,
    required this.colors,
    required this.labels,
    required this.whenImageClicked,
    required this.whenAudioClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return Container(
          height: 100.h,
          width: 420.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: theme.isDark ? greyColor : darkWhite,
          ),
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(icons.length, (index) {
                final IconData icon = icons[index];
                final Color color = colors[index];
                final String label = labels[index];
                return InkWell(
                  onTap: () async {
                    //CAMERA
                    if (label == "Camera") {
                      //Taking image using camera
                      final bool isGranted = await askCameraPermission();
                      final XFile? cameraImage = await _pickImage(
                        isPermissionGranted: isGranted,
                        isCamera: true,
                      );
                      if (cameraImage != null) {
                        whenImageClicked(cameraImage);
                      }
                      //GALLERY
                    } else if (label == "Gallery") {
                      //Asking permission for accessing storage
                      final bool isGranted = await askStoragePermission();
                      //Picking image from gallery
                      final XFile? galleryImage = await _pickImage(
                        isPermissionGranted: isGranted,
                        isCamera: false,
                      );
                      if (galleryImage != null) {
                        whenImageClicked(galleryImage);
                      }
                      //AUDIO
                    } else if (label == "Audio") {
                      //Asking permission for accessing storage
                      final bool isGranted = await askStoragePermission();
                      if (isGranted) {
                        //If permission is granted , then picking single audio file
                        final FilePickerResult? audio = await FilePicker
                            .platform
                            .pickFiles(
                              allowMultiple: false,
                              type: FileType.audio,
                            );
                        if (audio != null && audio.files.single.path != null) {
                          whenAudioClicked(audio.files.single);
                        }
                      }
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: color,
                        radius: 25.r,
                        child: Icon(icon, color: whiteColor),
                      ),
                      5.verticalSpace,
                      Text(
                        label,
                        style: getBodySmall(
                          context: context,
                          fontweight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

//For picking image using camera or getting from gallery
Future<XFile?> _pickImage({
  required bool isPermissionGranted,
  required bool isCamera,
}) async {
  if (isPermissionGranted) {
    final XFile? tookImage = await ImagePicker().pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );
    return tookImage;
  }
  return null;
}
