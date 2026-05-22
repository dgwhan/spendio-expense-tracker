import 'package:flutter/material.dart';

/// reusable primary button
class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const PrimaryButton({
    Key? key,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B5FEF),
          foregroundColor: Colors.white,
          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        child: Text(
          title,

          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}