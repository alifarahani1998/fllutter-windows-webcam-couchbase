import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customers_info/controllers/registration_controller.dart';
import 'package:flutter_customers_info/utils/constants.dart';
import 'package:flutter_customers_info/widgets/main_button.dart';
import 'package:flutter_customers_info/widgets/text_input.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController nationalCodeController = new TextEditingController();
  String? imageUri;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<RegistrationController, RegistrationStates>(
      // bloc was provided in main.dart, only needs to consume it
      listener: (context, state) {
        if (state is RegistrationStatesRegistered) {
          // new user is registered, shows success alarm and clears inputs
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            flushbarStyle: FlushbarStyle.FLOATING,
            reverseAnimationCurve: Curves.decelerate,
            forwardAnimationCurve: Curves.elasticOut,
            duration: Duration(seconds: 3),
            backgroundGradient:
                LinearGradient(colors: [Colors.blueGrey, Colors.black]),
            progressIndicatorBackgroundColor: Colors.blueGrey,
            messageText: Text(
              "کاربر با موفقیت افزوده شد",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.amber,
              ),
            ),
          ).show(context);
          firstNameController.clear();
          lastNameController.clear();
          nationalCodeController.clear();
          imageUri = null;
        } else if (state is RegistrationStatesError)
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            flushbarStyle: FlushbarStyle.FLOATING,
            reverseAnimationCurve: Curves.decelerate,
            forwardAnimationCurve: Curves.elasticOut,
            duration: Duration(seconds: 3),
            backgroundGradient:
                LinearGradient(colors: [Colors.blueGrey, Colors.black]),
            progressIndicatorBackgroundColor: Colors.blueGrey,
            messageText: Text(
              state.error,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.amber,
              ),
            ),
          ).show(context);
      },
      builder: (context, state) {
        return Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'ورود اطلاعات کاربر',
                style: TextStyle(fontSize: 30, color: lightOrange),
              ),
            ),
            body: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: screenWidth / 3, vertical: screenHeight / 15),
                decoration: BoxDecoration(
                    color: lightOrange,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextInput(
                            hintText: 'نام',
                            textEditingController: firstNameController),
                        TextInput(
                            hintText: 'نام خانوادگی',
                            textEditingController: lastNameController),
                        TextInput(
                          hintText: 'کد ملی',
                          textEditingController: nationalCodeController,
                          textInputType: TextInputType.number,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, WEBCAM_PAGE)
                              .then((value) {
                            if (value != null) imageUri = (value as String);
                          }),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(20)),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: lightOrange,
                            ),
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        MainButton(
                          isWaiting: state
                              is RegistrationStatesLoading, // progress indicator when saving in DB
                          onPressed: () {
                            if (firstNameController.text.isNotEmpty &&
                                lastNameController.text.isNotEmpty &&
                                nationalCodeController.text.isNotEmpty &&
                                imageUri != null)
                              context
                                  .read<RegistrationController>()
                                  .registerCustomerInfo(
                                      firstNameController.text,
                                      lastNameController.text,
                                      nationalCodeController.text,
                                      imageUri!);
                          },
                          text: strAddUser,
                          color: whiteColor,
                          textColor: lightOrange,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        MainButton(
                          // Go to search page, independent of the last part
                          isWaiting: false,
                          onPressed: () =>
                              Navigator.pushNamed(context, SEARCH_PAGE)
                                  .then((value) {
                            firstNameController.clear();
                            lastNameController.clear();
                            nationalCodeController.clear();
                            imageUri = null;
                          }),
                          text: 'جست و جوی کاربران',
                          color: whiteColor,
                          textColor: lightOrange,
                        ),
                      ],
                    )
                  ],
                )));
      },
    );
  }
}
