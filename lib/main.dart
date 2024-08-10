import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customers_info/controllers/registration_controller.dart';
import 'package:flutter_customers_info/pages/search_page.dart';
import 'package:flutter_customers_info/pages/main_page.dart';
import 'package:flutter_customers_info/pages/splash_page.dart';
import 'package:flutter_customers_info/pages/webcam_page.dart';
import 'package:flutter_customers_info/utils/constants.dart';
import 'package:cbl_flutter/cbl_flutter.dart';

Future<void> main() async {
  await CouchbaseLiteFlutter.init();
  runApp(MultiBlocProvider(providers: [
    BlocProvider<RegistrationController>(
        create: (context) => RegistrationController())
  ], child: App()));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        builder: (context, widget) {
          return MultiBlocListener(listeners: [
            BlocListener<RegistrationController, RegistrationStates>(
                listener: (context, state) {}),
          ], child: widget!);
        },
        title: "Customers",
        theme: ThemeData(
            fontFamily: 'Vazir',
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.dark),
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        initialRoute: SPLASH_PAGE,
        routes: {
          SPLASH_PAGE: (context) => SplashPage(),
          MAIN_PAGE: (context) => MainPage(),
          SEARCH_PAGE: (context) => SearchPage(),
          WEBCAM_PAGE: (context) => WebcamPage()
        });
  }
}
