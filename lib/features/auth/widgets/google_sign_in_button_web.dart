import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({required this.onPressed, super.key});

  // Google Identity Services owns the interaction on web.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue with Google',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonWidth = constraints.maxWidth.clamp(1.0, 400.0);
          return SizedBox(
            width: double.infinity,
            height: 54,
            child: Center(
              child: renderButton(
                configuration: GSIButtonConfiguration(
                  type: GSIButtonType.standard,
                  theme: GSIButtonTheme.outline,
                  size: GSIButtonSize.large,
                  text: GSIButtonText.continueWith,
                  shape: GSIButtonShape.rectangular,
                  logoAlignment: GSIButtonLogoAlignment.left,
                  minimumWidth: buttonWidth,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
