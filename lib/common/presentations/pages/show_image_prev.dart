import 'dart:io';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShowImagePrev extends StatelessWidget {
  final String username;
  final String imagePath;
  final String sentImageTime;
  final String heroTag;
  const ShowImagePrev({
    super.key,
    required this.imagePath,
    required this.username,
    required this.sentImageTime,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: double.infinity.h,
        width: double.infinity.w,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (username.isNotEmpty)
                  Text(
                    username,
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.bold,
                    ),
                  ),
                Text(
                  sentImageTime,
                  style: getTitleSmall(
                    context: context,
                    fontweight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            titleSpacing: 0,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InteractiveViewer(
                child: Center(
                  child: Hero(
                    tag: heroTag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 800.h),
                      child: Image.file(File(imagePath), fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
