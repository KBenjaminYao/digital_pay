import 'package:digital_pay/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VisaWidget extends StatefulWidget {
  final String accessToken;
  final int amount;
  const VisaWidget({Key? key, required this.accessToken, required this.amount})
      : super(key: key);

  @override
  State<VisaWidget> createState() => _VisaWidgetState();
}

class _VisaWidgetState extends State<VisaWidget> {
  bool isReady = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          WebView(
            onPageFinished: (url) {
              setState(() {
                isReady = true;
              });
            },
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl:
                "http://192.168.43.94:8000/api/gtb/form?access_token=${widget.accessToken}&amount=${widget.amount}",
          ),
           !isReady ?Positioned(
             top: 0,
              child: Container(
                margin: EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width - 50,
                child: SpinKitDualRing(
            color: primaryColor,
            size: 80,
            lineWidth: 10,
          ),
              )) : Container()
        ],
      ),
    );
  }
}
