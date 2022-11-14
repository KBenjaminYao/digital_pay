import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:digital_pay/constant.dart';
import 'package:digital_pay/required.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class MomoWidget extends StatefulWidget {
  final int amount;
  final String accessToken;
  const MomoWidget({Key? key, required this.amount, required this.accessToken}) : super(key: key);

  @override
  State<MomoWidget> createState() => _MomoWidgetState();
}

class _MomoWidgetState extends State<MomoWidget> {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
                                color: const Color(0xFF8C98A8).withOpacity(0.2),
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
                      RegExp(RegExp.escape("05")), "Numéro $operator incorrect")
                ]),
                controller: contactController,
                inputFormatters: [maskNumero],
                style:
                    TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
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
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 3, color: primaryColor),
                                  borderRadius: BorderRadius.circular(100)),
                              child: Text(
                                counter < 10 ? "0$counter" : "$counter",
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
                      backgroundColor: MaterialStateProperty.all(primaryColor)),
                  onPressed: !isReady
                      ? null
                      : () async {
                          bool state = formKey.currentState!.validate();
                          if (!state) {
                            return;
                          }
                          if (failTransaction != null) {
                            starTimer(idTransaction);
                          } else {
                            momoPaiementAction();
                          }
                        },
                  child:
                      Text((failTransaction != null) ? "Ressayer" : "PAYER")))
        ],
      ),
    );
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
    await ApiDCI.verification(accessToken: idTransaction).then((value) {
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
          String message = "Transaction échouée!!!";
          Map result = {
            "code": "SUCCESS_TRANSACTION",
            "message": message,
            "id": idTransaction
          };
          result.addAll(value);
          if (mounted) {
            unloading(context, result);
          }
        }
      } else {
        if (mounted) {
          String message = "Désoler une erreur s'est produite!!!";
          unloading(context, {"code": "SERVER_ERROR", "message": message});
        }
      }
    });
  }

  void momoPaiementAction() {
    loading(context);
    ApiDCI.paiement(
      amount: widget.amount,
      accessToken: widget.accessToken,
      number: unMask(contactController.text),
      operator: operator,
    ).then((value) {
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
}
