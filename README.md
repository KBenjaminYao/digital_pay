# digital_pay

This package allows you to make your payments safely. Designed to make your task easier with a simple widget.

## Features

 - `Paiment via MTN CI` 

## Getting started

To use this package, add digital_pay as a dependency in your pubspec.yaml file.

## Usage

Minimal example:

```dart
    //Launching the checkout request
    DigitalPay.checkout(
            context: context,
            accessToken: "MY_ACCESS_TOKEN",
            amount: 10)
        .then((result) {
          //result of the request
      print(result);
    });
```

Material App settings:

```dart
import 'dart:io';
import 'package:flutter/material.dart';

//Secure all hhtp request with [https]
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
//END secure http

//Change your main App
void main() async {
  //intialize http requests
  HttpOverrides.global = MyHttpOverrides();
  return runApp(const MyApp());
}
//END Change
```
