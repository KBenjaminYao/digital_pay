library digital_pay;

import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:digital_pay/components/momo.dart';
import 'package:digital_pay/components/visa.dart';
import 'package:digital_pay/components/wave.dart';
import 'package:digital_pay/required.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

import 'constant.dart';

class DigitalPay {
  /// Payer avec le package [DigitalPay] en toute sécurité.<br/>
  /// ### Obtenez votre code d'accès [accessToken] via https://pay.digital.ci
  /// #### ```Le montant de la transaction [amount] doit être supérieur à 10.```
  /// #### ** Codes de retour
  /// #### ----------------------------------
  /// ##### "INTERNAL_ERROR" : Erreur interne
  /// ``` veuillez contacter le support: ``` https://pay.digital.ci
  /// ##### "NOT_PERMITED" : Utlisateur non autorisé
  /// ##### "SERVER_ERROR" : Erreur du serveur
  /// ##### "TIME_OFF" : Temps du delai écoulé
  /// ##### "FAIL_TRANSACTION" : transaction échouée
  /// ##### "SUCCESS_TRANSACTION" : Transaction  effectuée
  /// ##### "CANCEL" : Opération annulée

  static Future<Map> checkout({
    required BuildContext context,
    required accessToken,
    required amount,
    bool appBar = true,
  }) async {
    try {
      Map result =
          await Navigator.push(context, MaterialPageRoute(builder: (c) {
        return HomeDPay(
          accessToken: accessToken,
          amount: amount,
          appBar: appBar,
        );
      }));
      return result;
    } catch (e) {
      return {
        "code": "INTERNAL_ERROR",
        "message": "Désoler une erreur s'est produite!!!"
      };
    }
  }

  static Future verification({required String transactionID}) async {
    return await ApiDCI.verification(accessToken: transactionID);
  }
}

//Payer en toute sécurité avec notre système
class HomeDPay extends StatefulWidget {
  /// Obtenir votre accessToken [accessToken] via https://pay.digital.ci
  final String accessToken;
  final bool appBar;

  /// Le montant [amount] de la transaction doit être supérieur à 10
  final int amount;

  final Function(dynamic)? waitResponse;
  const HomeDPay({
    Key? key,
    required this.accessToken,
    required this.amount,
    required this.appBar,
    this.waitResponse,
  }) : super(key: key);

  @override
  State<HomeDPay> createState() => _HomeDPayState();
}

class _HomeDPayState extends State<HomeDPay> {
  Map assets = {
    "momo": [
      "https://raw.githubusercontent.com/KBenjaminYao/digital_pay/main/assets/momo.png",
      "MTN",
      true
    ],
    "wave": [
      "https://raw.githubusercontent.com/KBenjaminYao/digital_pay/main/assets/wave.png",
      "WAVE",
      false
    ],
    // "moov": [
    //   "https://raw.githubusercontent.com/KBenjaminYao/digital_pay/main/assets/moov.png",
    //   "MOOV",
    //   false
    // ],
    // "orange": [
    //   "https://raw.githubusercontent.com/KBenjaminYao/digital_pay/main/assets/orange.png",
    //   "OM",
    //   false
    // ],
    "visa": [
      "https://raw.githubusercontent.com/KBenjaminYao/digital_pay/main/assets/visa.png",
      "VISA",
      false
    ]
  };
  String phoneCode = "+225";
  String operator = "MTN";
  TextEditingController contactController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final maxTime = 180;
  bool isReady = true;
  bool? failTransaction;
  late int counter;
  Timer? _timer;
  Map userInfo = {};
  String idTransaction = "";
  Widget data = Container();

  @override
  void initState() {
    counter = maxTime;
    Future.delayed(Duration.zero).then((value) {
      loading(context);
      ApiDCI.gestSellerInfo(widget.accessToken).then((value) {
        unloading(context);
        if (value != "error") {
          if (value.isNotEmpty) {
            setState(() {
              userInfo = value;
            });
          } else {
            if (mounted) {
              String message =
                  "Désoler vous n'êtes pas autorisé à utiliser ce service!!!";
              unloading(context, {"code": "NOT_PERMITED", "message": message});
            }
          }
        } else {
          if (mounted) {
            String message = "Désoler une erreur s'est produite!!!";
            unloading(context, {"code": "SERVER_ERROR", "message": message});
          }
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (counter == 0) {
      _timer?.cancel();
      ApiDCI.setErrorTransaction(idTransaction).then((statut) {
        if (mounted) {
          setState(() {
            counter = maxTime;
            failTransaction = statut;
          });
        }
        if (statut) {
          if (mounted) {
            setState(() {
              isReady = true;
            });
            String message = "Temps de la transaction écoulé!!!";
            unloading(context, {"code": "TIME_OFF", "message": message});
          }
        } else {
          if (mounted) {
            String message = "Désoler une erreur s'est produite!!!";
            unloading(context, {"code": "SERVER_ERROR", "message": message});
          }
        }
      });
    } else {}
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: WillPopScope(
          child: Scaffold(
            appBar: widget.appBar
                ? AppBar(
                    backgroundColor: primaryColor,
                    title: Text(userInfo["name"] ?? ""),
                    centerTitle: true,
                  )
                : null,
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: ListView(
                children: [
                  SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: [
                            buttonPaiement(assets["momo"][0], assets["momo"][1],
                                "momo", assets["momo"][2], false),
                            buttonPaiement(assets["wave"][0], assets["wave"][1],
                                "wave", assets["wave"][2], false),
                            buttonPaiement(assets["visa"][0], assets["visa"][1],
                                "visa", assets["visa"][2], false),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "DIGITAL PAY",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  Divider(
                    indent: 20,
                    endIndent: 20,
                    thickness: 2,
                    color: Colors.orange.withOpacity(.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    numberFormat(widget.amount),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  const SizedBox(height: 5),
                  // MomoWidget(
                  //   accessToken: widget.accessToken,
                  //   amount: widget.amount,
                  // ),
                  data,
                ],
              ),
            ),
          ),
          onWillPop: () {
            unloading(
                context, {"code": "CANCEL", "message": "Opération annulée"});
            return Future.value(false);
          }),
    );
  }

  Widget buttonPaiement(String image, String op, String code, bool active,
      [bool? desactived = true]) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: desactived!
              ? null
              : () {
                  setState(() {
                    operator = op;
                    assets["momo"][2] = false;
                    assets["visa"][2] = false;
                    assets["wave"][2] = false;
                    assets[code][2] = true;
                  });

                  formRouter(code);
                },
          child: Opacity(
            opacity: active ? 1 : .4,
            child: Card(
              elevation: 5,
              child: Container(
                width: 70,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.fill,
                    ),
                    border: Border.all(
                        color: Colors.grey.withOpacity(.5), width: 2)),
              ),
            ),
          ),
        ),
        active
            ? Positioned(
                bottom: -12,
                child: SizedBox(
                  width: 90,
                  child: Center(
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: primaryColor,
                    ),
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  formRouter(String code) {
    setState(() {
      if (code == "wave") {
        data = WaveWidget(
          accessToken: widget.accessToken,
          amount: widget.amount,
        );
      }
      if (code == "momo") {
        data = MomoWidget(
          accessToken: widget.accessToken,
          amount: widget.amount,
        );
      }
      if (code == "visa") {
        data = VisaWidget(
          accessToken: widget.accessToken,
          amount: widget.amount,
        );
      }
    });
  }
}
