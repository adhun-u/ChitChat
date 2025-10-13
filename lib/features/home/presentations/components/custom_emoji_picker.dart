import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomEmojiPicker extends StatelessWidget {
  final TextEditingController controller;
  final ValueNotifier<String> notifier;
  final Function() onEmojiChanged;
  const CustomEmojiPicker({
    super.key,
    required this.controller,
    required this.notifier,
    required this.onEmojiChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return EmojiPicker(
          onEmojiSelected: (category, emoji) {
            controller.text += emoji.emoji;
            notifier.value += emoji.emoji;
            onEmojiChanged();
          },
          onBackspacePressed: () {
            controller.text = controller.text.characters.skipLast(1).toString();
            notifier.value = notifier.value.characters.skipLast(1).toString();
            onEmojiChanged();
          },

          config: Config(
            checkPlatformCompatibility: true,
            categoryViewConfig: CategoryViewConfig(
              backgroundColor: theme.isDark ? greyColor : darkWhite,
              dividerColor: Colors.transparent,
              
            ),

            emojiViewConfig: EmojiViewConfig(
              backgroundColor: theme.isDark ? greyColor : darkWhite,
              
            ),
            bottomActionBarConfig: BottomActionBarConfig(
              backgroundColor: theme.isDark ? greyColor : darkWhite,
              buttonColor: Colors.transparent,
              buttonIconColor: theme.isDark ? whiteColor : blackColor,
            ),
          ),
        );
      },
    );
  }
}
