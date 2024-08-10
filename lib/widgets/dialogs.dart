import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_customers_info/utils/constants.dart';

class WebcamSelectionDialog extends StatefulWidget {
  final String title;
  final List<String> webcamIDs;

  const WebcamSelectionDialog({
    required this.title,
    required this.webcamIDs,
  });

  @override
  State<WebcamSelectionDialog> createState() => _WebcamSelectionDialogState();
}

class _WebcamSelectionDialogState extends State<WebcamSelectionDialog> {
  String? selectedWebcamID;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Builder(
        builder: (context) => Dialog(
          backgroundColor: whiteColor,
          child: Container(
            width: 100,
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: whiteColor, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 30),
                Text(
                  widget.title,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: blackColor),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Column(
                      children: [
                        ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: widget.webcamIDs.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: selectedWebcamID ==
                                                widget.webcamIDs[index]
                                                    .split('<')[1]
                                            ? Color(0xD1D3DE).withOpacity(0.5)
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: MaterialButton(
                                      onPressed: () => setState(() {
                                        selectedWebcamID = widget
                                            .webcamIDs[index]
                                            .split('<')[1];
                                      }),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10)),
                                          Text(
                                              '${index + 1}- ${widget.webcamIDs[index].split('<')[0]}',
                                              style:
                                                  TextStyle(color: blackColor)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ],
                    )),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                        onPressed: () => selectedWebcamID != null
                            ? Navigator.pop(context, selectedWebcamID)
                            : null,
                        child: Text(strConfirm,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                color: blackColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w400))),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
