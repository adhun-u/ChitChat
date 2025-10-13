import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomRefreshIndicator extends StatelessWidget {
  final Function onRefresh;
  final Widget child;
  const CustomRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return RefreshIndicator(
          onRefresh: () async {
            onRefresh();
          },
          color: blueColor,
          backgroundColor: theme.isDark ? greyColor : darkWhite,
          child: child,
        );
      },
    );
  }
}
