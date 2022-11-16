import 'dart:convert';

import 'package:digital_pay/constant.dart';
import 'package:digital_pay/required.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:html/parser.dart';

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
  InAppWebViewController? webViewController;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .5,
      child: Stack(
        children: [
          InAppWebView(
            onLoadStop: (controller, url) async {
              setState(() {
                isReady = true;
              });
              String uri = url!.host + url.path;
              if (uri == host) {
                var data = await webViewController!.getHtml();
                var document = parse(data);
                final render = parse(document.body!.text).documentElement!.text;
                try {
                  Map reponse = jsonDecode(render);

                  if (reponse["statut"] == "error") {
                    Map result = {
                      "code": "FAIL_TRANSACTION",
                      "message": "Transaction échouée!!!",
                      "gt_msg" : reponse["gtpay_tranx_status_msg"]
                    };
                    unloading(context, result);
                  } else {
                    Map result = {
                      "code": "SUCCESS_TRANSACTION",
                      "message": "Transaction effectuée!!!",
                    };
                    result.addAll(reponse);
                    unloading(context, result);
                  }
                } catch (e) {
                  return Future.error(e);
                }
              }
            },
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                isReady = false;
              });
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED);
            },
            initialUrlRequest: URLRequest(
              url: Uri.https("pay.digital.ci", "api/gtb/form", {
                "access_token": widget.accessToken,
                "amount": widget.amount.toString(),
              }),
            ),
          ),
          !isReady
              ? Positioned(
                  top: 0,
                  left: 20,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    width: MediaQuery.of(context).size.width - 50,
                    child: SpinKitPouringHourGlassRefined(
                      color: primaryColor,
                      size: 80,
                      strokeWidth: 1,
                    ),
                  ))
              : Container()
        ],
      ),
    );
  }
}
