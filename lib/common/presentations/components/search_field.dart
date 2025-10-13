import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:provider/provider.dart';

class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String text) onChanged;
  final Function() onClearButtonClicked;
  final String hintText;
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClearButtonClicked,
    required this.hintText,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final Debouncer _debouncer = Debouncer();

  //For calling when user releases finger from keyboard
  void debounceTyping(String text) {
    _debouncer.debounce(
      duration: const Duration(milliseconds: 300),
      onDebounce: () {
        widget.onChanged(text);
      },
    );
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(primaryColor: blueColor),

      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return CupertinoTextField.borderless(
            placeholder: widget.hintText,
            controller: widget.controller,
            placeholderStyle: getTitleMedium(
              context: context,
              fontweight: FontWeight.w400,
              color: theme.isDark ? darkWhite2 : lightGrey,
            ),
            style: getTitleMedium(
              context: context,
              fontweight: FontWeight.w400,
              color: theme.isDark ? whiteColor : blackColor,
            ),
            prefix: Icon(
              Icons.search,
              color: theme.isDark ? lightGrey : greyColor,
            ),
            suffix: IconButton(
              onPressed: () {
                widget.onClearButtonClicked();
              },
              icon: Icon(Icons.close),
              color: theme.isDark ? lightGrey : greyColor,
            ),
            onChanged: (text) {
              if (text.trim().isNotEmpty) {
                debounceTyping(text);
              }
            },
            cursorColor: blueColor,
          );
        },
      ),
    );
  }
}
