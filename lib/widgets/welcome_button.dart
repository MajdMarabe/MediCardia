import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  final String buttonText;
  final Widget onTap;
  final Color color;
  final Color textColor;
  final Color? borderColor; // Optional parameter for border color
  final double? borderWidth; // Optional parameter for border width
  final double width; // Added width parameter for consistent button size

  const WelcomeButton({
    required this.buttonText,
    required this.onTap,
    required this.color,
    required this.textColor,
    this.borderColor,
    this.borderWidth,
    this.width = double.infinity, // Default width is full width
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // Apply the fixed width
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => onTap),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0), // Rounded corners
            side: borderColor != null && borderWidth != null
                ? BorderSide(
                    color: borderColor!,
                    width: borderWidth!,
                  )
                : BorderSide.none, // No border if not specified
          ),
          padding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            color: textColor,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
