import 'dart:convert';

import 'package:currency_formatter/currency_formatter.dart';
import 'package:digital_pay/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void unloading(BuildContext context, [Map? data]) {
  Navigator.pop(context, data);
}

 loading(context){
  showDialog(context: context, builder: (c){
    return WillPopScope(
      onWillPop: (){
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            width: 180,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: primaryColor, width: 5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitCircle(
                  color: primaryColor,
                  size: 40,
                ),
                const Text("Chargement...")
              ],
            ),
          ),
        ),
      ),
    );
  });
}

toastMsg(String msg, [String? type = "danger"]){
  Fluttertoast.showToast(
    msg: msg,
    backgroundColor: type == "danger" ? Colors.red : Colors.green,
    gravity: ToastGravity.TOP,
    toastLength: Toast.LENGTH_LONG
  );
}

class ApiDCI{
  static Future get(uri, path, [Map? params, String? _token]) async {
    var q = "";
    var link = "";
    if (params != null) {
      q = "?";

      params.forEach((key, value) {
        q += key.toString() + "=" + value.toString() + "&";
      });
      _token != null ? q += "_token=$_token" : q = q.substring(0, q.length - 1);
      link = uri + path + q;
    } else {
      link = uri + path;
    }
    try {
      var response = await http.get(Uri.parse(link), headers: _setHeaders());
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "error";
      }
    } catch (e) {
      return "error";
    }
  }
  
  static Future gestSellerInfo(String accessToken) async {
    var response =  await get("$requestLink/", "seller",{"code": accessToken});
    //  var response =  await custom("""SELECT entreprises.*,abonnements.id AS abonnement_id,abonnements.libelle AS abonnement_libelle,abonnements.duree AS abonnement_duree,abonnements.amount AS abonnement_amount,abonnements.description AS abonnement_description,souscriptions.id AS souscription_id,souscriptions.statut AS souscription_statut,souscriptions.date_debut AS souscription_date_debut,souscriptions.date_fin AS souscription_date_fin FROM entreprises,abonnements,souscriptions WHERE entreprises.code="$accessToken" AND souscriptions.entreprise_id=entreprises.id AND souscriptions.abonnement_id=abonnements.id;""");
    if (response != "error") {
      Map sellerData = jsonDecode(response);
      if (sellerData.isNotEmpty) {
        return sellerData;
      } else {
        return {};
      }
      
    } else {
      return "error";
    }
  }
  static Future paiement([Map? params]) async {
    var q = "";
    if (params != null) {
      q = "/";
      params.forEach((key, value) {
        q += value.toString() + "/";
      });
      q = q.substring(0, q.length - 1);
    }

    try {
      var response = await http.get(Uri.parse(requestLink+q), headers: _setHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return "error";
      }
    } catch (e) {
      return "error";
    }
  }

  static Future verification(String accesToken) async {
    String link = responseLink+"/"+accesToken;
    try {  
      var response = await http.get(Uri.parse(link), headers: _setHeaders());
      if (response.statusCode == 200) {
        Map resultTrans = jsonDecode(response.body);
        return resultTrans;
      } else {
        return "error";
      }
    } catch (e) {
      return "error";
    }
  }


  static Future<bool> setErrorTransaction(String idTransaction) async {
    bool state = false;
    await get(requestLink, "/seterror",{"id_transaction" : idTransaction}).then((value) {
      state = jsonDecode(value);
    });
    return state;
  }

  static _setHeaders() => {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
}

var maskNumero = MaskTextInputFormatter(
  mask: '##-####-####',
  filter: {
    "#": RegExp(r'[0-9]'),
  },
);

String unMask(String string) {
  string = string.replaceAll("-", "");
  return string.trim();
}

String numberFormat(int amount) {
  CurrencyFormatterSettings euroSettings = CurrencyFormatterSettings(
    symbol: 'FCFA',
    symbolSide: SymbolSide.right,
    thousandSeparator: ' ',
    symbolSeparator: ' ',
  );

  return CurrencyFormatter.format(amount, euroSettings, decimal: 0);
}