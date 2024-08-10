// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customers_info/controllers/webcam_controller.dart';
import 'package:flutter_customers_info/helpers/global.dart';
import 'package:flutter_customers_info/utils/constants.dart';
import 'package:flutter_customers_info/widgets/dialogs.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:screenshot/screenshot.dart';

class WebcamPage extends StatefulWidget {
  const WebcamPage({super.key});

  @override
  State<WebcamPage> createState() => _WebcamPageState();
}

class _WebcamPageState extends State<WebcamPage> {
  String _cameraInfo = '';
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  int _cameraId = -1;
  bool _initialized = false;
  Size? _previewSize;
  StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;
  StreamSubscription<CameraClosingEvent>? _cameraClosingStreamSubscription;
  ScreenshotController screenshotController = new ScreenshotController();
  Uint8List? _imageFile;
  final PathProviderWindows provider = PathProviderWindows();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _fetchCameras();
  }

  @override
  void dispose() {
    _disposeCurrentCamera();
    _errorStreamSubscription?.cancel();
    _errorStreamSubscription = null;
    _cameraClosingStreamSubscription?.cancel();
    _cameraClosingStreamSubscription = null;
    super.dispose();
  }

  Future<void> _fetchCameras() async {
    String cameraInfo;
    List<CameraDescription> cameras = <CameraDescription>[];

    int cameraIndex = 0;
    try {
      cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty)
        cameraInfo = 'وب کم یافت نشد';
      else {
        if (Global.shPreferences.containsKey(DEFAULT_WEBCAM_ID)) {
          if (!cameras.any((element) =>
              element.name.split('<')[1] ==
              Global.shPreferences.getString(DEFAULT_WEBCAM_ID)))
            await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => WebcamSelectionDialog(
                      title:
                          'وب کم پیش فرض متصل نیست.\nوب کم دیگری را انتخاب نمایید:',
                      webcamIDs: cameras.map((e) => e.name).toList(),
                    )).then((value) async {
              Global.shPreferences.setString(DEFAULT_WEBCAM_ID, value);
              _initiateDefaultWebcam(value);
            });
        }
        cameraIndex = _cameraIndex % cameras.length;
      }
      cameraInfo = 'وب کم یافت شد: ${cameras[cameraIndex].name}';
    } on PlatformException catch (e) {
      debugPrint('هیچ وب کمی یافت نشد: ${e.code}: ${e.message}');
      cameraInfo = 'هیچ وب کمی یافت نشد: ${e.code}: ${e.message}';
    }

    if (mounted) {
      setState(() {
        _cameraIndex = cameraIndex;
        _cameras = cameras;
        _cameraInfo = cameraInfo;
      });
    }
  }

  Future<void> _initializeCamera() async {
    if (_cameras.isEmpty) return;

    int cameraId = -1;
    try {
      final int cameraIndex = _cameraIndex % _cameras.length;
      final CameraDescription camera = _cameras[cameraIndex];

      cameraId = await CameraPlatform.instance.createCamera(
        camera,
        ResolutionPreset.max,
      );

      unawaited(_errorStreamSubscription?.cancel());
      _errorStreamSubscription = CameraPlatform.instance
          .onCameraError(cameraId)
          .listen(_onCameraError);

      unawaited(_cameraClosingStreamSubscription?.cancel());
      _cameraClosingStreamSubscription = CameraPlatform.instance
          .onCameraClosing(cameraId)
          .listen(_onCameraClosing);

      await CameraPlatform.instance.initializeCamera(
        cameraId,
      );

      _previewSize = const Size(
        400,
        472,
      );

      if (mounted) {
        setState(() {
          _cameraId = cameraId;
          _cameraIndex = cameraIndex;
          _cameraInfo = 'وب کم یافت شده: ${camera.name}';
        });
      }
    } on CameraException catch (e) {
      debugPrint(
          'ناتوانی در خاموش کردن وب کم: ${e.code}: ${e.description} line122');
      try {
        if (cameraId >= 0) {
          await CameraPlatform.instance.dispose(cameraId);
        }
      } on CameraException catch (e) {
        debugPrint(
            'ناتوانی در خاموش کردن وب کم: ${e.code}: ${e.description} line128');
      }

      if (mounted) {
        setState(() {
          _cameraId = -1;
          _cameraIndex = 0;
          _previewSize = null;
          _cameraInfo =
              'ناتوانی در روشن کردن وب کم: ${e.code}: ${e.description}';
        });
      }
    }
  }

  Future<void> _disposeCurrentCamera() async {
    if (_cameraId >= 0) {
      try {
        await CameraPlatform.instance.dispose(_cameraId);

        if (mounted) {
          setState(() {
            _cameraId = -1;
            _previewSize = null;
            _cameraInfo = 'وب کم خاموش است';
          });
        }
      } on CameraException catch (e) {
        debugPrint(
            'ناتوانی در خاموش کردن وب کم: ${e.code}: ${e.description} line158');
        if (mounted) {
          setState(() {
            _cameraInfo =
                'ناتوانی در خاموش کردن وب کم: ${e.code}: ${e.description} line162';
          });
        }
      }
    }
  }

  Future<void> _initiateDefaultWebcam(String webcamId) async {
    if (_cameras.isNotEmpty) {
      setState(() {
        _initialized = true;
      });
      if (_cameras.any((element) =>
          element.name.split('<')[1] ==
          Global.shPreferences.getString(DEFAULT_WEBCAM_ID)))
        _cameraIndex = _cameras.indexWhere((element) =>
            element.name.split('<')[1] ==
            Global.shPreferences.getString(DEFAULT_WEBCAM_ID));
      await _initializeCamera();
    }
  }

  Future<void> _switchCamera(BuildContext context, int index) async {
    if (_cameras.isNotEmpty) {
      context.read<WebcamController>().emit(WebcamStatesLoading());
      setState(() {
        _initialized = true;
      });
      _cameraIndex = index;
      await _disposeCurrentCamera();
      await _fetchCameras();
      await _initializeCamera();
      context.read<WebcamController>().getDefaultWebcam();
    }
  }

  Widget _buildPreview() {
    return CameraPlatform.instance.buildPreview(_cameraId);
  }

  void _captureAndSaveWidgetAsPicture() {
    screenshotController
        .capture()
        .then((image) => setState(() {
              _imageFile = image;
              _saveImage(_imageFile!);
            }))
        .catchError((onError) {
      debugPrint(onError);
    });
  }

  Future<void> _saveImage(Uint8List imageBytes) async {
    try {
      final directory = await provider.getDownloadsPath();
      final fileName =
          '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}---${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}.png';
      final file = File('$directory\\$fileName');
      await file.writeAsBytes(imageBytes);
      Navigator.pop(context, base64Encode(await file.readAsBytes()));
      await Future.delayed(Duration(milliseconds: 100));
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
          "Image saved in database and ${file.path}",
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.amber,
          ),
        ),
      ).show(context);
    } catch (error) {
      debugPrint('Error saving image: $error');
    }
  }

  Future<void> _togglePreview(BuildContext context) async {
    if (_cameraId >= 0) {
      context.read<WebcamController>().emit(WebcamStatesLoading());
      await CameraPlatform.instance.pausePreview(_cameraId);
      await Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        reverseAnimationCurve: Curves.decelerate,
        forwardAnimationCurve: Curves.elasticOut,
        backgroundGradient:
            LinearGradient(colors: [Colors.blueGrey, Colors.black]),
        mainButton: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                _captureAndSaveWidgetAsPicture();
                Navigator.pop(context);
              },
              child: Text(
                "Yes",
                style: TextStyle(color: Colors.amber),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await CameraPlatform.instance.resumePreview(_cameraId);
              },
              child: Text(
                "No",
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ],
        ),
        showProgressIndicator: true,
        progressIndicatorBackgroundColor: Colors.blueGrey,
        messageText: Text(
          "Do you want to save this photo?",
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.amber,
          ),
        ),
      ).show(context);
      context.read<WebcamController>().getDefaultWebcam();
    }
  }

  void _onCameraError(CameraErrorEvent event) {
    if (mounted) {
      debugPrint('خطا: ${event.description}');
      _disposeCurrentCamera();
      _fetchCameras();
    }
  }

  void _onCameraClosing(CameraClosingEvent event) {
    if (mounted) {
      debugPrint('وب کم در حال خاموش شدن ...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WebcamController>(
      create: (context) => WebcamController(),
      child: BlocConsumer<WebcamController, WebcamStates>(
        listener: (context, state) async {
          if (state is WebcamStatesFetchedWithNoDefault)
            await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => WebcamSelectionDialog(
                      title: 'وب کم پیش فرض را انتخاب نمایید:',
                      webcamIDs: _cameras.map((e) => e.name).toList(),
                    )).then((value) async {
              await context.read<WebcamController>().changeDefaultWebcam(value);
              context.read<WebcamController>().initiateWebcams();
            });
          else if (state is WebcamStatesInitiateWithDefault)
            _initiateDefaultWebcam(state.defaultWebcamID);
        },
        builder: (context, state) {
          return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () {
                      if (state is! WebcamStatesLoading) {
                        _disposeCurrentCamera();
                        _errorStreamSubscription?.cancel();
                        _errorStreamSubscription = null;
                        _cameraClosingStreamSubscription?.cancel();
                        _cameraClosingStreamSubscription = null;
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(Icons.arrow_back)),
              ),
              body: ListView(
                children: <Widget>[
                  _cameras.isEmpty
                      ? Container()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'وب کم مورد نظر را انتخاب کنید:',
                              textDirection: TextDirection.rtl,
                            ),
                            Container(
                              height: 100,
                              child: ListView.builder(
                                itemCount: _cameras.length,
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () => state is! WebcamStatesLoading
                                      ? _switchCamera(context, index)
                                      : null,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      state is WebcamStatesFetchedWithDefault
                                          ? Text(_cameras[index]
                                                      .name
                                                      .split('<')[1] ==
                                                  state.defaultWebcamID
                                              ? '(پیش فرض) '
                                              : '')
                                          : state
                                                  is WebcamStatesInitiateWithDefault
                                              ? Text(_cameras[index]
                                                          .name
                                                          .split('<')[1] ==
                                                      state.defaultWebcamID
                                                  ? '(پیش فرض) '
                                                  : '')
                                              : Container(),
                                      Text(_cameras[index].name.split('<')[0]),
                                      Text(
                                        ' -${index + 1}',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                  _cameras.isNotEmpty
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(width: 20),
                            _initialized && state is! WebcamStatesLoading
                                ? ElevatedButton(
                                    onPressed: () => _togglePreview(context),
                                    child: const Text('ثبت عکس'),
                                  )
                                : Container(),
                            const SizedBox(width: 5),
                            _initialized &&
                                    _cameras.length > 1 &&
                                    state is WebcamStatesFetchedWithDefault &&
                                    _cameraInfo.contains('<') &&
                                    _cameraInfo.split('<')[1] !=
                                        state.defaultWebcamID
                                ? ElevatedButton(
                                    onPressed: () async => await context
                                        .read<WebcamController>()
                                        .changeDefaultWebcam(
                                            _cameraInfo.split('<')[1]),
                                    child:
                                        const Text('انتخاب به عنوان پیش فرض'),
                                  )
                                : Container(),
                          ],
                        )
                      : Center(
                          child: Text('هیچ وب کمی یافت نشد'),
                        ),
                  const SizedBox(height: 5),
                  _cameraId > 0 && _previewSize != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: Align(
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 500,
                              ),
                              child: AspectRatio(
                                aspectRatio:
                                    _previewSize!.width / _previewSize!.height,
                                child: Screenshot(
                                    controller: screenshotController,
                                    child: _buildPreview()),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ));
        },
      ),
    );
  }
}
