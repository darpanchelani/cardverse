import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFF8FAF9),
          foregroundColor: const Color(0xFF1F1F1F),
          disabledBackgroundColor: const Color(0xFFB9C0BC),
          disabledForegroundColor: const Color(0xFF5F6368),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontSize: 21,
                fontWeight: FontWeight.w800,
                fontFamily: 'Arial',
              ),
            ),
            SizedBox(width: 12),
            Text('Continue with Google'),
          ],
        ),
      ),
    );
  }
}
