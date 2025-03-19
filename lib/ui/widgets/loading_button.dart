import 'package:flutter/material.dart';



class LoadingButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const LoadingButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.onPressed,
    required this.isLoading,
  });

  @override
Widget build(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
    ),
  );
}
}