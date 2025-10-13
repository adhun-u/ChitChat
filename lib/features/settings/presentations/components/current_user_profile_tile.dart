import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/icons.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/device_size.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrentUserProfileTile extends StatelessWidget {
  final String currentUserProfilePic;
  final String currentUsername;
  final String currentUserbio;
  const CurrentUserProfileTile({
    super.key,
    required this.currentUserProfilePic,
    required this.currentUserbio,
    required this.currentUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            height: context.height() * 0.08,
            width: context.height() * 0.08,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: blueColor, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child:
                  currentUserProfilePic.isNotEmpty
                      ? Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) {
                          return CircleAvatar(
                            radius: context.height() * 0.04,
                            backgroundImage: NetworkImage(
                              currentUserProfilePic,
                            ),
                            backgroundColor:
                                themeProvider.isDark ? greyColor : darkWhite2,
                          );
                        },
                      )
                      : Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) {
                          return CircleAvatar(
                            radius: context.height() * 0.04,
                            backgroundImage: AssetImage(profileIcon),
                            backgroundColor:
                                themeProvider.isDark ? greyColor : darkWhite2,
                          );
                        },
                      ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.width() * 0.45),
                child: Text(
                  currentUsername,
                  style: getTitleMedium(
                    context: context,
                    fontweight: FontWeight.bold,
                  ),
                ),
              ),
              currentUserbio.isNotEmpty
                  ? ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: context.height() * 0.044,
                      maxWidth: context.width() * 0.5,
                    ),
                    child: Text(
                      currentUserbio,
                      style: getTitleSmall(
                        context: context,
                        fontweight: FontWeight.w500,
                      ),
                    ),
                  )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }
}
