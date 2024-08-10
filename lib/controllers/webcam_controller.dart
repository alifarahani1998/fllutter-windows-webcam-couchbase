// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customers_info/helpers/global.dart';
import 'package:flutter_customers_info/utils/constants.dart';

abstract class WebcamStates {}

class WebcamStatesInitial extends WebcamStates {}

class WebcamStatesLoading extends WebcamStates {}

class WebcamStatesFetchedWithNoDefault extends WebcamStates {}

class WebcamStatesInitiateWithDefault extends WebcamStates {
  final String defaultWebcamID;

  WebcamStatesInitiateWithDefault(this.defaultWebcamID);
}

class WebcamStatesFetchedWithDefault extends WebcamStates {
  final String defaultWebcamID;

  WebcamStatesFetchedWithDefault(this.defaultWebcamID);
}

class WebcamStatesError extends WebcamStates {
  final String error;
  WebcamStatesError({required this.error});
}

class WebcamController extends Cubit<WebcamStates> {
  WebcamController() : super(WebcamStatesInitial()) {
    initiateWebcams();
  }

  Future<void> initiateWebcams() async {
    await Future.delayed(Duration(milliseconds: 100));
    if (Global.shPreferences.containsKey(DEFAULT_WEBCAM_ID))
      emit(WebcamStatesInitiateWithDefault(
          Global.shPreferences.getString(DEFAULT_WEBCAM_ID)!));
    else
      emit(WebcamStatesFetchedWithNoDefault());
  }

  Future<void> getDefaultWebcam() async => emit(WebcamStatesFetchedWithDefault(
      Global.shPreferences.getString(DEFAULT_WEBCAM_ID)!));

  Future<void> changeDefaultWebcam(String defaultWebcamID) async {
    Global.shPreferences.setString(DEFAULT_WEBCAM_ID, defaultWebcamID);
    emit(WebcamStatesFetchedWithDefault(defaultWebcamID));
  }
}
