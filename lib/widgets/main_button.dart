import 'package:flutter/material.dart';
import 'package:flutter_customers_info/utils/constants.dart';

class MainButton extends StatelessWidget {
  final String text;
  final bool isWaiting;
  final Function onPressed;
  final Color color;
  final Color textColor;

  MainButton({
    required this.isWaiting,
    required this.onPressed,
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => !isWaiting ? onPressed() : null,
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 100),
            alignment: Alignment.center,
            height: 56,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: color),
            child: isWaiting
                ? CircularProgressIndicator(
                    color: lightOrange,
                  )
                : Text(
                    text,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  )));
  }
}
