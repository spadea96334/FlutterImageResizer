import 'package:flutter/material.dart';

class TooltipButton extends StatelessWidget {
  const TooltipButton({super.key, this.onPressed, required this.icon, required this.message});

  final Function()? onPressed;
  final Icon icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: message,
        child: IconButton(
            onPressed: onPressed,
            icon: icon,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent));
  }
}
