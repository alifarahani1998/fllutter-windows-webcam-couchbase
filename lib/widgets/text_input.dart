import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_customers_info/utils/constants.dart';

class TextInput extends StatelessWidget {
  final String hintText;
  final TextEditingController textEditingController;
  final TextInputType textInputType;

  const TextInput(
      {required this.hintText,
      required this.textEditingController,
      this.textInputType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: EdgeInsets.symmetric(horizontal: 100, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: whiteColor, borderRadius: BorderRadius.circular(16)),
      child: TextField(
        keyboardType: textInputType,
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w300, color: lightOrange),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        controller: textEditingController,
        decoration: new InputDecoration.collapsed(
            hintText: hintText,
            hintStyle: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: lightOrange)),
      ),
    );
  }
}
