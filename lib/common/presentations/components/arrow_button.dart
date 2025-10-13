import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArrowButton extends StatelessWidget {
  final Function() onClicked;
  const ArrowButton({required this.onClicked, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return FloatingActionButton.small(
          key: key,
          onPressed: () {
            onClicked();
          },
          backgroundColor: theme.isDark ? greyColor : darkWhite,
          shape: CircleBorder(),
          child: Icon(
            Icons.keyboard_double_arrow_down_rounded,
            color: theme.isDark ? whiteColor : blackColor,
          ),
        );
      },
    );
  }
}
