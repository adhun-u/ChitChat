import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:flutter/cupertino.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CupertinoButton(
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) {
                  return const ForgotPasswordPage();
                },
              ),
            );
          },
          sizeStyle: CupertinoButtonSize.small,
          child: Text(
            'Forgot password?',
            style: getTitleSmall(
              context: context,
              color: blueColor,
              fontweight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
