import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/device_size.dart';
import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ChatSettings extends StatelessWidget {
  const ChatSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: Text(
          'Chat Settings',
          style: getTitleMedium(
            context: context,
            fontweight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: greyColor,
                  child: Icon(Icons.dark_mode, color: whiteColor),
                ),
                title: Text(
                  'Dark theme',
                  style: getTitleMedium(
                    context: context,
                    fontweight: FontWeight.bold,
                  ),
                ),
                trailing: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return CupertinoSwitch(
                      activeTrackColor: blueColor,
                      value: themeProvider.isDark,
                      onChanged: (isDark) {
                        context.read<ThemeProvider>().changeTheme(isDark);
                      },
                    );
                  },
                ),
              ),
            ),
            18.verticalSpace,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 150.h,
                  width: double.infinity.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ChatBubbles(
                        alignment: Alignment.topRight,
                        textColor: whiteColor,
                      ),
                      10.verticalSpace,
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            return _ChatBubbles(
                              alignment: Alignment.bottomLeft,
                              color:
                                  themeProvider.isDark
                                      ? greyColor
                                      : darkWhite,
                              textColor:
                                  themeProvider.isDark
                                      ? darkWhite
                                      : greyColor,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: SizedBox(
                    height: 170.h,
                    width: double.infinity.w,
    
                    child: Consumer<ChatStyleProvider>(
                      builder: (context, chatStyle, _) {
                        return Padding(
                          padding: EdgeInsets.only(left: 15.w, right: 15.w),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: chatStyle.colors.length,
                            itemBuilder: (context, index) {
                              final Color color = chatStyle.colors[index];
                              return _ColorChatContainer(
                                color: color,
                                isSelected:
                                    chatStyle.chatColor.toARGB32() ==
                                    color.toARGB32(),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(width: 3.w);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                40.verticalSpace,
                Consumer<ChatStyleProvider>(
                  builder: (context, chatStyle, _) {
                    return _CustomSliders(
                      title: "Border radius",
                      maxValue: 15,
                      changingValue: chatStyle.borderRadius,
                      onDragging: (borderRadius) {
                        context.read<ChatStyleProvider>().changeBorderRadius(
                          borderRadius,
                        );
                      },
                    );
                  },
                ),
                Consumer<ChatStyleProvider>(
                  builder: (context, chatStyle, _) {
                    return _CustomSliders(
                      title: "Font size",
                      maxValue: 20,
                      minValue: 13,
                      changingValue: chatStyle.fontSize,
                      onDragging: (fontSize) {
                        context.read<ChatStyleProvider>().changeFontSize(
                          fontSize,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//-------------------------------------------------------------------

class _ColorChatContainer extends StatelessWidget {
  final bool isSelected;
  final Color color;
  const _ColorChatContainer({required this.color, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return GestureDetector(
          onTap: () {
            //Changing the chat color
            context.read<ChatStyleProvider>().changeColor(color.toARGB32());
          },
          child: Container(
            height: 140.h,
            width: 110.w,
            decoration: BoxDecoration(
              border: isSelected ? Border.all(color: color, width: 2) : null,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: EdgeInsets.all(5.w),
              child: Container(
                height: 128.h,
                width: 110.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: themeProvider.isDark ? greyColor : darkWhite2,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10.h,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: Container(
                            height: 25.h,
                            width: 60.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.w),
                          child: Consumer<ThemeProvider>(
                            builder: (context, themeProvider, _) {
                              return Container(
                                height: 25.h,
                                width: 60.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  color:
                                      themeProvider.isDark
                                          ? darkGrey
                                          : darkWhite,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: Container(
                            height: 25.h,
                            width: 60.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                              color: color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChatBubbles extends StatelessWidget {
  final Alignment alignment;
  final Color? color;
  final Color? textColor;
  const _ChatBubbles({
    required this.alignment,
    required this.textColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.only(right: 20.w),
        child: Consumer<ChatStyleProvider>(
          builder: (context, chatStyleProvider, _) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: context.height() * 0.03,
                minWidth: context.width() * 0.025,
                maxWidth: context.width() * 0.5,
              ),
              child: IntrinsicHeight(
                child: IntrinsicWidth(
                  stepWidth: 30.w,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          chatStyleProvider.borderRadius,
                        ),
                        topRight: Radius.circular(
                          chatStyleProvider.borderRadius,
                        ),
                        bottomLeft:
                            alignment == Alignment.topRight
                                ? Radius.circular(
                                  chatStyleProvider.borderRadius,
                                )
                                : Radius.circular(0),
                        bottomRight:
                            alignment == Alignment.bottomLeft
                                ? Radius.circular(
                                  chatStyleProvider.borderRadius,
                                )
                                : Radius.circular(0),
                      ),
                      color: color ?? chatStyleProvider.chatColor,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 10.h,
                      ),
                      child: Consumer<ChatStyleProvider>(
                        builder: (context, chatStyleProvider, _) {
                          return Text(
                            'This is a message',
                            style: getTitleMedium(
                              context: context,
                              fontweight: FontWeight.bold,
                              color: textColor,
                              fontSize: chatStyleProvider.fontSize.sp,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CustomSliders extends StatelessWidget {
  final String title;
  final double maxValue;
  final double changingValue;
  final double? minValue;
  final Function(double value) onDragging;
  const _CustomSliders({
    required this.title,
    required this.maxValue,
    required this.changingValue,
    required this.onDragging,
    this.minValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: getTitleMedium(
                context: context,
                fontweight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 14.w),
              child: SizedBox(
                width: 380.w,
                child: CupertinoSlider(
                  value: changingValue,
                  min: minValue ?? 0,
                  max: maxValue,
                  thumbColor: darkWhite,
                  activeColor: blueColor,
                  onChanged: (value) {
                    onDragging(value);
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10.w, left: 10.w),
              child: Consumer<ChatStyleProvider>(
                builder: (context, chatStyle, _) {
                  return Text(
                    changingValue.toInt().toString(),
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
