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

loading(context) {
  showDialog(
      context: context,
      builder: (c) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(true);
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                width: 180,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(top: BorderSide(color: primaryColor, width: 5)),
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

toastMsg(String msg, [String? type = "danger"]) {
  Fluttertoast.showToast(
      msg: msg,
      backgroundColor: type == "danger" ? Colors.red : Colors.green,
      gravity: ToastGravity.TOP,
      toastLength: Toast.LENGTH_LONG);
}

class ApiDCI {
  static Future get(uri, path, [Map? params, String? _token]) async {
    var q = "";
    var link = "";
    path = "/" + path;
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
      var result = response.body;
      if (response.statusCode == 200 && result != "error") {
        return jsonDecode(result);
      } else {
        return "error";
      }
    } catch (e) {
      return "error";
    }
  }

  static Future gestSellerInfo(String accessToken) async {
    var response = await get(apiLink, "seller", {"code": accessToken});
    return response;
  }

  static Future paiement({
    required int amount,
    required String accessToken,
    required String number,
    required String operator,
  }) async {
    var response = await get(apiLink, "paiement", {
      "access_token": accessToken,
      "amount": amount,
      "number": "225" + number,
      "operator": operator,
    });
    return response;
  }

  static Future paiementWave({
    required int amount,
    required String accessToken,
  }) async {
    var response = await get("$apiLink/wave", "paiement", {
      "amount": amount,
      "access_token": accessToken,
    });
    return response;
  }

  static Future verificationWave({required String id}) async {
    var response = await get("$apiLink/wave", "verification", {"id": id});
    return response;
  }

  static Future verification({required String accessToken}) async {
    var response =
        await get(apiLink, "verification", {"access_token": accessToken});
    return response;
  }

  static Future<bool> setErrorTransaction(String idTransaction) async {
    try {
      return await get(apiLink, "seterror", {"id_transaction": idTransaction});
    } catch (e) {
      return false;
    }
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
