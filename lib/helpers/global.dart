import 'package:shared_preferences/shared_preferences.dart';

//a typedef to use in class for callback functions
typedef OnValueCallback = void Function(int value);

abstract class Global {

  //ُ/SharedPreferences instance to use globally
  //This instance will initialize in SplashPage func
  static late SharedPreferences shPreferences;

}
