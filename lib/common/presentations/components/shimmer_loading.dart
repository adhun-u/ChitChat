import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/utils/device_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  const ShimmerLoading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.height() * 0.77,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Shimmer.fromColors(
            baseColor: themeProvider.isDark ? greyColor : darkWhite2,
            highlightColor:
                themeProvider.isDark
                    ? const Color.fromARGB(255, 42, 42, 42)
                    : const Color.fromARGB(255, 178, 178, 178),
            child: child ?? const SizedBox(),
          );
        },
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, _) {
            return Padding(padding: EdgeInsets.only(top: 10.h), child: child);
          },
        ),
      ),
    );
  }
}
