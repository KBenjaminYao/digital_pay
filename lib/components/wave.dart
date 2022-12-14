import 'dart:async';

import 'package:digital_pay/required.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

class WaveWidget extends StatefulWidget {
  final int amount;
  final String accessToken;
  const WaveWidget({Key? key, required this.amount, required this.accessToken})
      : super(key: key);

  @override
  State<WaveWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget> {
  bool isReady = true;
  int counter = 60;
  Timer? _timer;
  Timer? _timerVerif;
  Map data = {};
  Map resultData = {};

  @override
  void dispose() {
    _timer?.cancel();
    _timerVerif?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Material(
              borderRadius: BorderRadius.circular(16),
              color: !isReady
                  ? const Color(0xFF1dc8ff).withAlpha(100)
                  : resultData.isEmpty
                      ? const Color(0xFF1dc8ff)
                      : Colors.green.withOpacity(.8),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: !isReady
                    ? null
                    : resultData.isEmpty
                        ? () async {
                            loading(context);
                            var result = await ApiDCI.paiementWave(
                              amount: widget.amount,
                              accessToken: widget.accessToken,
                            );
                            unloading(context);
                            try {
                              setState(() {
                                data = result;
                              });
                              if (data.isEmpty) {
                                errorTraitement();
                                return;
                              }
                            } catch (e) {
                              errorTraitement();
                              return;
                            }

                            String urlLaunch = result["wave_launch_url"];
                            if (urlLaunch.isNotEmpty) {
                              setState(() {
                                isReady = false;
                              });
                            } else {
                              errorTraitement();
                              _timer?.cancel();
                              _timerVerif?.cancel();
                              return;
                            }
                            final Uri _url = Uri.parse(
                              result["wave_launch_url"],
                            );
                            if (!await launchUrl(
                              _url,
                              mode: LaunchMode.externalNonBrowserApplication,
                            )) {
                              errorTraitement();
                              _timer?.cancel();
                              _timerVerif?.cancel();
                              return;
                            } else {
                              starTimer();
                              verifTimer();
                            }
                          }
                        : () {
                            if (mounted) {
                              unloading(context, resultData);
                            }
                          },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child:
                      Text(resultData.isEmpty ? "PAYER AVEC WAVE" : "TERMINER",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: !isReady ? Colors.grey : Colors.white,
                          ),
                          textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
          !isReady
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: const [
                        SpinKitThreeInOut(
                          color: Color(0xFFf58231),
                        ),
                        Text("Traitement en cours...")
                      ],
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.black12,
                      child: Container(
                        width: 100,
                        height: 100,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100)),
                        child: Text(
                          "$counter",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    )
                  ],
                )
              : Container()
        ],
      ),
    );
  }

  void errorTraitement() {
    toastMsg("D??soler! Une erreur s'est produite. Veuillez r??essayer!!!");
    setState(() {
      isReady = true;
    });
  }

  void starTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        counter--;
      });
      if (counter == 0) {
        _timer?.cancel();
        await ApiDCI.setErrorTransaction(data["code"]).then((value) {
          if (value) {
            if (mounted) {
              String message = "Temps de la transaction ??coul??!!!";
              unloading(context, {"code": "TIME_OFF", "message": message});
            }
          } else {
            if (mounted) {
              String message = "D??soler une erreur s'est produite!!!";
              unloading(context, {"code": "SERVER_ERROR", "message": message});
            }
          }
        });
      }
    });
  }

  void verifTimer() {
    _timerVerif = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await verification();
    });
  }

  Future<void> verification() async {
    if (data.isEmpty) {
      return;
    }
    await ApiDCI.verificationWave(id: data["code"])
        .then((value) {
          if (value != "error") {
            if (value["checkout_status"] == "expired") {
              _timerVerif?.cancel();
              _timer?.cancel();
              Map result = {
                "code": "FAIL_TRANSACTION",
                "message": "Transaction ??chou??e!!!",
                "id": value["id"]
              };
              result.addAll(value);
              if (mounted) {
                unloading(context, result);
              }
            } else if (value["checkout_status"] == "complete") {
              _timerVerif?.cancel();
              _timer?.cancel();
              String message = "Transaction  effectu??e !!!";
              Map result = {
                "code": "SUCCESS_TRANSACTION",
                "message": message,
                "id": value["id"]
              };
              result.addAll(value);
              setState(() {
                resultData = result;
                isReady = true;
              });
            }
          } else {
            if (mounted) {
              _timerVerif?.cancel();
              _timer?.cancel();
              String message = "D??soler une erreur s'est produite!!!";
              unloading(context, {"code": "SERVER_ERROR", "message": message});
            }
          }
        })
        .timeout(const Duration(seconds: 5))
        .onError((error, stackTrace) => null);
  }
}
