library digital_pay;

import 'dart:async';

import 'package:country_picker/country_picker.dart';
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
  static Future<Map> checkout(
      {required BuildContext context,
      required accessToken,
      required amount}) async {
    try {
      Map result =
          await Navigator.push(context, MaterialPageRoute(builder: (c) {
        return HomeDPay(accessToken: accessToken, amount: amount);
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
    return await ApiDCI.verification(transactionID);
  }
}

//Payer en toute sécurité avec notre système
class HomeDPay extends StatefulWidget {
  /// Obtenir votre accessToken [accessToken] via https://pay.digital.ci
  final String accessToken;

  /// Le montant [amount] de la transaction doit être supérieur à 10
  final int amount;

  final Function(dynamic)? waitResponse;
  const HomeDPay(
      {Key? key,
      required this.accessToken,
      required this.amount,
      this.waitResponse})
      : super(key: key);

  @override
  State<HomeDPay> createState() => _HomeDPayState();
}

class _HomeDPayState extends State<HomeDPay> {
  Map assets = {
    "momo": [
      "https://www.ubabenin.com/wp-content/uploads/sites/6/2022/04/245.png",
      "MTN",
      true
    ],
    "moov": [
      "https://play-lh.googleusercontent.com/ON1Rr1bNthJnb-DEEu4ktgmKEZ9uvvrjg9QI84YltjtcD73peOF6ARZXRAogrUYT4Q",
      "MOOV",
      false
    ],
    "orange": [
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSf6yZAUhceAOD3lZdI3Fy1kdI61bWN6cHuKJufaj84sYM_xrSLwzQK0ud7spfFKT7gtnM&usqp=CAU",
      "OM",
      false
    ],
    "visa": [
      "https://img2.freepng.fr/20180814/oqo/kisspng-mastercard-visa-bank-card-portable-network-graphic--5b72ceb25742b5.6910264415342506743574.jpg",
      "VISA",
      false
    ]
  };
  String phoneCode = "+225";
  String operator = "MTN";
  TextEditingController contactController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final maxTime = 60;
  bool isReady = true;
  bool? failTransaction;
  late int counter;
  Timer? _timer;
  Map userInfo = {};
  String idTransaction = "";

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
              unloading(context, {
                "code": "NOT_PERMITED",
                "message":
                    "Désoler vous n'êtes pas autorisé à utiliser ce service!!!"
              });
            }
          }
        } else {
          if (mounted) {
            unloading(context, {
              "code": "SERVER_ERROR",
              "message": "Désoler une erreur s'est produite!!!"
            });
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
        setState(() {
          counter = maxTime;
          failTransaction = statut;
        });
        if (statut) {
          if (mounted) {
            setState(() {
              isReady = true;
            });
            unloading(context, {
              "code": "TIME_OFF",
              "message": "Temps de la transaction écoulé!!!"
            });
          }
        } else {
          if (mounted) {
            unloading(context, {
              "code": "SERVER_ERROR",
              "message": "Désoler une erreur s'est produite!!!"
            });
          }
        }
      });
    } else {}
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
                        buttonPaiement(assets["orange"][0], assets["orange"][1],
                            "orange", assets["orange"][2]),
                        buttonPaiement(assets["moov"][0], assets["moov"][1],
                            "moov", assets["moov"][2]),
                        buttonPaiement(assets["visa"][0], assets["visa"][1],
                            "visa", assets["visa"][2]),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: const Text(
                  "DIGITAL PAY",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              const SizedBox(height: 5),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4.0,
                            spreadRadius: 1.0,
                            color: secondaryColor,
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.only(top: 2),
                          child: GestureDetector(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  countryFilter: ["CI"],
                                  countryListTheme: CountryListThemeData(
                                    flagSize: 25,
                                    backgroundColor: Colors.white,
                                    textStyle: const TextStyle(
                                        fontSize: 16, color: Colors.blueGrey),
                                    bottomSheetHeight:
                                        250, // Optional. Country list modal height
                                    //Optional. Sets the border radius for the bottomsheet.
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                    //Optional. Styles the search field.
                                    inputDecoration: InputDecoration(
                                      labelText: 'Rechercher',
                                      hintText: 'Recherchez un pays',
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: const Color(0xFF8C98A8)
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onSelect: (Country country) {
                                    setState(() {
                                      phoneCode = "+" + country.phoneCode;
                                    });
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  phoneCode,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor),
                                ),
                              )),
                        ),
                        title: TextFormField(
                          enabled: isReady,
                          validator: Validators.compose([
                            Validators.required("Le numéro est Oligatoire"),
                            Validators.minLength(
                                12, "Veuillez renseigner un numéro correct"),
                            Validators.minLength(
                                12, "Veuillez renseigner un numéro correct"),
                            Validators.patternRegExp(
                                RegExp(RegExp.escape("05")),
                                "Numéro $operator incorrect")
                          ]),
                          controller: contactController,
                          inputFormatters: [maskNumero],
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.bold),
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Numéro de téléphone',
                            border: InputBorder.none,
                            errorStyle: TextStyle(
                              fontSize: 12,
                              height: .06,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Center(
                      child: Text(
                        "Sécurisé avec DIGITAL PAY",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    isReady
                        ? Container()
                        : Column(
                            children: [
                              ListTile(
                                title: Text(
                                  failTransaction == null
                                      ? "Veuillez composer *133# choisir puis  l'option 1 pour confirmer la transaction"
                                      : "Nous n'avons pas pu procéder à la vérification de votre transaction",
                                  style: TextStyle(
                                      color: failTransaction == null
                                          ? Colors.black
                                          : Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                trailing: failTransaction != null
                                    ? null
                                    : Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 3, color: primaryColor),
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: Text(
                                          counter < 10
                                              ? "0$counter"
                                              : "$counter",
                                          style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                              ),
                              failTransaction != null
                                  ? Container()
                                  : SpinKitWave(
                                      color: secondaryColor,
                                      size: 20,
                                    ),
                            ],
                          ),
                    Container(
                        width: MediaQuery.of(context).size.width - 60,
                        margin: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(primaryColor)),
                            onPressed: !isReady
                                ? null
                                : () async {
                                    bool state =
                                        formKey.currentState!.validate();
                                    if (!state) {
                                      return;
                                    }
                                    if (failTransaction != null) {
                                      starTimer(idTransaction);
                                    } else {
                                      momoPaiementAction();
                                    }
                                  },
                            child: Text((failTransaction != null)
                                ? "Ressayer"
                                : "PAYER")))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
                    assets["orange"][2] = false;
                    assets["moov"][2] = false;
                    assets["visa"][2] = false;
                    assets[code][2] = true;
                  });
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
                    border: Border.all(color: primaryColor, width: 3)),
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

  void momoPaiementAction() {
    loading(context);
    ApiDCI.paiement({
      "montant": widget.amount,
      "entreprise": widget.accessToken,
      "numero": unMask(contactController.text),
      "fournisseur": operator,
    }).then((value) {
      unloading(context);
      if (value != "error") {
        Map data = {};
        try {
          data = value;
          setState(() {
            idTransaction = data["code"];
            isReady = false;
            starTimer(idTransaction);
          });
        } catch (e) {
          setState(() {
            isReady = true;
            counter = maxTime;
          });
          toastMsg("Impossible de poursuivre l'opération! Veuillez réessayer.");
        }
      } else {
        setState(() {
          isReady = true;
          counter = maxTime;
        });

        toastMsg("Opération echouée! Veuillez réessayer.");
      }
    });
  }

  void starTimer(String idTransaction) {
    counter = maxTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (mounted) {
        setState(() {
          counter--;
        });
      }
      await verificationTrans(idTransaction);
    });
  }

  verificationTrans(String idTransaction) async {
    await ApiDCI.verification(idTransaction).then((value) {
      if (value != "error") {
        if (value["status"] == "FAILED") {
          _timer?.cancel();
          Map result = {
            "code": "FAIL_TRANSACTION",
            "message": "Transaction échouée!!!",
            "id": idTransaction
          };
          result.addAll(value);
          if (mounted) {
            unloading(context, result);
          }
        } else if (value["status"] == "SUCCESSFUL") {
          Map result = {
            "code": "SUCCESS_TRANSACTION",
            "message": "Transaction échouée!!!",
            "id": idTransaction
          };
          result.addAll(value);
          if (mounted) {
            unloading(context, result);
          }
        }
      } else {
        if (mounted) {
          unloading(context, {
            "code": "SERVER_ERROR",
            "message": "Désoler une erreur s'est produite!!!"
          });
        }
      }
    });
  }
}
