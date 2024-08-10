import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_customers_info/utils/constants.dart';
import 'package:flutter_customers_info/widgets/main_button.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: lightOrange.withOpacity(0.8),
        body: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(
              horizontal: screenWidth / 5, vertical: screenHeight / 5),
          decoration: BoxDecoration(
              color: lightOrange, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(50.0),
                  decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      )),
                  alignment: Alignment.center,
                  child: Image.asset(robotImage),
                ),
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'آرسام روباتیک',
                    style: TextStyle(
                        color: whiteColor,
                        fontFamily: 'Vazir-Bold',
                        fontSize: 50),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  MainButton(isWaiting: false, onPressed: () => Navigator.pushReplacementNamed(context, MAIN_PAGE), text: 'ورود', color: whiteColor, textColor: lightOrange,)
                ],
              )),
            ],
          ),
        ));
  }
}
